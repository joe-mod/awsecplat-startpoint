

/**
 * JUST A DUMMY INDEX FILE TO CHECK IF NODE APP IS RUNNING IN THE CONTAINER
 */


const express = require('express');
const app = express();


app.get('/', function (req, res) {
  res.send('Request recieved, app is running!');
});
app.listen(3333, function () {
  console.log('Example app listening on port 3333!');
});