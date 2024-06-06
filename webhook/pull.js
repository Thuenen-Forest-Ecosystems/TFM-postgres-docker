const simpleGit = require('simple-git');
const path = require('path');
const{ execSync } = require('child_process');

const { v2 } = require('docker-compose');

function pullRepository(gitPath, options, cb) {
    const git = simpleGit(path.resolve(__dirname, gitPath), { binary: 'git' });
    git.submoduleUpdate(['--recursive']);
    return git.pull(cb);
}

function pull_structure_and_data() {
  pullRepository('../', {binary: 'git'}, (err, update) => {
    if (err) {
      console.log('Error: ', err);
    }else{
      console.log('Success: ');
      execSync('npm run start')
    }
    return;

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
}

pull_structure_and_data();


git clone https://ci_server:glpat-wfBR-FVC9EZsX6hxkWfe@git-dmz.thuenen.de/datenerfassungci2027/ci2027_datenerfassung/ci2027-db-structure.git

project_635_bot_dfghshrefj5:glpat-LAC7y5crjAoE4t1MSox-