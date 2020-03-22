var mysql = require('mysql');
var fs = require('fs');

let object = {
    image: fs.readFileSync('drphil.png')
}

var mysql_server = mysql.createConnection({
  host: "summon-database-1.cvz7gyjlkulq.us-east-2.rds.amazonaws.com",
  user: "admin",
  password: "5!7^W6r7%KjPNB3JKmwqN2lWtO3e",
  database: "test"
});

function send_image() {
    mysql_server.query('INSERT INTO image_test SET ?', object, function(err,
        result) {
        console.log(result);
    });
}

function get_image() {
    mysql_server.query('SELECT image FROM image_test WHERE id = 5', function(err,
        result) {
        let image_data = result[0].image
        fs.writeFileSync('image_from_heaven.png', image_data)
    });
}

get_image()

 