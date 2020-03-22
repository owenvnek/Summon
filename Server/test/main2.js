let express = require('express')
let login = require('login')

let app = express()
let server = {
    
}

function create_context(req, res) {
    return {
        server: server,
        req: req,
        res: res
    }
}

function login(req, res) {
    let context = create_context(req, res)
    login.input(context)
}
