// smee --url https://smee.io/SHEfVsriuoRxq8AF --path /webhook --port 4000

const express = require('express');
const simpleGit = require('simple-git');
const path = require('path');
const{ execSync } = require('child_process');

const { v2 } = require('docker-compose');

const helmet  = require('helmet');
const axios = require('axios');



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
function pullRepository(gitPath, cb) {
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

  pullRepository('../', (err, update) => {
    if (err) {
      console.log('Error: ', err);
    } else {
      pullRepository('../ci2027-db-structure', (err, update) => {
        if (err) {
          console.log('Error: ', err);
        } else {
          pullRepository('../ci2027-db-data', (err, update) => {
            if (err) {
              console.log('Error: ', err);
            } else {
              pull_data();
            }
          });
        }
      });
    }
  });
});



// CHECK SERVER IS RUNNING
const servers = [
  {
    url: 'https://ci.thuenen.de/rest/',
    name: 'PostgREST',
    type: 'GET'
  },
  {
    url: 'https://ci.thuenen.de/webhook',
    name: 'Status',
    type: 'POST'
  },
  {
    url: 'https://ci.thuenen.de/swagger/',
    name: 'Swagger',
    type: 'GET'
  },
  {
    url: 'https://ci.thuenen.de/pgadmin/login',
    name: 'Swagger',
    type: 'GET'
  }
];

app.get('/status', async (req, res) => {
  const results = [];

  for (const server of servers) {
    try {
      if(server.type === 'GET'){
        const response = await axios.get(server.url);
        if (response.status === 200) {
          results.push({ server, status: 'up', active: true });
        } else {
          results.push({ server, status: 'down', active: false });
        }
      } else {
        const response = await axios.post(server.url);
        if (response.status === 202) {
          results.push({ server, status: 'up', active: true});
        } else {
          results.push({ server, status: 'down', active: false});
        }
      }

    } catch (error) {
      results.push({ server, status: error.code || 'error'});
    }

    
  }

  const data = {results: results};
  res.render('index', data);

});

app.listen(port);
