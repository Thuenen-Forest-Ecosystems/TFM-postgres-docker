// You installed the `express` library earlier. For more information, see "[JavaScript example: Install dependencies](#javascript-example-install-dependencies)."
const express = require('express');
const simpleGit = require('simple-git');
const path = require('path');
const{ execSync } = require('child_process');

const { v2 } = require('docker-compose');

// This initializes a new Express application.
const app = express();


const options = {
  baseDir: path.resolve(__dirname, '../'),
  binary: 'git',
  maxConcurrentProcesses: 6,
  trimmed: false,
};

// when setting all options in a single object

// smee --url https://smee.io/SHEfVsriuoRxq8AF --path /webhook --port 4000


function pull_data(){
  const dataGit = simpleGit(path.resolve(__dirname, '../ci2027-db-data'), { binary: 'git' });
  dataGit.pull((err, update) => {
      if (err) {
          console.log('Error: ', err);
      } else {
          console.log('Update: ', update);
          execSync('npm run restart');
      }
  });
}
function pull_structure_and_data() {
  const scructureGit = simpleGit(path.resolve(__dirname, '../ci2027-db-structure'), { binary: 'git' });
  scructureGit.pull((err, update) => {
      if (err) {
          console.log('Error: ', err);
      } else {
          console.log('Update: ', update);
          pull_data();
      }
  });
  
}
function pull() {
  const git = simpleGit(options);
  git.pull((err, update) => {
    if (err) {
      console.log('Error: ', err);
    } else {
      console.log('Update: ', update);
      // Due to not supported recursive pull, we need to pull the submodules manually
      pull_structure_and_data();
    }
  });
}

// This defines a POST route at the `/webhook` path. This path matches the path that you specified for the smee.io forwarding. For more information, see "[Forward webhooks](#forward-webhooks)."
//
// Once you deploy your code to a server and update your webhook URL, you should change this to match the path portion of the URL for your webhook.
app.post('/webhook', express.json({type: 'application/json'}), (request, response) => {

  // Respond to indicate that the delivery was successfully received.
  // Your server should respond with a 2XX response within 10 seconds of receiving a webhook delivery. If your server takes longer than that to respond, then GitHub terminates the connection and considers the delivery a failure.
  response.status(202).send('Accepted');

  // Check the `x-github-event` header to learn what event type was sent.
  const githubEvent = request.headers['x-github-event'];

  const data = request.body;

  
  //if(!data.ref.endsWith('master'))
  if(!data.ref?.endsWith('/main') && githubEvent !== 'push') return;

  console.log(data.ref, githubEvent);

  pull();

});


const port = 4000;

app.listen(port, () => {
  console.log(`Server is running on port ${port}`);
});
