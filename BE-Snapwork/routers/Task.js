var router = require('express')();
var db = require('./DBConnect');


// Lấy danh sách công việc
router.get('/', function (req, res) {
    var query = 
    "SELECT Task.*, Project.projectName, Users.fullName " +
    "FROM Task " +
    "JOIN Project ON Task.projectID = Project.projectID " +
    "JOIN Users ON Task.userID = Users.userID";
    db.query(query, function (err, result) {
        if (err) throw err;
        res.status(200).json(result);
    });
});

var path = require('path');
module.exports = router;