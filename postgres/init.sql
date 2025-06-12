-- Crear la base de datos 'project'
CREATE DATABASE project;

\connect project;

-- ROLES AND USERS
CREATE TABLE roles (
  id SERIAL PRIMARY KEY,
  name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100),
  email VARCHAR(100) UNIQUE NOT NULL,
  password VARCHAR(255) NOT NULL,
  role_id INT,
  mfa_enabled BOOLEAN DEFAULT FALSE,
  FOREIGN KEY (role_id) REFERENCES roles(id)
);

-- COURSES AND MODULES
CREATE TABLE courses (
  id SERIAL PRIMARY KEY,
  title VARCHAR(100),
  description TEXT,
  image VARCHAR(255),
  category VARCHAR(100),
  is_active BOOLEAN DEFAULT TRUE,
  instructor_id INT,
  FOREIGN KEY (instructor_id) REFERENCES users(id)
);

CREATE TYPE module_type AS ENUM ('video', 'text', 'exercise', 'test');

CREATE TABLE modules (
  id SERIAL PRIMARY KEY,
  course_id INT,
  name VARCHAR(100),
  type module_type,
  display_order INT,
  FOREIGN KEY (course_id) REFERENCES courses(id)
);

-- ENROLLMENTS
CREATE TABLE enrollments (
  id SERIAL PRIMARY KEY,
  user_id INT,
  course_id INT,
  enrolled_at TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (course_id) REFERENCES courses(id)
);

-- ASSESSMENTS
CREATE TABLE assessments (
  id SERIAL PRIMARY KEY,
  module_id INT,
  title VARCHAR(100),
  duration_minutes INT,
  start_time TIMESTAMP,
  end_time TIMESTAMP,
  FOREIGN KEY (module_id) REFERENCES modules(id)
);

CREATE TABLE questions (
  id SERIAL PRIMARY KEY,
  assessment_id INT,
  content TEXT,
  FOREIGN KEY (assessment_id) REFERENCES assessments(id)
);

CREATE TABLE options (
  id SERIAL PRIMARY KEY,
  question_id INT,
  content VARCHAR(255),
  is_correct BOOLEAN,
  FOREIGN KEY (question_id) REFERENCES questions(id)
);

-- ATTEMPTS AND RESULTS
CREATE TABLE attempts (
  id SERIAL PRIMARY KEY,
  user_id INT,
  assessment_id INT,
  attempted_at TIMESTAMP,
  score NUMERIC(5,2),
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (assessment_id) REFERENCES assessments(id)
);

-- STUDENT PROGRESS
CREATE TABLE progress (
  id SERIAL PRIMARY KEY,
  user_id INT,
  module_id INT,
  is_completed BOOLEAN,
  updated_at TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (module_id) REFERENCES modules(id)
);

-- NOTIFICATIONS
CREATE TABLE notifications (
  id SERIAL PRIMARY KEY,
  sender_id INT,
  content TEXT,
  sent_at TIMESTAMP,
  type VARCHAR(50),
  recipients JSON,
  FOREIGN KEY (sender_id) REFERENCES users(id)
);

-- FILES (Polymorphic)
CREATE TABLE files (
  id SERIAL PRIMARY KEY,
  original_name VARCHAR(255),
  path VARCHAR(255) NOT NULL,
  mime_type VARCHAR(100),
  size_bytes INT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  fileable_id INT NOT NULL,
  fileable_type VARCHAR(100) NOT NULL
);

CREATE INDEX idx_fileable ON files (fileable_id, fileable_type);

INSERT INTO roles (name) VALUES
('Admin'),
('Teacher'),
('Student');

INSERT INTO users (name, email, password, photo, role_id, mfa_enabled) VALUES
('Admin User', 'admin@example.com', 'hashed_password_admin', 1, FALSE);  

INSERT INTO users (name, email, password, photo, role_id, mfa_enabled) VALUES
('Teacher User', 'teacher@example.com', 'hashed_password_teacher', 2, FALSE);  

INSERT INTO users (name, email, password, photo, role_id, mfa_enabled) VALUES
('Student User', 'student@example.com', 'hashed_password_student', 3, FALSE);  
