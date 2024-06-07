// https://docs.github.com/en/actions/using-containerized-services/creating-postgresql-service-containers#testing-the-postgresql-service-container

const { Client } = require('pg');
const result = require('dotenv').config({ path: `_.env` })

// can be replaces with axios
const request = require('sync-request')

const pgclient = new Client({
    host: process.env.POSTGRES_HOST || 'TFM',
    port: process.env.POSTGRES_PORT || "5432",
    user: process.env.POSTGRES_USER,
    password: process.env.POSTGRES_PASSWORD,
    database: 'postgres'
});

var assert = require('assert');

describe('openApi', function () {
    it('should return 200', function () {
        const res = request('GET', 'http://localhost:3000/');
        assert.strictEqual(res.statusCode, 200);
    });
    it('should return 200', function () {
        const res = request('GET', 'http://localhost:3000/my_schemata');
        assert.strictEqual(res.statusCode, 200);
    });
    it('should return 200', function () {
        const res = request('POST', 'http://localhost:3000/rpc/login', {
            json: { email: 'web_anon@example.com', pass: 'vyui4yEEaEcBMwpaCl1idpx43d' }
        });
        console.log(res.getBody('utf8'))
        assert.strictEqual(res.statusCode, 200);
    });
});

describe('Postgres', function () {

    it('should connect', function () {
        let connected = false;
        pgclient.connect().then(() => {
            connected = true;
        }).catch((err) => {
            console.error('Error connecting to postgres', err)
            connected = false;
        });
        assert.strictEqual(connected, true);
    });
    it('should connect to postgres', function () {
        pgclient.query('SELECT NOW() as now').then((res) => {
            console.log('Connected to postgres at', res.rows[0].now)
        }).catch((err) => {
            console.error('Error connecting to postgres', err)
        });
    });
    it('should create a table', function () {
        pgclient.query('CREATE TABLE student(id SERIAL PRIMARY KEY, firstName VARCHAR(40) NOT NULL, lastName VARCHAR(40) NOT NULL, age INT, address VARCHAR(80), email VARCHAR(40))', (err, res) => {

        });
    });
});



/*
var assert = require('assert');
describe('Array', function () {
    describe('#indexOf()', function () {
        it('should return -1 when the value is not present', function () {
            assert.equal([1, 2, 3].indexOf(4), -2);
        });
    });
});

try {
    const res = request('GET', 'http://localhost:3000/');
    if(res.statusCode !== 200)
        throw 'http://localhost:3000/ not running!'
} catch (e) {
    throw e
}


// http://localhost:3000/my_schemata
try {
    const res = request('GET', 'http://localhost:3000/my_schemata');
    if(res.statusCode !== 200)
        throw 'function http://localhost:3000/my_schemata does not exist!'
} catch (e) {
    throw e
}

const pgclient = new Client({
    host: process.env.POSTGRES_HOST || 'localhost',
    port: process.env.POSTGRES_PORT || "5432",
    user: process.env.POSTGRES_USER,
    password: process.env.POSTGRES_PASSWORD,
    database: 'postgres'
});

pgclient.connect();

const table = 'CREATE TABLE student(id SERIAL PRIMARY KEY, firstName VARCHAR(40) NOT NULL, lastName VARCHAR(40) NOT NULL, age INT, address VARCHAR(80), email VARCHAR(40))'
const text = 'INSERT INTO student(firstname, lastname, age, address, email) VALUES($1, $2, $3, $4, $5) RETURNING *'
const values = ['Mona the', 'Octocat', 9, '88 Colin P Kelly Jr St, San Francisco, CA 94107, United States', 'octocat@github.com']

pgclient.query(table, (err, res) => {
    if (err) throw err
});

pgclient.query(text, values, (err, res) => {
    if (err) throw err
});

pgclient.query('SELECT * FROM student', (err, res) => {
    if (err) throw err
    console.log(err, res.rows) // Print the data in student table
    pgclient.end()
});
*/