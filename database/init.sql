-- ============================================================================
-- Smart Campus Database Initialization Script (v4 Schema)
-- ============================================================================
-- RESPONSIBILITY:
-- Executing this script on an empty MySQL server will rebuild the entire 
-- organizational architecture and automatically populate it with the mock data 
-- required to successfully demonstrate the Viva application lifecycle.
-- ============================================================================

CREATE DATABASE IF NOT EXISTS smart_campus_db;
USE smart_campus_db;

-- ----------------------------------------------------------------------------
-- 1. Users Table
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS users (
    id VARCHAR(50) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    role ENUM('student', 'staff') NOT NULL,
    address TEXT,
    emergencyName TEXT,
    emergencyPhone TEXT,
    profilePic TEXT
);

-- ----------------------------------------------------------------------------
-- 2. Timetable Table
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS timetable (
    id VARCHAR(50) PRIMARY KEY,
    subject VARCHAR(100) NOT NULL,
    dayOfWeek VARCHAR(20) NOT NULL,
    startTime VARCHAR(10) NOT NULL,
    endTime VARCHAR(10) NOT NULL,
    room VARCHAR(50) NOT NULL,
    userId VARCHAR(50) NOT NULL,
    isAttended BOOLEAN DEFAULT FALSE,
    isAdditional BOOLEAN DEFAULT FALSE,
    lectureContent TEXT,
    FOREIGN KEY (userId) REFERENCES users(id) ON DELETE CASCADE
);

-- ----------------------------------------------------------------------------
-- 3. Academic Calendar Table
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS academic_calendar (
    id INTEGER PRIMARY KEY AUTO_INCREMENT,
    number INTEGER NOT NULL,
    label VARCHAR(100) NOT NULL,
    type VARCHAR(50) NOT NULL,
    startDate VARCHAR(50) NOT NULL,
    endDate VARCHAR(50) NOT NULL
);

-- ----------------------------------------------------------------------------
-- 4. Academic Results Table
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS academic_results (
    id INTEGER PRIMARY KEY AUTO_INCREMENT,
    subject VARCHAR(100) NOT NULL,
    semester INTEGER NOT NULL,
    grade VARCHAR(5) NOT NULL,
    gpa REAL NOT NULL,
    userId VARCHAR(50) NOT NULL,
    FOREIGN KEY (userId) REFERENCES users(id) ON DELETE CASCADE
);

-- ----------------------------------------------------------------------------
-- 5. Events Table
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS events (
    id VARCHAR(50) PRIMARY KEY,
    title VARCHAR(150) NOT NULL,
    description TEXT,
    date VARCHAR(50) NOT NULL,
    venue VARCHAR(100) NOT NULL,
    organizer VARCHAR(100) NOT NULL,
    capacity INTEGER DEFAULT 50
);

-- ----------------------------------------------------------------------------
-- 6. User Events (Registrations) Table
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS user_events (
    userId VARCHAR(50),
    eventId VARCHAR(50),
    PRIMARY KEY (userId, eventId),
    FOREIGN KEY (userId) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (eventId) REFERENCES events(id) ON DELETE CASCADE
);

-- ----------------------------------------------------------------------------
-- 7. Announcements Table
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS announcements (
    id VARCHAR(50) PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    body TEXT,
    postedBy VARCHAR(100),
    date VARCHAR(50)
);

-- ============================================================================
-- Seed Mock Data (For Viva Presentation)
-- ============================================================================

-- Insert Test Accounts
INSERT INTO users (id, name, email, password, role, address, emergencyName, emergencyPhone) VALUES 
('usr-001', 'Ashan Perera', 'student@campus.lk', '1234', 'student', 'No 45, Flower Road, Colombo 07', 'Sumanasiri Perera (Father)', '0712345678'),
('usr-002', 'Dr. Nilufar Silva', 'staff@campus.lk', '1234', 'staff', 'Faculty of Engineering, UoR', 'Security Desk', '0412223334')
ON DUPLICATE KEY UPDATE name=VALUES(name), address=VALUES(address);

-- Timetable Data
INSERT INTO timetable (id, subject, dayOfWeek, startTime, endTime, room, userId, isAttended, lectureContent, isAdditional) VALUES 
('tt-001', 'Mobile App Dev', 'Monday', '08:00', '10:00', 'Lab 3', 'usr-001', TRUE, 'Flutter Architecture.', FALSE),
('tt-002', 'Database Systems', 'Tuesday', '10:00', '12:00', 'Hall A', 'usr-001', FALSE, 'SQL Indexing.', FALSE),
('tt-006', 'Guest Lecture', 'Wednesday', '15:30', '17:00', 'Main Hall', 'usr-001', FALSE, 'Future of AI.', TRUE)
ON DUPLICATE KEY UPDATE subject=VALUES(subject);

-- Academic Calendar
INSERT INTO academic_calendar (number, label, type, startDate, endDate) VALUES 
(1, 'Week 01', 'academic', '2026-03-02', '2026-03-08'),
(6, 'Week 06', 'academic', '2026-04-06', '2026-04-12'),
(7, 'Vacation', 'vacation', '2026-04-13', '2026-04-19')
ON DUPLICATE KEY UPDATE label=VALUES(label);

-- Academic Results
INSERT INTO academic_results (subject, semester, grade, gpa, userId) VALUES 
('Mathematics', 1, 'A', 4.0, 'usr-001'),
('Programming', 1, 'A-', 3.7, 'usr-001'),
('Database Systems', 2, 'A', 4.0, 'usr-001')
ON DUPLICATE KEY UPDATE grade=VALUES(grade);

-- Events
INSERT INTO events (id, title, description, date, venue, organizer) VALUES 
('evt-001', 'AI Workshop', 'Hands on with TensorFlow', '2026-04-10', 'Main Auditorium', 'Tech Club'),
('evt-002', 'Career Fair', 'Meet top IT companies', '2026-05-01', 'Campus Ground', 'Career Center')
ON DUPLICATE KEY UPDATE title=VALUES(title);

-- Announcements
INSERT INTO announcements (id, title, body, postedBy, date) VALUES 
('ann-001', 'Campus Closed on Friday', 'Due to extreme weather, campus is closed.', 'Admin', '2026-04-01'),
('ann-002', 'Exam Results Released', 'Log in to the LMS to view your final semester results.', 'Exam Branch', '2026-04-02')
ON DUPLICATE KEY UPDATE title=VALUES(title);

