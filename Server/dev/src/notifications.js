let apn = require('apn')

let data = require('./data.js')

let options = {
    token: {
        key: "keys/AuthKey_8F8B2U52Q4.p8",
        keyId: "8F8B2U52Q4",
        teamId: "A33SP8Q4D7"
    },
    production: false
}
let apnProvider = new apn.Provider(options)

function query_device_token(username, call_back) {
    data.parse_query_with_values('SELECT token FROM device_tokens WHERE username = ?', [username], call_back)
}

function query_save_device_token(username, token) {
    data.query_with_values('INSERT INTO device_tokens (username, token) VALUES (?)', [username, token], function() {

    })
}

function query_update_device_token(username, token) {
    data.query_with_values('UPDATE device_tokens SET token = ? WHERE username = \'' + username + '\'', token, function() {
        
    })
}

function query_delete_existing_token_instances(token, call_back) {
    data.query_with_values('DELETE FROM device_tokens WHERE token = ?', [token], call_back)
}

function check_device_token(username, device_token) {
    data.query_existence('device_tokens', 'username', username, function(existence) {
        if (existence) {
            query_device_token(username, function(result) {
                let token = result[0].token
                if (token !== device_token) {
                    query_delete_existing_token_instances(token, function() {
                        query_update_device_token(username, device_token)
                    })
                }
            })
        } else {
            query_delete_existing_token_instances(device_token, function() {
                query_save_device_token(username, device_token)
            })
        }
    })

}

function send_notification_with_data(username, text, notification_data) {
    data.query_existence('device_tokens', 'username', username, function(existence) {
        if (existence) {
            query_device_token(username, function(result) {
                let note = new apn.Notification()
                let token = result[0].token
                note.expiry = Math.floor(Date.now() / 1000) + 3600 // Expires 1 hour from now.
                note.badge = 1
                note.sound = "default"
                note.alert = text
                note.payload = {
                    "aps": {
                    "alert": text,
                    "sound": "default"
                    }
                }
                for (let [key, value] of Object.entries(notification_data)) {
                    note.payload[key] = value
                }
                note.topic = "com.gmail.niopullus.Summon" //DO NOT FING CHANGE THIS
                apnProvider.send(note, token).then((result) => {
                    // see documentation for an explanation of result
                })
            })
        }
    })
}

function send_notification(username, text) {
    send_notification_with_data(username, text, {})
}

function remove_deivce_token(token) {
    data.query_with_values('DELETE FROM device_tokens WHERE token = ?', [token], function() {

    })
}

function remove_device_token_for_username(username) {
    data.query_with_values('DELETE FROM device_tokens WHERE username = ?', [username], function() {
        
    })
}

module.exports.check_device_token = check_device_token
module.exports.send_notification = send_notification
module.exports.send_notification_with_data = send_notification_with_data
module.exports.remove_deivce_token = remove_deivce_token
module.exports.remove_device_token_for_username = remove_device_token_for_username