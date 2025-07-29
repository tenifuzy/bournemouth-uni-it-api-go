-- Create database if it doesn't exist
CREATE DATABASE student_db;

-- Connect to the database
\c student_db;

-- Create the students table
CREATE TABLE IF NOT EXISTS students (
    id SERIAL PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    student_id VARCHAR(50) NOT NULL UNIQUE,
    course VARCHAR(100) NOT NULL,
    year_of_study INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert sample data
INSERT INTO students (first_name, last_name, email, student_id, course, year_of_study) VALUES
('John', 'Doe', 'john.doe@bournemouth.ac.uk', 'S12345678', 'Information Technology', 2),
('Jane', 'Smith', 'jane.smith@bournemouth.ac.uk', 'S87654321', 'Computer Science', 3),
('Bob', 'Johnson', 'bob.johnson@bournemouth.ac.uk', 'S11111111', 'Software Engineering', 1)
ON CONFLICT (email) DO NOTHING;