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
function pullRepository(gitPath, options, cb) {
  const git = simpleGit(path.resolve(__dirname, gitPath), { binary: 'git' });
  return git.pull(cb);
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
  if(!data.ref?.endsWith('/main') && githubEvent !== 'push') return;

  pullRepository('../', {binary: 'git'}, (err, update) => {
    if (err) {
      console.log('Error: ', err);
    } else {
      pullRepository('../ci2027-db-structure', {
        binary: 'git',
        config: [
          `http.extraHeader=Authorization: Bearer ${process.env.gitlabStructureToken}`
        ]
      }, (err, update) => {
        if (err) {
          console.log('Error: ', err);
        } else {
          pullRepository('../ci2027-db-data', {
            binary: 'git',
            config: [
              `http.extraHeader=Authorization: Bearer ${process.env.gitlabDataToken}`
            ]
          }, (err, update) => {
            if (err) {
              console.log('Error: ', err);
            } else {
              execSync('npm run start')
            }
          });
        }
      });
    }
  });
});

app.listen(port);
