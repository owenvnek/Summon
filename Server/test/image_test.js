var mysql = require('mysql');
var fs = require('fs');

function getByteArray(filePath){
    let fileData = fs.readFileSync(filePath).toString('base64');
    let result = ""
    for (var i = 0; i < fileData.length; i++)
      result += fileData[i]
    return result;
}

data_result = getByteArray('drphil.png')

var mysql_server = mysql.createConnection({
  host: "summon-database-1.cvz7gyjlkulq.us-east-2.rds.amazonaws.com",
  user: "admin",
  password: "5!7^W6r7%KjPNB3JKmwqN2lWtO3e",
  database: "test"
});

function query_with_values(line, values, call_back) {
  mysql_server.query(line, [values], function(err, result) {
      if (err) {
          throw err
      }
      call_back(result)
  })
}

function parse_query(line, call_back) {
  mysql_server.query(line, function(err, result, fields) {
      if (err) {
          throw err
      }
      try {
          let parsed_results = []
          for (let i = 0; i < result.length; i++) {
              let parsed_data = JSON.parse(JSON.stringify(result[i]))
              parsed_results.push(parsed_data)
          }
          call_back(parsed_results)
      } catch (e) {
          console.log('Failed to parse: ' + result[0] + ' (' + JSON.stringify(result[0]) + ')')
          throw e
      }
  })
}

function parse_query_with_values(line, values, call_back) {
  mysql_server.query(line, [values], function(err, result) {
      if (err) {
          throw err
      }
      try {
          let parsed_data = JSON.parse(JSON.stringify(result[0]))
          call_back(parsed_data)
      } catch (e) {
          console.log('Failed to parse: ' + result[0] + ' (' + JSON.stringify(result[0]) + ')')
          throw e
      }
  })
}

function query_existence(table, variable, value, call_back) {
  parse_query_with_values('SELECT EXISTS(SELECT * FROM ' + table + ' WHERE ' + variable + ' = ?)', value, function(result) {
      console.log('I got ' + result)
      let key = Object.keys(result[0])
      let existence = result[key] == 1
      call_back(existence)
  })
}

mysql_server.connect(function(err) {
  
})

function test1() {
  let values = [data_result]
  query_with_values('INSERT INTO image_test (image) VALUES (?)', values, function(){
    console.log('doneyy')
  })
}

function test2() {
  parse_query('SELECT image FROM image_test WHERE id = 4', function(result) {
    let image_data = result[0].image.data
    fs.createWriteStream('philly.png').write(Buffer.from(image_data));
  })
}

test2()
