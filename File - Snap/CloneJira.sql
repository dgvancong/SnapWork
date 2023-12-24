CREATE DATABASE CloneJira;
USE CloneJira;

CREATE TABLE Roles (
    roleID INT AUTO_INCREMENT PRIMARY KEY,
    roleName VARCHAR(20) UNIQUE
);
INSERT INTO Roles (roleID,roleName) 
VALUES 
    (1,'Admin'),
    (2,'Developer'),
    (3,'Tester'),
    (4,'Project Manager');

CREATE TABLE Users (
    userID INT AUTO_INCREMENT PRIMARY KEY, -- ID tự động tăng cho mỗi người dùng
    picture NVARCHAR(255), -- Dữ liệu nhị phân hình ảnh người dùng (ví dụ: avatar), có thể là NULL
    fullName NVARCHAR(150) UNIQUE, -- Tên đầy đủ của người dùng, độ dài tối đa 150 ký tự, duy nhất
    passwordHash VARCHAR(255), -- Giá trị đã được băm của mật khẩu người dùng để bảo mật
    emailAddress NVARCHAR(255) UNIQUE, -- Địa chỉ email của người dùng, duy nhất
    phoneNumber VARCHAR(11), -- Số điện thoại của người dùng (điều chỉnh độ dài và định dạng)
    roleID INT, -- Khóa ngoại liên kết với vai trò người dùng trong bảng Roles
    lastLogin DATETIME, -- Thời điểm đăng nhập cuối cùng của người dùng
    createdDate DATETIME, -- Thời điểm tạo tài khoản người dùng
    isDeleted BIT DEFAULT 0, -- Cột xác định trạng thái xóa mềm, mặc định là chưa xóa
    FOREIGN KEY (roleID) REFERENCES Roles(roleID)ON DELETE CASCADE -- Liên kết với vai trò người dùng
);
INSERT INTO Users (picture, fullName, passwordHash, emailAddress, phoneNumber, roleID, lastLogin, createdDate)
VALUES 
    (NULL, N'Đồng Văn Công', '123', 'john.doe@example.com', '0334624356', 2, '2023-11-30 08:00:00', '2023-11-30 08:00:00');
    
CREATE TABLE Notifications (
    notificationID INT AUTO_INCREMENT PRIMARY KEY, -- ID tự động tăng cho mỗi thông báo
    userID INT, -- Khóa ngoại liên kết với Users
    message NVARCHAR(4000), -- Nội dung thông báo
    isRead BIT DEFAULT 0, -- Cột xác định trạng thái đã đọc hay chưa, mặc định là chưa đọc
    createdDate DATETIME, -- Thời điểm tạo thông báo
    isDeleted BIT DEFAULT 0, -- Cột xác định trạng thái xóa mềm, mặc định là chưa xóa
    FOREIGN KEY (userID) REFERENCES Users(userID)ON DELETE CASCADE
);
INSERT INTO Notifications (userID, message, createdDate)
VALUES 
    (1, N'New task assigned to you.', '2023-11-30'),
    (2, N'Project deadline approaching.', '2023-11-30'),
    (3, N'Your comment received a reply.', '2023-12-01');
    
CREATE TABLE Team (
    teamID INT AUTO_INCREMENT PRIMARY KEY, -- ID tự động tăng cho mỗi nhóm
    teamName NVARCHAR(200), -- Tên của nhóm
    createdDate DATETIME, -- Thời điểm tạo nhóm
    isDeleted BIT DEFAULT 0 -- Cột xác định trạng thái xóa mềm, mặc định là chưa xóa
);
INSERT INTO Team (teamName, createdDate)
VALUES 
    (N'Development Team', '2023-11-30 10:00:00'),
    (N'Marketing Team', '2023-11-30 11:30:00'),
    (N'Sales Team', '2023-12-01 14:00:00');
    
CREATE TABLE TeamMembers (
    teamMemberID INT AUTO_INCREMENT PRIMARY KEY, -- ID tự động tăng cho mỗi thành viên trong nhóm
    teamID INT, -- Khóa ngoại liên kết với Team
    userID INT, -- Khóa ngoại liên kết với Users
    roleInTeam NVARCHAR(50), -- Vai trò của thành viên trong nhóm
    joinDate DATETIME, -- Thời điểm tham gia nhóm
    isDeleted BIT DEFAULT 0, -- Cột xác định trạng thái xóa mềm, mặc định là chưa xóa
    FOREIGN KEY (teamID) REFERENCES Team(teamID)ON DELETE CASCADE,
    FOREIGN KEY (userID) REFERENCES Users(userID)ON DELETE CASCADE
);
INSERT INTO TeamMembers (teamID, userID, roleInTeam, joinDate)
VALUES 
    (1, 1, N'Developer', '2023-11-30 10:00:00'),
    (1, 2, N'Project Manager', '2023-11-30 11:30:00'),
    (2, 3, N'Sales Representative', '2023-12-01 14:00:00');
    
CREATE TABLE ProjectTeam (
    projectID INT,
    teamID INT,
    PRIMARY KEY (projectID, teamID), -- Khóa chính là sự kết hợp của projectID và teamID
    isDeleted BIT DEFAULT 0, -- Cột xác định trạng thái xóa mềm, mặc định là chưa xóa
    FOREIGN KEY (projectID) REFERENCES Project(projectID)ON DELETE CASCADE,
    FOREIGN KEY (teamID) REFERENCES Team(teamID)ON DELETE CASCADE
);
INSERT INTO ProjectTeam (projectID, teamID)
VALUES 
    (1, 1),
    (2, 1);
    
CREATE TABLE Task (
    taskID INT AUTO_INCREMENT PRIMARY KEY, -- ID tự tăng cho từng công việc
    projectID INT, -- Khóa ngoại liên kết với bảng Project
    taskType VARCHAR(100), -- Loại công việc (ví dụ: "Development", "Testing", "Design")
    summary NVARCHAR(4000), -- Miêu tả ngắn gọn về công việc
    userID INT, -- Khóa ngoại liên kết với bảng Users, xác định người được giao công việc
    status VARCHAR(20), -- Trạng thái công việc (ví dụ: "To Do", "In Progress", "Done")
    createdDate DATETIME, -- Ngày tạo công việc
    endDate DATETIME, -- Ngày bắt đầu công việc
    priority INT, -- Ưu tiên công việc
	description TEXT, -- Mô tả chi tiết về công việc
    FOREIGN KEY (projectID) REFERENCES Project(projectID) ON DELETE CASCADE, -- Liên kết với dự án
    FOREIGN KEY (userID) REFERENCES Users(userID) ON DELETE CASCADE -- Liên kết với người được giao công việc
);
INSERT INTO Task (projectID, taskType, summary, userID, status, createdDate, endDate, priority, description)
VALUES 
    (1, 'Development', 'Implement feature A', 1, 'To Do', '2023-11-30 09:00:00', '2023-12-01', 1 , 'Develop the new feature according to specifications.'),
	(1, 'Testing', 'Implement feature A', 2, 'In Progress', '2023-11-30 09:00:00', '2023-12-01', 2 , 'Develop the new feature according to specifications.'),
	(1, 'Design', 'Implement feature A', 2, 'To Do', '2023-11-30 09:00:00', '2023-12-01', 3 ,'Develop the new feature according to specifications.');
    
CREATE TABLE TaskDetails (
    taskID INT AUTO_INCREMENT PRIMARY KEY, -- Khóa chính là taskID
    taskDescription TEXT, -- Mô tả chi tiết về nhiệm vụ
    actualHoursSpent INT, -- Số giờ thực tế đã dành cho nhiệm vụ
    taskManagerID INT, -- Khóa ngoại liên kết với người quản lý nhiệm vụ trong bảng Users
    FOREIGN KEY (taskID) REFERENCES Task(taskID)ON DELETE CASCADE,
    FOREIGN KEY (taskManagerID) REFERENCES Users(userID) ON DELETE CASCADE
);
-- Chèn thông tin chi tiết về nhiệm vụ vào bảng TaskDetails
INSERT INTO TaskDetails (taskID, taskDescription, actualHoursSpent, taskManagerID)
VALUES 
    (4, 'Front-end development for homepage', 15, 1),
    (1, 'Create marketing materials for campaign', 25, 3),
    (1, 'Database optimization', 35, 1);

CREATE TABLE TaskAssignment (
    taskAssignmentID INT AUTO_INCREMENT PRIMARY KEY, -- ID tự tăng cho mỗi phân công công việc
    taskID INT, -- Khóa ngoại liên kết với bảng Task, xác định công việc được phân công
    assigneeID INT, -- Khóa ngoại liên kết với bảng Users, xác định người được phân công công việc
    hoursSpent INT, -- Số giờ đã dành cho công việc
    completionDate DATETIME, -- Ngày và giờ hoàn thành công việc
    note TEXT, -- Ghi chú về công việc (nếu có)
    status VARCHAR(20), -- Trạng thái của công việc (ví dụ: "In Progress", "Completed")
    FOREIGN KEY (taskID) REFERENCES Task(taskID)ON DELETE CASCADE, -- Liên kết với công việc được phân công
    FOREIGN KEY (assigneeID) REFERENCES Users(userID)ON DELETE CASCADE -- Liên kết với người được phân công công việc
);
-- Chèn một số phân công công việc vào bảng TaskAssignment
INSERT INTO TaskAssignment (taskID, assigneeID, hoursSpent, completionDate, note, status)
VALUES 
    (4, 1, 8, '2023-11-30 14:30:00', 'Cần hoàn thành trước cuối tháng', 'In Progress'),
    (1, 3, 5, '2023-12-05 10:45:00', 'Gấp, cần kiểm tra kỹ lưỡng', 'Not Started'),
    (7, 2, 10, '2023-12-10 16:00:00', 'Dành nhiều thời gian cho công việc này', 'Completed');
    
CREATE TABLE Comments (
    commentID INT AUTO_INCREMENT PRIMARY KEY, -- ID tự động tăng cho mỗi comment
    taskID INT, -- Khóa ngoại liên kết với Task
    userID INT, -- Khóa ngoại liên kết với Users
    commentText TEXT, -- Nội dung của comment
    attachmentData VARBINARY(4000), -- Dữ liệu nhị phân đính kèm (ví dụ: file đính kèm)
    createdDate DATETIME, -- Thời điểm tạo comment
    isDeleted BIT DEFAULT 0, -- Cột xác định trạng thái xóa mềm, mặc định là chưa xóa
    FOREIGN KEY (taskID) REFERENCES Task(taskID)ON DELETE CASCADE,
    FOREIGN KEY (userID) REFERENCES Users(userID)ON DELETE CASCADE
);
INSERT INTO Comments (taskID, userID, commentText, attachmentData, createdDate)
VALUES 
    (1, 1, 'Great progress on this task!', NULL, '2023-11-30 10:00:00'),
    (2, 1, 'I have a question about the requirements.', NULL, '2023-11-30 11:30:00');
    
CREATE TABLE Project (
    projectID INT AUTO_INCREMENT PRIMARY KEY,
    projectName NVARCHAR(200),
    projectKey VARCHAR(10),
	progress INT,
    createdDate DATETIME,
    endDate DATETIME
);
INSERT INTO Project (projectName, projectKey, progress, createdDate, endDate)
VALUES ('Snapwork', 'PA123', 20, '2023-01-01 10:00:00', '2023-06-30 18:00:00');
INSERT INTO Project (projectName, projectKey, progress, createdDate, endDate)
VALUES ('Jira', 'PB456', 10, '2023-02-15 14:30:00', '2023-08-31 20:45:00');

CREATE TABLE ProjectDetails (
    projectID INT AUTO_INCREMENT PRIMARY KEY, -- Khóa chính là projectID
    projectDescription TEXT, -- Mô tả chi tiết về dự án
    clientContactName NVARCHAR(150), -- Tên người liên hệ của khách hàng
    clientContactEmail NVARCHAR(255), -- Địa chỉ email của người liên hệ của khách hàng
    clientContactPhone VARCHAR(15), -- Số điện thoại của người liên hệ của khách hàng
    teamID INT, -- Khóa ngoại liên kết với người quản lý dự án trong bảng Users
	userID INT,
    FOREIGN KEY (projectID) REFERENCES Project(projectID) ON DELETE CASCADE,
    FOREIGN KEY (teamID) REFERENCES Team(teamID)ON DELETE CASCADE,
	FOREIGN KEY (userID) REFERENCES Users(userID)ON DELETE CASCADE
);
INSERT INTO ProjectDetails (projectID, projectDescription, clientContactName, clientContactEmail, clientContactPhone, teamID, userID)
VALUES (1, 'Detailed description of Project A', 'Đồng Văn Công', 'john.doe@example.com', '123-456-7890', 1, 1);
INSERT INTO ProjectDetails (projectID, projectDescription, clientContactName, clientContactEmail, clientContactPhone, teamID, userID)
VALUES (1, 'Detailed description of Project B', 'Nguyễn Xuân Bình', 'jane.smith@example.com', '987-654-3210', 2, 2);
