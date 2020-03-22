let express = require('express')
let app = express()
app.get('/', (req, res) => {
  res.send('HEY!')
})
app.get('/tacos', (req, res) => {
  res.send('You wanna know about tacos? Fascinating')
})
app.get('/frickers', (req, res) => {
  res.send('frick off')
})
app.listen(3000, () => console.log('Server running on port 3000'))