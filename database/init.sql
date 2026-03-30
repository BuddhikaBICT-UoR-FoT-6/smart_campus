-- ============================================================================
-- Smart Campus Database Initialization Script
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
    role ENUM('student', 'staff') NOT NULL
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
    FOREIGN KEY (userId) REFERENCES users(id) ON DELETE CASCADE
);

-- ----------------------------------------------------------------------------
-- 3. Events Table
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
-- 4. User Events (Registrations) Table
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS user_events (
    userId VARCHAR(50),
    eventId VARCHAR(50),
    PRIMARY KEY (userId, eventId),
    FOREIGN KEY (userId) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (eventId) REFERENCES events(id) ON DELETE CASCADE
);

-- ----------------------------------------------------------------------------
-- 5. Announcements Table
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

-- Insert Test Accounts securely mimicking the previously mocked AuthProvider strings
INSERT INTO users (id, name, email, password, role) VALUES 
('usr-001', 'Ashan Perera', 'student@campus.lk', '1234', 'student'),
('usr-002', 'Dr. Nilufar Silva', 'staff@campus.lk', '1234', 'staff'),
('usr-003', 'Campus Admin', 'admin@campus.lk', '1234', 'superadmin')
ON DUPLICATE KEY UPDATE name=name;

-- Refactored SQLite Timetable insertions safely ported to MySQL
INSERT INTO timetable (id, subject, dayOfWeek, startTime, endTime, room, userId) VALUES 
('tt-001', 'Mobile App Dev', 'Monday', '08:00', '10:00', 'Lab 3', 'usr-001'),
('tt-002', 'Database Systems', 'Tuesday', '10:00', '12:00', 'Hall A', 'usr-001')
ON DUPLICATE KEY UPDATE subject=subject;

-- Refactored SQLite Events data migrated into MySQL structures
INSERT INTO events (id, title, description, date, venue, organizer) VALUES 
('evt-001', 'AI Workshop', 'Hands on with TensorFlow', '2026-04-10', 'Main Auditorium', 'Tech Club'),
('evt-002', 'Career Fair', 'Meet top IT companies', '2026-05-01', 'Campus Ground', 'Career Center')
ON DUPLICATE KEY UPDATE title=title;

-- Automatically register the student for the AI Workshop to demonstrate the Checkmark boundary
INSERT IGNORE INTO user_events (userId, eventId) VALUES ('usr-001', 'evt-001');

-- Migrated Announcements explicitly away from the external 'jsonplaceholder' domain
INSERT INTO announcements (id, title, body, postedBy, date) VALUES 
('ann-001', 'Campus Closed on Friday', 'Due to extreme weather, campus is closed.', 'Admin', '2026-04-01'),
('ann-002', 'Exam Results Released', 'Log in to the LMS to view your final semester results.', 'Exam Branch', '2026-04-02')
ON DUPLICATE KEY UPDATE title=title;
