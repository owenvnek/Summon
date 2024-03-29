let express = require('express');
let http = require('http')
let socket_io = require('socket.io')
let readline = require('readline')

let account = require('./account.js')
let summon = require('./summon.js')
let friends = require('./friends.js')
let login = require('./login.js')
let log = require('./log.js')
let monitor = require('./monitor.js')
let notifications = require('./notifications.js')

let app = express()
let server = http.Server(app)
let io = socket_io(server)
let context = {
    active_users: {},
}
let rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout
})
let SERVER_VERSION = 1.2
let running = true
let mode = parseInt(process.argv.slice(2)[0])
let MODE_INVALID = 0
let MODE_DEV = 1
let MODE_RELEASE = 2
let port = 0

io.on('connection', function(socket) {
    if (socket == undefined) {
        return
    }
    log.write('A user connected', 'INFO');
    socket.emit('version_check')
    socket.on('version_send', function(data) {
        let version = data.version
        if (version >= SERVER_VERSION) {
            socket.emit('version_verified')
        } else {
            socket.emit('version_verification_failed')
        }
    })
    socket.on('create_account', function(data) {
        account.create_account(data, socket)
    })
    socket.on('request_account', function(data) {
        account.request_account(data, socket)
    })
    socket.on('save_profile', function(data) {
        account.save_profile(data, socket)
    })
    socket.on('login', function(data) {
        login.login(context, data, socket)
    })
    socket.on('logout', function(data) {
        login.logout(context, data, socket)
    })
    socket.on('create_summon', function(data) {
        summon.create_summon(context, data, socket)
    })
    socket.on('request_outgoing_summons', function(data) {
        summon.request_outgoing_summons(context, data, socket)
    })
    socket.on('request_incoming_summons', function(data) {
        summon.request_incoming_summons(context, data, socket)
    })
    socket.on('add_friend', function(data) {
        friends.add_friend(context, data, socket)
    })
    socket.on('remove_friend', function(data) {
        friends.remove_friend(data, socket)
    })
    socket.on('request_friends', function(data) {
        friends.request_friends(context, data, socket)
    })
    socket.on('delete_summon', function(data) {
        summon.delete_summon(data, socket)
    })
    socket.on('change_password', function(data) {
        account.change_password(data, socket)
    })
    //Whenever someone disconnects this piece of code executed
    socket.on('disconnect', function () {
        log.write('A user disconnected', 'INFO')
    })
})

if (mode == MODE_DEV) {
    port = 3000
    log.write('Starting summon server in Dev mode', 'INFO')
} else if (mode == MODE_RELEASE) {
    port = 3300
    log.write('Starting summon server in Release mode', 'INFO')
}

server.listen(port, function(req, res) {
    log.write('Listening on http://localhost:' + port, 'INFO');
})

function system_status() {
    monitor.system_status()
}

function stop() {
    log.write('Stopping the server', 'INFO')
    running = false
    server.close()
    process.exit(0)
}

function list_active_users() {
    console.log('Active users:')
    for (const [username, user] of Object.entries(context.active_users)) {
        console.log(username)
    }
}

function console_input() {
    rl.question('', (answer) => {
        let params = answer.split(' ')
        switch (params[0]) {
            case 'stop': stop()
            break
            case 'system_status': system_status()
            break
            case 'notification_test': notifications.send_notification(params[1], params[2])
            break
            case 'list': list_active_users()
        }
        if (running) {
            console_input()
        }
    })
}

function system_status_timer() {
    system_status()
    setTimeout(system_status_timer, 28800000)
}

system_status_timer()
console_input()
