module.exports = {
    apps : [{
        name   : "TFM-Webhook",
        script : "./webhook/hooks.js",
        node_args : '-r dotenv/config'
    }]
}