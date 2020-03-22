let express = require('express');
let http = require('http')
let socket_io = require('socket.io')
let fs = require('fs')

let app = express();
let server = http.Server(app)
let io = socket_io(server)
/**
app.get('/', function(req, res) {
    res.sendfile('index.html')
});
 */
//Whenever someone connects this gets executed
io.on('connection', function(socket) {
    console.log('A user connected');

    setTimeout(function() {
        //Sending an object when emmiting an event
        socket.emit('login', {event_details: "chicken is good"})
    }, 500);

    //Whenever someone disconnects this piece of code executed
    socket.on('disconnect', function () {
        console.log('A user disconnected');
    });

    socket.on('thanks', function() {
        console.log('awww, he said thanks')
    })
});

server.listen(3000, function() {
    console.log('listening on *:3000');
});