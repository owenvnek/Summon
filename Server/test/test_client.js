let http = require('http');

http.get('http://ec2-52-15-46-109.us-east-2.compute.amazonaws.com:3000/login?username=niopullus', (resp) => {
  let data = '';

  // A chunk of data has been recieved.
  resp.on('data', (chunk) => {
    data += chunk;
  });

  // The whole response has been received. Print out the result.
  resp.on('end', () => {
    console.log(JSON.parse(data).explanation);
  });
}).on("error", (err) => {
  console.log("Error: " + err.message);
});