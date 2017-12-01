var express = require('express');
var app = express();

app.get('/',function(req, res) {
   res.send('Hello Worldxxx'); 
});


var server = app.listen(3000,function() {
  var host = server.address().address;
  var port = server.address().port;

  console.log('Example app list at http://%s:%s',host,port);
});