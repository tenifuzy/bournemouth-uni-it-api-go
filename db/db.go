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
	// Connect to PostgreSQL without specifying a database
	db, err := sql.Open("postgres", cfg.GetDBConnectionStringWithoutDB())
	if err != nil {
		return err
	}
	defer db.Close()

	// Check if database exists
	var exists bool
	query := fmt.Sprintf("SELECT EXISTS(SELECT 1 FROM pg_database WHERE datname = '%s')", cfg.DBName)
	if err := db.QueryRow(query).Scan(&exists); err != nil {
		return err
	}

	// Create database if it doesn't exist
	if !exists {
		_, err = db.Exec(fmt.Sprintf("CREATE DATABASE %s", cfg.DBName))
		if err != nil {
			return err
		}
		log.Printf("Database '%s' created", cfg.DBName)
	} else {
		log.Printf("Database '%s' already exists", cfg.DBName)
	}

	return nil
}