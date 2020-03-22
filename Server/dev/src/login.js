let user = require('./user.js')
let data = require('./data.js')
let account = require('./account.js')
let notifications = require('./notifications.js')

function query_password_for_username(username, call_back) {
    data.parse_query('SELECT username, password FROM accounts WHERE username = \'' + username + '\'', function(result) {
        call_back(result[0].password)
    })
}

function notify_login_failed(socket, reason) {
    socket.emit('login_failed', {
        reason: reason
    })
}

function login(context, data, socket) {
    let username = data.username
    let password = data.password
    let device_token = data.device_token
    account.query_if_account_exists(username, function(existence) {
        if (existence) {
            query_password_for_username(username, function(target_password) {
                if (password === target_password) {
                    let user_obj = {
                        socket: socket,
                        outgoing_summon_queue: [],
                        friend_queue: []
                    }
                    notifications.check_device_token(username, device_token)
                    user.add_active_user(context, username, user_obj)
                    account.query_account_data(username, function(result) {
                        socket.emit('login_successful', result)
                    })
                } else {
                    notify_login_failed(socket, 'Incorrect password')
                    notifications.remove_deivce_token(device_token)
                }
            })
        } else {
            notify_login_failed(socket, 'No account by that username exists')
            notifications.remove_deivce_token(device_token)
        }
    })
}

function logout(context, account_data, socket) {
    let username = account_data.username
    user.remove_active_user(context, username)
    notifications.remove_device_token_for_username(username)
    socket.emit('logged_out')
}

module.exports.login = login
module.exports.logout = logout