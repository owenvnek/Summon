let url = require('url')
let http = require('http')

let server = http.createServer((req, res) => {
    let parsedUrl = url.parse(req.url, true)
    if (parsedUrl.path == '/ping') {
        res.writeHead(200, { 'Content-Type': 'text/html' });
        res.write('PONG!')
        res.end()
    }
})
server.listen(3200)
console.log('Listening on http://localhost:3200')
