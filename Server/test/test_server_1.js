let express = require('express')
let app = express()
let responses = []

function tell_all(req, res) {
    responses.push(res)
    for (let i = 0; i < responses.length; i++) {
        responses[i].send("Chicken " + responses.length)
    }
}

app.get('/tell_all', tell_all)
app.listen(3000, () => console.log('Server running on port 3000'))

