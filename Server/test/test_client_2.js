let http = require('http')

function buffer_as_string(buffer) {
    return buffer.toString()
}

function process_res(res, handler) {
    var bodyChunks = [];
    res.on('data', function(chunk) {
      bodyChunks.push(chunk);
    }).on('end', function() {
      var body = Buffer.concat(bodyChunks);
      handler(body)
    })
}

function send_request(path, handler) {
    let options = {
        host: 'ec2-52-15-46-109.us-east-2.compute.amazonaws.com',
        port: 3000,
        path: path,
        method: 'GET'
    }
    let req = http.get(options, function(res) {
        process_res(res, handler)
    })
    req.on('error', function(e) {
        console.log('ERROR: ' + e.message);
    })
}

function request_user_id() {
    send_request('/get_user_id', function(buffer) {
        let line = buffer_as_string(buffer)
        console.log(line)
    })
}

function login() {
    send_request('/login?username=niopullus', function(buffer) {
        let line = buffer_as_string(buffer)
        console.log(line)
        if (line === 'logged you in') {
            request_user_id()
        }
    })
}

login()

