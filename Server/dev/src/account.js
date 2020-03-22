let moment = require('moment-timezone')

let data = require('./data.js')
let log = require('./log.js')

let USERNAME_MIN_CHAR_COUNT = 4
let USERNAME_MAX_CHAR_COUNT = 16
let PASSWORD_MIN_CHAR_COUNT = 6
let PASSWORD_MAX_CHAR_COUNT = 20
let NAME_MIN_CHAR_COUNT = 3
let NAME_MAX_CHAR_COUNT = 20

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
    if (!(username.length >= USERNAME_MIN_CHAR_COUNT && username.length <= USERNAME_MAX_CHAR_COUNT)) {
        return {
            valid: false,
            reason: 'Usernames must be between ' + USERNAME_MIN_CHAR_COUNT + ' and ' + USERNAME_MAX_CHAR_COUNT + ' characters'
        }
    }
    if (!(password.length >= 6 && password.length <= 20)) {
        return {
            valid: false,
            reason: 'Passwords must be between ' + PASSWORD_MIN_CHAR_COUNT + ' and ' + PASSWORD_MAX_CHAR_COUNT + ' characters'
        }
    }
    if (!(name.length >= 3 && name.length <= 18)) {
        return {
            valid: false,
            reason: 'Names must be between ' + NAME_MIN_CHAR_COUNT + ' and ' + NAME_MAX_CHAR_COUNT + ' characters'
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
        if (!(name.length >= NAME_MIN_CHAR_COUNT && name.length <= NAME_MAX_CHAR_COUNT)) {
            return {
                valid: false,
                reason: 'Names must be between ' + NAME_MIN_CHAR_COUNT + ' and ' + NAME_MAX_CHAR_COUNT + ' characters'
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

function constrain_digits(num, digits) {
    let test = num + ''
    if (test.length < digits) {
        let diff = digits - test.length
        let result = test
        for (let i = 0; i < diff; i++) {
            result = '0' + result
        }
        return result
    }
    return test
}

function create_datetime_string(datetime) {
    return constrain_digits(datetime.year, 4) +
    '-' + constrain_digits(datetime.month, 2) +
    '-' + constrain_digits(datetime.day, 2) + 
    ' ' + constrain_digits(datetime.hour, 2) + 
    ':' + constrain_digits(datetime.minute, 2) + 
    ':00'
}

function adjust_moment(datetime_moment) {
    let now = moment()
    let NewYork_tz_offset = moment.tz.zone("America/New_York").utcOffset(now); 
    let London_tz_offset = moment.tz.zone("Europe/London").utcOffset(now);
    let offset = (NewYork_tz_offset - London_tz_offset) / 60;
    return datetime_moment.add(-offset, 'hours')
}

function get_join_date() {
    let now = adjust_moment(moment())
    let year = now.format('YYYY')
    let month = now.format('MM')
    let day = now.format('DD')
    let datetime = {
        year: year,
        month: month,
        day: day,
        hour: 0,
        minute: 0
    }
    return create_datetime_string(datetime)
}

function create_account(account_data, socket) {
    query_if_valid_account_data(account_data, function(account_validity) {
        if (account_validity.valid) {
            let username = account_data.username
            let name = account_data.name
            let password = account_data.password
            let image = account_data.image
            let join_date = get_join_date()
            data.parse_query('SELECT COUNT(*) FROM accounts', function(result) {
                let account_count = result[0]['COUNT(*)']
                let values = [
                    [account_count, username, name, password, join_date, image]
                ]
                data.query_with_values('INSERT INTO accounts (id, username, name, password, join_date, image) VALUES ?', values, function(result) {
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

function convert_datetime(original) {
    let year = parseInt(original.substring(0, 4))
    let month = parseInt(original.substring(5, 7))
    let day = parseInt(original.substring(8, 10))
    let hour = parseInt(original.substring(11, 13))
    let minute = parseInt(original.substring(14, 16))
    return {
        year: year,
        month: month,
        day: day,
        hour: hour,
        minute: minute
    }
}

function query_account_data(username, call_back) {
    let values = [username]
    data.parse_query_with_values('SELECT * FROM accounts WHERE username = ?', values, function(result) {
        let account_data = result[0]
        if (account_data == undefined) {
            log.write('Invalid account query for username ' + username, 'ERROR')
        } else {
            assign_status_message(account_data)
            account_data.join_date = convert_datetime(account_data.join_date)
            result[0] = account_data
            call_back(result)
        }
    })
}

function assign_status_message(account_data) {
    if (account_data.status_level == 1) {
        account_data.status_message = 'Tester'
    } else if (account_data.status_level == 2) {
        account_data.status_message = 'Technician'
    } else if (account_data.status_level == 3) {
        account_data.status_message = 'Developer'
    }
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