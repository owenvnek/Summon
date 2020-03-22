let url = require('url')
let http = require('http')

let server = http.createServer((req, res) => {
    let parsedUrl = url.parse(req.url, true)
    if (parsedUrl.path == '/health_check') {
        res.writeHead(200, { 'Content-Type': 'text/html' });
        res.write('OK')
        res.end()
    }
})
server.listen(3100)
console.log('Listening on http://localhost:3100')
