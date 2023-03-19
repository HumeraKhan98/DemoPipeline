'use strict'

var express = require('express');

var app = express()

const port = 3000

app.get('/', function(req, res){
  res.send('Hello World on 19th of March!');
});

app.listen(3000, () => {
  console.log('Express started on port 3000');
});
