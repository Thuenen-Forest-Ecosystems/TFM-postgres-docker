const SmeeClient = require('smee-client')

const smee = new SmeeClient({
  source: 'https://smee.io/SHEfVsriuoRxq8AF',
  target: 'http://localhost:4000/webhook',
  logger: console
})

const events = smee.start()

// Stop forwarding events
events.close()