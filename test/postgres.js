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
let token = null;

describe('openApi + postgres + authentication', function () {
    it('localhost:3000 -> return 200', function () {
        const res = request('GET', 'http://localhost:3000/');
        assert.strictEqual(res.statusCode, 200);
    });
    it('http://localhost:3000/my_schemata: -> return 200', function () {
        const res = request('GET', 'http://localhost:3000/schemata');
        assert.strictEqual(res.statusCode, 200);
    });
    it('http://localhost:3000/rpc/login -> return 200', function () {
        const res = request('POST', 'http://localhost:3000/rpc/login', {
            json: { "email": "anonymous@example.com", "pass": "anonymous" }
        });
        if (res.statusCode === 200){
            token = JSON.parse(res.getBody('utf8')).token;
            console.log('TOKEN:', token);
        }else{
            console.log(res.statusCode);
        }
        
        assert.strictEqual(res.statusCode, 200);
    });
});