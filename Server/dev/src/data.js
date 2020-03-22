let mysql = require('mysql')
let log = require('./log.js')

var mysql_server

function create_server() {
    mysql_server = mysql.createConnection({
        host: "summon-database-1.cvz7gyjlkulq.us-east-2.rds.amazonaws.com",
        user: "admin",
        password: "5!7^W6r7%KjPNB3JKmwqN2lWtO3e",
        database: "summon"
    })
    mysql_server.connect(function(err) {
        if(err) {
          log.write('Failed to connect to MYSQL DB', 'ERROR')
          setTimeout(handleDisconnect, 2000)
        }
    })
    mysql_server.on('error', function(err) {
        console.log('db error', err)
        if(err.code === 'PROTOCOL_CONNECTION_LOST') {
          create_server()
        } else {
          throw err
        }
    })
}

function query(line, call_back) {
    mysql_server.query(line, function(err, result, fields) {
        if (err) {
            throw err
        }
        call_back(result)
    })
}

function query_with_values(line, values, call_back) {
    mysql_server.query(line, [values], function(err, result) {
        if (err) {
            throw err
        }
        call_back(result)
    })
}

function query_with_object(line, object, call_back) {
    mysql_server.query(line, object, function(err, result) {
        if (err) {
            throw err
        }
        call_back(result)
    })
}

function parse_query(line, call_back) {
    mysql_server.query(line, function(err, result, fields) {
        if (err) {
            throw err
        }
        try {
            let parsed_results = []
            for (let i = 0; i < result.length; i++) {
                let parsed_data = JSON.parse(JSON.stringify(result[i]))
                parsed_results.push(parsed_data)
            }
            call_back(parsed_results)
        } catch (e) {
            console.log('Failed to parse: ' + result[0] + ' (' + JSON.stringify(result[0]) + ')')
            throw e
        }
    })
}

function parse_query_with_values(line, values, call_back) {
    mysql_server.query(line, [values], function(err, result) {
        if (err) {
            throw err
        }
        try {
            let parsed_results = []
            for (let i = 0; i < result.length; i++) {
                let parsed_data = JSON.parse(JSON.stringify(result[i]))
                parsed_results.push(parsed_data)
            }
            call_back(parsed_results)
        } catch (e) {
            console.log('Failed to parse: ' + result[0] + ' (' + JSON.stringify(result[0]) + ')')
            throw e
        }
    })
}

function parse_query_with_object(line, object, call_back) {
    mysql_server.query(line, object, function(err, result) {
        if (err) {
            throw err
        }
        try {
            let parsed_results = []
            for (let i = 0; i < result.length; i++) {
                let parsed_data = JSON.parse(JSON.stringify(result[i]))
                parsed_results.push(parsed_data)
            }
            call_back(parsed_results)
        } catch (e) {
            console.log('Failed to parse: ' + result[0] + ' (' + JSON.stringify(result[0]) + ')')
            throw e
        }
    })
}

function query_existence(table, variable, value, call_back) {
    let line = 'SELECT EXISTS(SELECT * FROM ' + table + ' WHERE ' + variable + ' = ?)'
    parse_query_with_values(line, value, function(result) {
        let key = Object.keys(result[0])
        let existence = result[0][key] == 1
        call_back(existence)
    })
}

function query_existence_conditions(table, conditions, call_back) {
    let query = 'SELECT EXISTS(SELECT * FROM ' + table + ' WHERE '
    for (let i = 0; i < conditions.length; i++) {
        let condition = conditions[i]
        let variable = condition.variable
        let value = condition.value
        query += variable + ' = \'' + value + '\''
        if (i !== conditions.length - 1) {
            query += ' AND '
        }
    }
    query += ')'
    parse_query(query, function(result) {
        let key = Object.keys(result[0])[0]
        let existence = result[0][key] == 1
        call_back(existence)
    })
}

function stop() {
    mysql_server.close()
}

create_server()

module.exports.query = query
module.exports.query_with_values = query_with_values
module.exports.query_with_object = query_with_object
module.exports.parse_query = parse_query
module.exports.parse_query_with_values = parse_query_with_values
module.exports.parse_query_with_object = parse_query_with_object
module.exports.query_existence = query_existence
module.exports.query_existence_conditions = query_existence_conditions
module.exports.stop = stop