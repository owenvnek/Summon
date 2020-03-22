function get_active_user(context, username) {
    return context.active_users[username]
}

function add_active_user(context, username, user) {
    context.active_users[username] = user
}

function remove_active_user(context, username) {
    delete context.active_users[username]
}

function check_if_user_active(context, username) {
    return username in context.active_users
}

/**
function notify_created_summon(summon_id) {
    let summon = get_summon(summon_id)
    let participants = summon.participants
    for (let i = 0; i < participants.length; i++) {
        let participant = participants[i]
        if (check_if_user_active(participant)) {
            let user = get_active_user(participant)
            let socket = user.socket
            socket.emit('new_summon')
        }
    }
}
*/

module.exports.get_active_user = get_active_user
module.exports.add_active_user = add_active_user
module.exports.remove_active_user = remove_active_user
module.exports.check_if_user_active = check_if_user_active
//module.exports.notify_created_summon = notify_created_summon