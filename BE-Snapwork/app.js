const express = require('express');
const app = express();
const path = require('path');
const cors = require('cors');
const morgan = require('morgan');
const cookieParser = require('cookie-parser');

app.use(morgan('dev'));
const port = 3000;
app.use(cors());
const bodyParser = require('body-parser');
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));
app.use(express.urlencoded({ extended: false }));
app.use(cookieParser());
app.use(express.static(path.join(__dirname, 'public')));

var projectRouter = require('./routers/Project');
app.use('/project', projectRouter);

var taskRouter = require('./routers/Task');
app.use('/task', taskRouter);

var taskRouter = require('./routers/User');
app.use('/user', taskRouter);

var taskRouter = require('./routers/Comment');
app.use('/comment', taskRouter);

app.listen(port, () => {
  console.log(`Server is running at http://localhost:${port}`);
});
