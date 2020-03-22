let data = require('./data.js')

function query_if_account_exists(username, call_back) {
    data.query_existence('accounts', 'username', username, function(existence) {
        call_back(existence)
    })
}

function are_account_details_to_standard(account_data) {
    let username = account_data.username
    let password = account_data.password
    let name = account_data.name
    if (username == undefined || password == undefined || name == undefined) {
        return {
            valid: false,
            reason: 'Each field must have a value'
        }
    }
    if (!(username.length >= 4 && username.length <= 12)) {
        return {
            valid: false,
            reason: 'Usernames must be between 4 and 12 characters'
        }
    }
    if (!(password.length >= 6 && password.length <= 20)) {
        return {
            valid: false,
            reason: 'Passwords must be between 6 and 20 characters'
        }
    }
    if (!(name.length >= 3 && name.length <= 18)) {
        return {
            valid: false,
            reason: 'Names must be between 3 and 18 characters'
        }
    }
    if (username.match(/^[0-9a-zA-Z_]+$/) === null) {
        return {
            valid: false,
            reason: 'Usernames must only include letters, numbers, and underscores'
        }
    }
    if (password.match(/^[0-9a-zA-Z]+$/) === null) {
        return {
            valid: false,
            reason: 'Passwords must only include letters and numbers'
        }
    }
    if (!name.match(/^[0-9a-zA-Z_]+\s+$/) === null) {
        return {
            valid: false,
            reason: 'Names must only include letters, numbers, underscores, and spaces'
        }
    }
    return {
        valid: true,
        reason: ''
    }
}

function is_account_update_to_standard(account_data) {
    let name = account_data.name
    if (name !== undefined) {
        if (!(name.length >= 3 && name.length <= 18)) {
            return {
                valid: false,
                reason: 'Names must be between 3 and 18 characters'
            }
        }
        if (!name.match(/^[0-9a-zA-Z_]+\s+$/) === null) {
            return {
                valid: false,
                reason: 'Names must only include letters, numbers, underscores, and spaces'
            }
        }
    }
    return {
        valid: true,
        reason: ''
    }
}

function is_password_change_to_standard(account_data) {
    let password = account_data.new_password
    if (!(password.length >= 6 && password.length <= 20)) {
        return {
            valid: false,
            reason: 'Passwords must be between 6 and 20 characters'
        }
    }
    if (password.match(/^[0-9a-zA-Z]+$/) === null) {
        return {
            valid: false,
            reason: 'Passwords must only include letters and numbers'
        }
    }
    return {
        valid: true,
        reason: ''
    }
}

function query_if_valid_account_data(account_data, call_back) {
    let validity = are_account_details_to_standard(account_data)
    if (!validity.valid) {
        call_back(validity)
        return
    }
    let result = {}
    query_if_account_exists(account_data.username, function(existence) {
        if (existence) {
            result =  {
                valid: false,
                reason: "An account with that username already exists"
            }
            call_back(result)
        } else {
            result = {
                valid: true,
                reason: ""
            }
            call_back(result)
        }
    })
}

function create_account(account_data, socket) {
    query_if_valid_account_data(account_data, function(account_validity) {
        if (account_validity.valid) {
            let username = account_data.username
            let name = account_data.name
            let password = account_data.password
            let image = account_data.image
            data.parse_query('SELECT COUNT(*) FROM accounts', function(result) {
                let account_count = result[0]['COUNT(*)']
                let values = [
                    [account_count, username, name, password, image]
                ]
                data.query_with_values('INSERT INTO accounts (id, username, name, password, image) VALUES ?', values, function(result) {
                    socket.emit('account_creation_successful')
                })
            })
        } else {
            socket.emit('account_creation_failed', {
                reason: account_validity.reason
            })
        }
    })
}

function query_account_data(username, call_back) {
    let values = [username]
    data.parse_query_with_values('SELECT * FROM accounts WHERE username = ?', values, call_back)
}

function request_account(data, socket) {
    let username = data.username
    query_account_data(username, function(result) {
        let account_data = result[0]
        socket.emit('send_account', account_data)
    })
}

function notify_save_profile_successful(socket) {
    socket.emit('profile_save_successful')
}

function query_save_profile(username, profile_data, socket) {
    if (profile_data.name !== undefined) {
        data.query_with_object('UPDATE accounts SET name = ? WHERE username = \'' + username + '\'', profile_data.name, function() {
        })
    }
    if (profile_data.image !== undefined) {
        data.query_with_object('UPDATE accounts SET image = ? WHERE username = \'' + username + '\'', profile_data.image, function() {
        })
    }
    notify_save_profile_successful(socket)
}

function notify_profile_saved(socket) {
    socket.emit('profile_saved')
}

function save_profile(account_data, socket) {
    let validity = is_account_update_to_standard(account_data)
    if (validity.valid) {
        let name = account_data.name
        let image = account_data.image
        let username = account_data.username
        query_account_data(username, function(result) {
            let account_data2 = result[0]
            if (name !== null) {
                account_data2.name = name
            }
            if (image !== null) {
                account_data2.image = image
            }
            query_save_profile(username, account_data2, socket)
        })
    } else {
        socket.emit('failed_to_save_profile', {
            reason: validity.reason
        })
    }
}

function query_change_password(username, new_password, call_back) {
    data.query_with_object('UPDATE accounts SET password = ? WHERE username = \'' + username + '\'', new_password, call_back)
}

function change_password(account_data, socket) {
    let validity = is_password_change_to_standard(account_data)
    let username = account_data.username
    let old_password_guess = account_data.current_password
    let new_password = account_data.new_password
    if (validity.valid) {
        query_account_data(username, function(result) {
            let account_data2 = result[0]
            let old_password = account_data2.password
            if (old_password === old_password_guess) {
                query_change_password(username, new_password, function() {
                    socket.emit('password_changed')
                })
            } else {
                socket.emit('failed_to_change_password', {
                    reason: 'Current password incorrect'
                })
            }
        })
    } else {
        socket.emit('failed_to_change_password', {
            reason: validity.reason
        })
    }
}

module.exports.query_if_account_exists = query_if_account_exists
module.exports.query_account_data = query_account_data
module.exports.create_account = create_account
module.exports.request_account = request_account
module.exports.save_profile = save_profile
module.exports.change_password = change_password