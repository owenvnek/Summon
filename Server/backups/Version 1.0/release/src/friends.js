let data = require('./data.js')
let account = require('./account.js')
let user = require('./user.js')

function query_if_friendship_exists(username, friend_username, call_back) {
    let conditions = [
        {
            variable: 'username',
            value: username
        },
        {
            variable: 'friend_username',
            value: friend_username
        }
    ]
    data.query_existence_conditions('friends', conditions, call_back)
}

function send_friendship_query(username, friend_username) {
    let values = [
        [username, friend_username]
    ]
    data.query_with_values('INSERT INTO friends VALUES ?', values, function(result) {})
}

function notify_friendship_failed(socket, reason) {
    socket.emit('friendship_failed', {
        reason: reason
    })
}

function notify_friend_added(socket) {
    socket.emit('friend_added')
}

function enqueue_friend(context, username, friend_username) {
    let sender_user = user.get_active_user(context, username)
    account.query_account_data(friend_username, function(account_data) {
        sender_user.friend_queue.push(account_data[0])
    })
}

function add_friend(context, data, socket) {
    let username = data.username
    let friend_username = data.friend_username
    account.query_if_account_exists(friend_username, function(existence) {
        if (existence) {
            query_if_friendship_exists(username, friend_username, function(existence2) {
                if (existence2) {
                    notify_friendship_failed(socket, 'You are already friends with that user')
                } else {
                    if (username === friend_username) {
                        notify_friendship_failed(socket, 'You cannot add yourself as a friend')
                    } else {
                        send_friendship_query(username, friend_username)
                        notify_friend_added(socket)
                        enqueue_friend(context, username, friend_username)
                        /**
                        query_account_data(friend_username, function(friend_data) {
                            socket.emit('send_friend', {
                                friends: [friend_data[0]]
                            })
                        })
                         */
                    }
                }
            })
        } else {
            notify_friendship_failed(socket, 'That user does not exist')
        }
    })
}

function query_friend_data(username, call_back) {
    data.parse_query_with_values('SELECT username, friend_username FROM friends WHERE username = ?', [username], call_back)
}

function request_friends(context, data, socket) {
    let username = data.username
    let request_id = data.request_id
    let source = data.source
    if (source === "queue") {
        let friend_user = user.get_active_user(context, username)
        let queue = friend_user.friend_queue
        socket.emit('send_friend', {
            friends: queue,
            request_id: request_id
        })
        friend_user.friend_queue = []
    } else if (source === "all") {
        query_friend_data(username, function(result1) {
            let friends = []
            for (let i = 0; i < result1.length; i++) {
                let friend_data = result1[i]
                let friend_username = friend_data.friend_username
                account.query_account_data(friend_username, function(result2) {
                    let account_data = result2[0]
                    friends.push(account_data)
                    if (friends.length >= result1.length) {
                        socket.emit('send_friend', {
                            friends: friends,
                            request_id: request_id
                        })
                    }
                })
            }
        })
    }
}

module.exports.add_friend = add_friend
module.exports.request_friends = request_friends