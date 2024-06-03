const simpleGit = require('simple-git');
const path = require('path');
const{ execSync } = require('child_process');

const { v2 } = require('docker-compose');


const options = {
  baseDir: path.resolve(__dirname, '../'),
  binary: 'git',
  maxConcurrentProcesses: 6,
  trimmed: false,
};

const git = simpleGit(options);

function pull_structure_and_data() {
    let git = simpleGit(path.resolve(__dirname, '../ci2027-db-structure'), { binary: 'git' });
    git.pull((err, update) => {
        if (err) {
            console.log('Error: ', err);
        } else {
            console.log('Update: ', update);
        }
    });
    git = simpleGit(path.resolve(__dirname, '../ci2027-db-data'), { binary: 'git' });
    git.pull((err, update) => {
        if (err) {
            console.log('Error: ', err);
        } else {
            console.log('Update: ', update);
        }
    });
}
function pull() {
    git.pull((err, update) => {
        if (err) {
            console.log('Error: ', err);
        } else {
            console.log('Update: ', update);
        }
    });
}

pull_structure_and_data();