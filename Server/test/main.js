let express = require('express');
let http = require('http')
let socket_io = require('socket.io')

let app = express();
let server = http.Server(app)
let io = socket_io(server)
let context = {
    active_users: {},
    summons: {},
    summon_id: 0
}

function claim_summon_id() {
    let id = context.summon_id
    id++
    return id
}

function add_active_user(username, user) {
    context.active_users[username] = user
}

function login(data, socket) {
    let username = data.username
    let user = {
        socket: socket,
        summons: new Set(),
        friends: []
    }
    //load summons
    add_active_user(username, user)
    socket.emit('login_successful', {
        username: username
    })
    console.log('logged in successfully')
}

function get_summon(summon_id) {
    return context.summons[summon_id]
}

function check_if_user_active(username) {
    return username in context.active_users
}

function get_active_user(username) {
    return context.active_users[username]
}

function notify_created_summon(summon_id) {
    let summon = get_summon(summon_id)
    let participants = summon.participants
    for (let i = 0; i < participants.length; i++) {
        let participant = participants[i]
        console.log("trying to send to " + participant)
        if (check_if_user_active(participant)) {
            console.log("he's active")
            let user = get_active_user(participant)
            let socket = user.socket
            socket.emit('new_summon')
        }
    }
}

function add_summon(summon_id, summon) {
    context.summons[summon_id] = summon
}

function create_summon(data) {
    let title = data.title
    let participants = data.participants
    let summon_id = claim_summon_id()
    let summon = {
        title: title,
        participants: participants
    }
    add_summon(summon_id, summon)
    notify_created_summon(summon_id)
    console.log('created a summon')
}

function check_if_user_exists(username) {
    return username in context.active_users
}

function notify_friend_added(username) {
    let user = context.active_users[username]
    let socket = user.socket
    socket.emit('friend_added')
}

function notify_user_does_not_exist(username) {
    console.log(username)
    console.log(context.active_users)
    let user = context.active_users[username]
    let socket = user.socket
    socket.emit('user_not_found')
}

function add_friend(data) {
    console.log(data)
    let username = data.username
    let friend_username = data.friend_username
    console.log(context.active_users)
    console.log("checking if " + friend_username + " exists...")
    if (check_if_user_exists(friend_username)) {
        console.log("he does!")
        context.active_users[username].friends.push(friend_username)
        notify_friend_added(username)
    } else {
        console.log("he does not :(")
        notify_user_does_not_exist(username)
    }
}

io.on('connection', function(socket) {
    console.log('A user connected');
    socket.emit('connected')
    socket.on('login', function(data) {
        login(data, socket)
    })
    socket.on('create_summon', create_summon)
    socket.on('add_friend', add_friend)
    //Whenever someone disconnects this piece of code executed
    socket.on('disconnect', function () {
        console.log('A user disconnected');
    });
});

server.listen(3000, function() {
    console.log('listening on *:3000');
});