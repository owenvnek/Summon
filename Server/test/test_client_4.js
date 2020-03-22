let io = require('socket.io-client');
let socket = io('http://localhost:3000');

socket.on('login', function(data) {
    console.log('Ive been logged in')
    console.log(data)
    socket.emit('thanks')
})