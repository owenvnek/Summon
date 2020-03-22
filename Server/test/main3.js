let express = require('express')

let app = express()
let app_context = {
  user_id: 0,
  users: {},
  username_lookups: {}
}

function assign_user_id() {
  let id = app_context.user_id
  app_context.userID++
  return id
}

function get_user(user_id) {
  return app_context.users[user_id]
}

function get_username(user_id) {
  console.log(app_context.users)
  let user = app_context.users[user_id]
  return user.username
}

function lookup_username(username) {
  return app_context.username_lookups[username].user_id
}

function add_user(user) {
  app_context.users[user.user_id] = user
}

function add_username_lookup(username_lookup) {
  app_context.username_lookups[username_lookup.username] = username_lookup.user_id
}

function notify_of_summon(target_username) {
  let user_id = lookup_username(target_username)
  let user = get_user(user_id)
  let res = user.res
  res.send('You got a summon')
}

function login(req, res) {
  let query = req.query
  let username = query.username
  let user_id = assign_user_id()
  let user = {
    res: res,
    user_id: user_id,
    username: username,
    summons: []
  }
  let username_lookup = {
    username: username,
    user_id: user_id
  }
  add_username_lookup(username_lookup)
  res.socket.locals = {
    chicken: "tacozzz"
  }
  res.socket.locals.userID = user_id
  add_user(user)
  console.log('assignment check')
  console.log(res.socket)
  res.send('logged you in')
}

function create_summon(req, res) {
  let query = req.query
  let description = query.description
  let time = query.time
  let target_username = query.target_username
  let author_username = get_username(res.socket.userID)
  let target_id = lookup_username(target_username)
  let target_user = get_user(target_id)
  let summon = {
    description: description,
    time: time,
    author_username: author_username,
    target_username: target_username
  }
  target_user.summons.push(summon)
  notify_of_summon(target_username)
  res.send('created the summon')
}

function get_user_id(req, res) {
  console.log('get check')
  console.log(res.socket)
  let user_id = res.socket.locals.userID
  res.send('your user id is ' + user_id)
}

function get_incoming_summons(req, res) {

}

function get_outgoing_summons(req, res) {

}

app.get('/login', login)
app.get('/create_summon', create_summon)
app.get('/get_user_id', get_user_id)
app.get('/get_incoming_summons', get_incoming_summons)
app.get('/get_outgoing_summons', get_outgoing_summons)
app.listen(3000, () => console.log('Server running on port 3000'))