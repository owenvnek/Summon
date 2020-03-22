function verify_query(context) {
    let req = context.req
    let query = req.query
    let username = query.username
    return {
        username: username
    }
}

function input(context) {
    let parameters = verify_query(context)
    
}