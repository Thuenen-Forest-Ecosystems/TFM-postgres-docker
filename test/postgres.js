// https://docs.github.com/en/actions/using-containerized-services/creating-postgresql-service-containers#testing-the-postgresql-service-container

const { Client } = require('pg');
const result = require('dotenv').config({ path: `_.env` })

// can be replaces with axios
const request = require('sync-request')

const pgclient = new Client({
    host: 'localhost',
    port: process.env.POSTGRES_PORT || "5432",
    user: process.env.POSTGRES_USER || 'postgres',
    password: process.env.POSTGRES_PASSWORD,
    database: 'TFM'
});

var assert = require('assert');
let token = null;

console.log('process.env.POSTGRES_PASSWORD', process.env.POSTGRES_PASSWORD);

describe('openApi + postgres + authentication', function () {
    before(async function () {
        await pgclient.connect();
    });
    
    it('SELECT NOW()', async function () {
        const result = await pgclient.query('SELECT NOW()');
        assert.strictEqual(result.rows.length, 1);
    });
    it('localhost:3000 -> return 200', function () {
        const res = request('GET', 'http://localhost:3000/');
        assert.strictEqual(res.statusCode, 200);
    });
    it('http://localhost:3000/schemata: -> return 200', function () {
        const res = request('GET', 'http://localhost:3000/schemata');
        assert.strictEqual(res.statusCode, 200);
    });
    it('http://localhost:3000/rpc/login -> return 200', function () {
        const res = request('POST', 'http://localhost:3000/rpc/login', {
            json: { "email": "anonymous@example.com", "pass": "anonymous" }
        });
        if (res.statusCode === 200){
            token = JSON.parse(res.getBody('utf8')).token;
        }else{
            console.log(res.statusCode);
        }
        
        assert.strictEqual(res.statusCode, 200);
    });
});