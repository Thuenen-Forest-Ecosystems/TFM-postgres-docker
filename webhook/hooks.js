// smee --url https://smee.io/SHEfVsriuoRxq8AF --path /webhook --port 4000

require('dotenv').config();

const express = require('express');
const simpleGit = require('simple-git');
const path = require('path');
const{ execSync } = require('child_process');

const helmet  = require('helmet');


// This initializes a new Express application.
const app = express();
const port = process.env.PORT || 4000;

// Helmet helps secure Express apps by setting HTTP response headers.
app.use(helmet());

// This sets the view engine to EJS. For more information, see "[View engines](#view-engines)."
app.set('views', path.join(__dirname, '/views'));
app.set('view engine', 'ejs');



/**
 * Pulls repositories when a push event from github is received
 * @returns {void}
 * @param {string} gitPath - The path to the git repository
 * @param {string} cb - The callback function
 * */
function pullRepository(remote, gitPath, options, cb) {
  const git = simpleGit(path.resolve(__dirname, gitPath), { binary: 'git' });
  const res = git.pull(remote, 'main', { '--rebase': 'true' });
  cb();
}
function pullAll(skipDocker){
  console.log('start pulling repositories');
  pullRepository('https://github.com/Thuenen-Forest-Ecosystems/TFM-postgres-docker.git', '../', {binary: 'git'}, (err, update) => {
    if (err) {
      console.log('Error: ', err);
    } else {
      console.log('Successfully pulled root');
      pullRepository('https://ci_server:glpat-wfBR-FVC9EZsX6hxkWfe@git-dmz.thuenen.de/datenerfassungci2027/ci2027_datenerfassung/ci2027-db-structure.git', '../ci2027-db-structure', {
        binary: 'git',
      }, (err, update) => {
        if (err) {
          console.log('Error: ', err);
        } else {
          console.log('Successfully pulled structure');
          pullRepository('https://ci_server:glpat-LtQLKmF3j9cQ6yAkuVZ1@git-dmz.thuenen.de/datenerfassungci2027/ci2027_datenerfassung/ci2027-db-data.git', '../ci2027-db-data', {
            binary: 'git'
          }, (err, update) => {
            if (err) {
              console.log('Error: ', err);
            } else {
              console.log('Successfully pulled data');
              if(!skipDocker)
                execSync('npm run start')
            }
          });
        }
      });
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

  const githubEvent = request.headers['x-github-event'];
  const data = request.body;

  
  //if(!data.ref.endsWith('master'))
  console.log(data.ref, githubEvent);

  if( data.action !== 'completed' || githubEvent !== 'check_suite') return;

  console.log('-------pullAll-------');
  pullAll()
});

pullAll(true);
app.listen(port);
