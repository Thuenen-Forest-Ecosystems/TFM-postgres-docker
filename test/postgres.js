// https://docs.github.com/en/actions/using-containerized-services/creating-postgresql-service-containers#testing-the-postgresql-service-container

const { Client } = require('pg');
const result = require('dotenv').config({ path: process.env.ENV_FILE || '.env' });

// can be replaces with axios
const request = require('sync-request')

const pgclient = new Client({
    host: 'localhost',
    port: process.env.POSTGRES_PORT || "5432",
    user: process.env.POSTGRES_USER || 'postgres',
    password: process.env.POSTGRES_PASSWORD,
    database: 'postgres'
});

var assert = require('assert');
let country_admin_token = null;

describe('openApi & postgres exists', function () {
    before(async function () {
        const rest = await pgclient.connect();
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

    after(async function () {
        const rest = await pgclient.end();
    });
});

describe(`Anon User`, function () {
    it(`can NOT get cluster -> return cluster object`, function () {
        const res = request('GET', 'http://localhost:3000/cluster', {
            headers: {
                "Accept-Profile": "private_ci2027_001"
            }
        })
        
        
        assert.strictEqual(res.statusCode, 401);
    });
});

describe(`User: ${process.env.COUNTRY_ADMIN_USER}`, function () {
    it(`can login -> return 200`, function () {
        const res = request('POST', 'http://localhost:3000/rpc/login', {
            json: { "email": process.env.COUNTRY_ADMIN_USER, "pass": process.env.COUNTRY_ADMIN_PASSWORD }
        }, headers = { "Content-Type": "application/json" });
        if (res.statusCode === 200){
            country_admin_token = JSON.parse(res.getBody('utf8')).token;
            console.log(country_admin_token);
        }else{
            console.log(res.statusCode);
        }
        
        assert.strictEqual(res.statusCode, 200);
    });
    it(`can get_current_user -> return user Object`, function () {
        const res = request('GET', 'http://localhost:3000/rpc/get_current_user', {
            json: { "email": process.env.COUNTRY_ADMIN_USER, "pass": process.env.COUNTRY_ADMIN_PASSWORD },
            headers: { "Authorization": `Bearer ${country_admin_token}` }
        });
        if (res.statusCode === 200){
            assert.strictEqual(JSON.parse(res.getBody('utf8')).email, process.env.COUNTRY_ADMIN_USER);
        }else{
            console.log(res.statusCode, res.getBody('utf8'));
        }
        
        assert.strictEqual(res.statusCode, 200);
    });

    let clusterId = null;
    const clusterToSet = {
        "cluster_name": "6666666",
        "state_responsible": "BB",
        "states_affected": ["BB"],
        "grid_density": "8",
        "status": "12"
    };
    it(`can insert cluster -> return cluster object`, function () {
        console.log(clusterToSet);
        const res = request('POST', 'http://localhost:3000/rpc/set_cluster', {
            json: {
                "json_object": [clusterToSet]
            },
            headers: {
                "Authorization": `Bearer ${country_admin_token}`,
                "Content-Profile": "private_ci2027_001"
            }
        });
        if (res.statusCode === 200){
            clusterId = JSON.parse(res.getBody('utf8'))[0].id;
            assert.strictEqual(res.statusCode, 200);
        }else{
            console.log(res.getBody('utf8'), res.statusCode, res.headers);
        }
        
        assert.strictEqual(res.statusCode, 200);
    });

    it(`can get cluster -> return cluster object`, function () {
        const res = request('GET', `http://localhost:3000/cluster?id=eq.${clusterId}&select=*,plot(*,plot_location(*),tree(*),deadwood(*),edges(*),position(*),regeneration(*),structure_lt4m(*))`, {
            headers: {
                "Authorization": `Bearer ${country_admin_token}`,
                "Accept-Profile": "private_ci2027_001"
            }
        });
        if (res.statusCode === 200){
            console.log(JSON.parse(res.getBody('utf8')));
            assert.strictEqual(JSON.parse(res.getBody('utf8'))[0].id, clusterId);
        }else{
            console.log(res.getBody('utf8'));
        }
        
        assert.strictEqual(res.statusCode, 200);
    });

    it(`can DELETE cluster -> return cluster object`, function () {
        const res = request('DELETE', `http://localhost:3000/cluster?id=eq.${clusterId}`, {
            
            headers: {
                "Authorization": `Bearer ${country_admin_token}`,
                "Content-Profile": "private_ci2027_001",
                "Prefer": "return=representation"
            }
        });
        if (res.statusCode === 200){
            assert.strictEqual(JSON.parse(res.getBody('utf8'))[0].id, clusterId);
        }else{
            console.log(res.getBody('utf8'));
        }
        
        assert.strictEqual(res.statusCode, 200);
    });
});