package db

import (
	"database/sql"
	"fmt"
	"log"

	"github.com/bournemouth-uni-it-api-go/config"
	_ "github.com/lib/pq"
)

// InitDB initializes the database connection
func InitDB(cfg *config.Config) (*sql.DB, error) {
	db, err := sql.Open("postgres", cfg.GetDBConnectionString())
	if err != nil {
		return nil, err
	}

	if err = db.Ping(); err != nil {
		return nil, err
	}

	log.Println("Database connection established")
	return db, nil
}

// CreateDBIfNotExists creates the database if it doesn't exist
func CreateDBIfNotExists(cfg *config.Config) error {
	log.Printf("Connecting to PostgreSQL to create database '%s'...", cfg.DBName)
	
	// Connect to PostgreSQL default database
	connStr := cfg.GetDBConnectionStringWithoutDB()
	log.Printf("Connection string (without password): host=%s port=%s user=%s dbname=postgres sslmode=%s", 
		cfg.DBHost, cfg.DBPort, cfg.DBUser, cfg.DBSSLMode)
	
	db, err := sql.Open("postgres", connStr)
	if err != nil {
		return fmt.Errorf("failed to open connection to postgres database: %w", err)
	}
	defer db.Close()

	// Test connection
	if err := db.Ping(); err != nil {
		return fmt.Errorf("failed to ping postgres database: %w", err)
	}

	// Check if database exists
	var exists bool
	query := "SELECT EXISTS(SELECT 1 FROM pg_database WHERE datname = $1)"
	if err := db.QueryRow(query, cfg.DBName).Scan(&exists); err != nil {
		return fmt.Errorf("failed to check if database exists: %w", err)
	}

	// Create database if it doesn't exist
	if !exists {
		createQuery := fmt.Sprintf("CREATE DATABASE %s", cfg.DBName)
		_, err = db.Exec(createQuery)
		if err != nil {
			return fmt.Errorf("failed to create database '%s': %w", cfg.DBName, err)
		}
		log.Printf("Database '%s' created successfully", cfg.DBName)
	} else {
		log.Printf("Database '%s' already exists", cfg.DBName)
	}

	return nil
}

// InsertSampleData inserts sample data if the table is empty
func InsertSampleData(db *sql.DB) error {
	// Check if table has any data
	var count int
	err := db.QueryRow("SELECT COUNT(*) FROM students").Scan(&count)
	if err != nil {
		return fmt.Errorf("failed to count students: %w", err)
	}

	if count > 0 {
		log.Printf("Students table already has %d records", count)
		return nil
	}

	// Insert sample data
	sampleData := []struct {
		firstName, lastName, email, studentID, course string
		yearOfStudy int
	}{
		{"John", "Doe", "john.doe@bournemouth.ac.uk", "S12345678", "Information Technology", 2},
		{"Jane", "Smith", "jane.smith@bournemouth.ac.uk", "S87654321", "Computer Science", 3},
		{"Bob", "Johnson", "bob.johnson@bournemouth.ac.uk", "S11111111", "Software Engineering", 1},
	}

	for _, student := range sampleData {
		_, err := db.Exec(`
			INSERT INTO students (first_name, last_name, email, student_id, course, year_of_study)
			VALUES ($1, $2, $3, $4, $5, $6)
		`, student.firstName, student.lastName, student.email, student.studentID, student.course, student.yearOfStudy)
		
		if err != nil {
			log.Printf("Warning: Failed to insert sample student %s %s: %v", student.firstName, student.lastName, err)
		} else {
			log.Printf("Inserted sample student: %s %s", student.firstName, student.lastName)
		}
	}

	log.Println("Sample data insertion completed")
	return nil
}