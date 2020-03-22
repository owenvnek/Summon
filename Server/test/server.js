function add_connection(context) {
    let server = context.server
    
}

function remove_connection(context) {

}

function create_server() {
    return {
        connections: {},
        add_connection: add_connection,
        remove_connection: remove_connection
    }
}