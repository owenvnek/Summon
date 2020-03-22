let moment = require('moment-timezone')
let schedule = require('node-schedule')

let data = require('./data.js')
let account = require('./account.js')
let user = require('./user.js')
let notifications = require('./notifications.js')
let location = require('./location.js')

let SUMMON_MIN_TITLE_LENGTH = 1
let SUMMON_MAX_TITLE_LENGTH = 40

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
    return '\'' + constrain_digits(datetime.year, 4) +
    '-' + constrain_digits(datetime.month, 2) +
    '-' + constrain_digits(datetime.day, 2) + 
    ' ' + constrain_digits(datetime.hour, 2) + 
    ':' + constrain_digits(datetime.minute, 2) + 
    ':00\''
}

function query_create_summon(owner_username, description, datetime, location_id, call_back) {
    let datetime_str = create_datetime_string(datetime)
    let query = 'INSERT INTO summons (owner, title, location, datetime) VALUES (?, ' + datetime_str + ')'
    let values = [
        owner_username,
        description,
        location_id
    ]
    data.query_with_values(query, values, function() {
        data.parse_query('SELECT LAST_INSERT_ID()', function(result) {
            let id = result[0]['LAST_INSERT_ID()']
            call_back(id)
        })
    })
}

function query_add_membership(member_username, summon_id, call_back) {
    let query = 'INSERT INTO summons_membership (summon_id, username) VALUES (?)'
    let values = [
        summon_id,
        member_username
    ]
    data.query_with_values(query, values, call_back)
}

function notify_summon_created(socket) {
    socket.emit('summon_created', function() {

    })
}

function query_participants(summon_id, call_back) {
    let query = 'SELECT username FROM summons_membership WHERE summon_id = ?'
    let values = [
        summon_id
    ]
    data.parse_query_with_values(query, values, function(result) {
        if (result.length > 0) {
            let participants = []
            for (let i = 0; i < result.length; i++) {
                let membership_data = result[i]
                let username = membership_data["username"]
                account.query_account_data(username, function(account_data) {
                    participants.push(account_data[0])
                    if (participants.length >= result.length) {
                        call_back(participants)
                    }
                })
            }
        } else {
            call_back([])
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

function query_summon(summon_id, call_back) {
    let query = 'SELECT * FROM summons WHERE id = ?'
    let values = [
        summon_id
    ]
    let summon = {
        owner: "",
        title: "",
        id: 0,
        participants: [],
        datetime: {}
    }
    data.parse_query_with_values(query, values, function(result) {
        let summon_data = result[0]
        account.query_account_data(summon_data.owner, function(account_data) {
            let location_id = summon_data.location
            summon.owner = account_data[0]
            summon.title = summon_data.title
            summon.id = summon_data.id
            location.query_location(location_id, function(result) {
                if (result !== undefined) {
                    summon.location = result[0]
                }
                if (summon_data.datetime != null) {
                    summon.datetime = convert_datetime(summon_data.datetime)
                }
                query_participants(summon_id, function(participants) {
                    summon.participants = participants
                    call_back(summon)
                })
            })
        })
    })
}

function send_outgoing_summons(summons, source, socket) {
    for (summon in summons) {
        socket.emit('send_outgoing_summon', {
            source: source,
            summons: [summons[summon]]
        })
    }
}

function send_incoming_summons(summons, source, socket) {
    for (summon in summons) {
        socket.emit('send_incoming_summon', {
            source: source,
            summons: [summons[summon]]
        })
    }
}

function enqueue_summon_participants(context, summon) {
    let owner = summon.owner
    let name = owner.name
    let participants = summon.participants
    for (participant in participants) {
        let username = participants[participant].username
        notifications.send_notification_with_data(username, name + ' sent you a Summon', {
            summon_id: summon.id
        })
        if (user.check_if_user_active(context, username)) {
            let participant_user = user.get_active_user(context, username)
            let socket = participant_user.socket
            socket.emit('summon_enqueued')
        }
    }
}

function adjust_moment(datetime_moment) {
    let now = moment()
    let NewYork_tz_offset = moment.tz.zone("America/New_York").utcOffset(now); 
    let London_tz_offset = moment.tz.zone("Europe/London").utcOffset(now);
    let offset = (NewYork_tz_offset - London_tz_offset) / 60;
    return datetime_moment.add(-offset, 'hours')
}

function datetime_in_the_future(datetime) {
    let now = moment()
    let datetime_moment = moment(datetime.year + '-' + datetime.month + '-' + datetime.day + ' ' + datetime.hour + ':' + datetime.minute, 'YYYY-MM-DD HH:mm').tz('America/New_York')
    now = adjust_moment(now)
    if (datetime_moment.diff(now, 'minutes') <= 0) {
        return false
    }
    return true
}

function check_standards_for_summon_details(summon_data) {
    let title = summon_data.title
    let participant_count = summon_data.participants.length
    let datetime = summon_data.datetime
    if (title.length > SUMMON_MAX_TITLE_LENGTH || title.length < SUMMON_MIN_TITLE_LENGTH) {
        return {
            valid: false,
            reason: 'Titles must be within' + SUMMON_MIN_TITLE_LENGTH + ' and ' + SUMMON_MAX_TITLE_LENGTH + ' characters'
        }
    }
    if (participant_count < 1) {
        return {
            valid: false,
            reason: 'You need to add at least 1 participant'
        }
    }
    if (!datetime_in_the_future(datetime)) {
        return {
            valid: false,
            reason: 'You cannot schedule a summon for the past'
        }
    }
    return {
        valid: true,
        reason: ''
    }
}

function schedule_notification(username, datetime) {
    let date = new Date(datetime.year, datetime.month, datetime.day, datetime.hour, datetime.minute, 0, 0)
    let job = schedule.scheduleJob(date, function() {
        notifications.send_notification(username, 'A summon in your inbox is happening!')
    })
}

function create_summon(context, summon_data, socket) {
    let title = summon_data.title
    let owner = summon_data.owner
    let participants = summon_data.participants
    let datetime = summon_data.datetime
    let summon_location = summon_data.location
    let standard_response = check_standards_for_summon_details(summon_data)
    if (!standard_response.valid) {
        socket.emit('summon_creation_failed', {
            reason: standard_response.reason
        })
        return
    }
    location.query_save_location(summon_location, function(location_id) {
        query_create_summon(owner, title, datetime, location_id, function(summon_id) {
            let participant_counter = {
                count: 0
            }
            for (member_index in participants) {
                let member = participants[member_index]
                query_add_membership(member, summon_id, function() {
                    participant_counter.count++
                    if (participant_counter.count >= participants.length) {
                        notify_summon_created(socket)
                        query_summon(summon_id, function(summon) {
                            let owner_user = user.get_active_user(context, owner)
                            owner_user.outgoing_summon_queue.push(summon)
                            enqueue_summon_participants(context, summon)
                        })
                    }
                })
                //schedule_notification(member.username, datetime)
            }
        })
    })
}

function query_outgoing_summon_data(username, call_back) {
    let query = 'SELECT id FROM summons WHERE owner = ? AND datetime > CONVERT_TZ(NOW(), \'GMT\', \'EST\') ORDER BY datetime'
    let values = [username]
    data.parse_query_with_values(query, values, call_back)
}

function request_outgoing_summons(context, data, socket) {
    let username = data.username
    let source = data.source
    if (data.source === 'queue') {
        let request_user = user.get_active_user(context, username)
        let queue = request_user.outgoing_summon_queue
        send_outgoing_summons(queue, source, socket)
        request_user.outgoing_summon_queue = []
    } else if (data.source === 'all') {
        query_outgoing_summon_data(username, function(result) {
            let collector = {
                summons: [],
                remaining: result.length
            }
            for (let i = 0; i < result.length; i++) {
                let summon_data = result[i]
                let summon_id = summon_data.id
                query_summon(summon_id, function(summon) {
                    collector.summons.push(summon)
                    collector.remaining--
                    if (collector.remaining === 0) {
                        send_outgoing_summons(collector.summons, source, socket)
                    }
                })
            }
        })
    }
}

function query_incoming_summon_data(username, call_back) {
    let query = 'SELECT summon_id FROM summons_membership WHERE username = ? AND summon_id IN (SELECT id FROM summons WHERE datetime > CONVERT_TZ(NOW(), \'GMT\', \'EST\'))'
    let values = [username]
    data.parse_query_with_values(query, values, call_back)
}

function query_incoming_summon_data_min_id(username, min_summon_id, call_back) {
    let query = 'SELECT summon_id FROM summons_membership WHERE username = ? AND summon_id IN (SELECT id FROM summons WHERE datetime > CONVERT_TZ(NOW(), \'GMT\', \'EST\')) AND summon_id > ' + min_summon_id
    let values = [username]
    data.parse_query_with_values(query, values, call_back)
}

function query_summon_queue(username, call_back) {
    let query = 'SELECT * FROM summons_queue WHERE username = ?'
    let values = [username]
    data.parse_query_with_values(query, values, call_back)
}

function query_update_summon_queue(username, summon_id) {
    let query = 'REPLACE INTO summons_queue (username, summon_id) VALUES ?'
    let values = [
        username, summon_id
    ]
    data.query_with_values(query, [values], function() {

    })
}

function send_incoming_summons_data(result, username, source, socket) {
    let collector = {
        summons: [],
        remaining: result.length
    }
    let max_summon_id = 0
    for (let i = 0; i < result.length; i++) {
        let summon_data = result[i]
        let summon_id = summon_data.summon_id
        //console.log('sending a summon with id ' + summon_id)
        if (summon_id > max_summon_id) {
            max_summon_id = summon_id
        }
        query_summon(summon_id, function(summon) {
            collector.summons.push(summon)
            collector.remaining--
            if (collector.remaining === 0) {
                send_incoming_summons(collector.summons, source, socket)
            }
        })
        query_update_summon_queue(username, max_summon_id)
    }
}

function request_incoming_summons(context, summon_data, socket) {
    let username = summon_data.username
    let source = summon_data.source
    if (source === 'queue') {
        console.log('Got a queue request')
        query_summon_queue(username, function(result1) {
            let queue_index = 0
            if (result1.length > 0) {
                queue_index = result1[0].summon_id
            }
            if (queue_index == undefined) {
                queue_index = 0
            }
            query_incoming_summon_data_min_id(username, queue_index, function(result2) {
                send_incoming_summons_data(result2, username, source, socket)
            })
        })
    } else if (source === 'all') {
        query_incoming_summon_data(username, function(result) {
            send_incoming_summons_data(result, username, source, socket)
        })
    }
}

function query_delete_summon(summon_id, call_back) {
    data.query_with_values('DELETE FROM summons WHERE id = ?', [summon_id], function() {
        data.query_with_values('DELETE FROM summons_membership WHERE summon_id = ?', [summon_id], call_back)
    })
}

function delete_summon(summon_data, socket) {
    let summon_id = summon_data.summon_id
    query_delete_summon(summon_id, function() {
        socket.emit('summon_deleted')
    })
}

module.exports.create_summon = create_summon
module.exports.request_outgoing_summons = request_outgoing_summons
module.exports.request_incoming_summons = request_incoming_summons
module.exports.delete_summon = delete_summon
