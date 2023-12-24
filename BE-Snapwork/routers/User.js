var router = require('express')();
var db = require('./DBConnect');

//Tạo roles
const util = require('util');
const query = util.promisify(db.query).bind(db);
router.post('/addrole', async (req, res) => {
  try {
    const rolename = req.body.roleName;
    const result = await query("INSERT INTO Roles (roleName) VALUES (?)", [rolename]);
    res.json(result);
  } catch (error) {
    console.error('Lỗi truy vấn:', error.message);
    res.status(500).json({ error: 'Lỗi truy vấn', details: error.message });
  }
});
// Đăng ký người dùng
const bcrypt = require('bcrypt');
router.post('/register', async (req, res) => {
  try {
    const { picture, fullName, password, emailAddress, phoneNumber, roleID } = req.body;
    const saltRounds = 10;
    const passwordHash = await bcrypt.hash(password, saltRounds);
    const query = "INSERT INTO Users (picture, fullName, passwordHash, emailAddress, phoneNumber, roleID, lastLogin, createdDate) VALUES (?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)";
    db.query(query, [picture, fullName, passwordHash, emailAddress, phoneNumber, roleID], (err, result) => {
      if (err) {
        console.error('Error executing query:', err);
        res.status(500).json({ success: false, message: 'Error executing query', details: err.message });
      } 
      else {
        res.json({ success: true, message: 'User registered successfully', userID: result.insertId });
      }
      });
    } 
    catch (error) {
      console.error('Error during registration:', error);
      res.status(500).json({ success: false, message: 'Error during registration', details: error.message });
    }
});
// Đăng nhập người dùng và tạo token JWT
const jwt = require('jsonwebtoken');
router.post('/login', async (req, res) => {
  try {
    const { emailAddress, password } = req.body;
    const query = "SELECT * FROM Users WHERE emailAddress = ?";
    db.query(query, [emailAddress], async (err, results) => {
      if (err) {
        console.error('Error executing query:', err);
        res.status(500).json({ success: false, message: 'Error executing query', details: err.message });
      } else {
        if (results.length > 0) {
          const user = results[0];
          const passwordMatch = await bcrypt.compare(password, user.passwordHash);
          if (passwordMatch) {
            const token = jwt.sign({ userID: user.userID, emailAddress: user.emailAddress }, 'your-secret-key', { expiresIn: '1h' });
            const userData = {
              userID: user.userID,
              picture: user.picture,
              fullName: user.fullName,
              emailAddress: user.emailAddress,
              phoneNumber: user.phoneNumber,
              roleID: user.roleID,
              lastLogin: user.lastLogin,
              createdDate: user.createdDate,
            };
            res.json({ success: true, message: 'Login successful', token, user: userData, userID: user.userID});
          } else {
            res.status(401).json({ success: false, message: 'Incorrect email or password' });
          }
        } else {
          res.status(401).json({ success: false, message: 'Incorrect email or password' });
        }
      }
    });
  } catch (error) {
    console.error('Error during login:', error);
    res.status(500).json({ success: false, message: 'Error during login', details: error.message });
  }
});
router.get('/userLogin/:userID', (req, res) => {
  const userId = req.params.userID;

  const userLoginQuery = `
    SELECT Users.*, Roles.roleName
    FROM Users
    JOIN Roles ON Users.roleID = Roles.roleID
    WHERE Users.userID = ?`;
  db.query(userLoginQuery, [userId], (userLoginErr, userLoginResult) => {
    try {
      if (userLoginErr) {
        throw new Error(`Lỗi thực hiện truy vấn UserLogin: ${userLoginErr.message}`);
      }
      res.json({ userLogin: userLoginResult });
    } catch (userLoginCatchErr) {
      res.status(500).json({ error: 'Lỗi truy vấn UserLogin', details: userLoginCatchErr.message });
    }
  });
});

// Lấy danh sách roles
router.get('/roles',function(req,res){
  var query = "select * from Roles";
  db.query(query,function(err,result){
    if(err) throw err;
    res.status(200).json(result);
  });
})

router.get('/', function(req, res) {
    var query = ` SELECT U.userID, U.picture, U.fullName, PT.teamID, PT.teamName FROM Users U INNER JOIN Team PT ON U.userID = PT.teamID `;
    db.query(query, function(err, result) {
    if (err) throw err;
    res.status(200).json(result);
    });
});
  
router.get('/get-user/:id', function(req, res){
    var query = 'select * from Users where userID = '+ req.params.id ;
    db.query(query, function(err, result) {
      if(err) res.status(500).send('Loi cau lenh truy van');
      res.json(result);
    })
});

var path = require('path');
module.exports = router;