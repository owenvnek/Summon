let os = require('os')
let log = require('./log.js')

function system_status() {
    let free = (os.freemem() / 1000000).toString() + 'mb'
    let total = (os.totalmem() / 1000000).toString() + 'mb'
    log.write('MEMORY: ' + free + ' free of ' + total, 'INFO')
}

module.exports.system_status = system_status