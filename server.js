require('dotenv').config();
const express = require('express');
const http = require('http');
const { Server } = require('socket.io');
const mongoose = require('mongoose');
const cors = require('cors');

const app = express();
const server = http.createServer(app);

const io = new Server(server, {
  cors: { origin: '*' }
});

app.use(cors());
app.use(express.json());

mongoose.connect('mongodb://127.0.0.1:27017/solo-chat')
  .then(() => console.log("DB Connected"));

const Message = mongoose.model('Message', {
  room: String,
  username: String,
  message: String,
  time: String
});

let users = {};

io.on('connection', (socket) => {

  socket.on('join', ({ username }) => {
    users[socket.id] = username;
    io.emit('online', Object.values(users));
  });

  socket.on('joinRoom', (room) => {
    socket.join(room);
  });

  socket.on('chatMessage', async (data) => {
    await Message.create(data);
    io.to(data.room).emit('message', data);
  });

  socket.on('disconnect', () => {
    delete users[socket.id];
    io.emit('online', Object.values(users));
  });
});

server.listen(5000, () =>
  console.log("Server running on http://localhost:5000")
);
