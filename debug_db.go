package main

import (
	"database/sql"
	"fmt"
	"log"

	"github.com/bournemouth-uni-it-api-go/config"
	"github.com/joho/godotenv"
	_ "github.com/lib/pq"
)

func main() {
	// Load environment variables
	if err := godotenv.Load(); err != nil {
		log.Println("Warning: .env file not found")
	}

	// Initialize configuration
	cfg := config.LoadConfig()

	// Connect to database
	db, err := sql.Open("postgres", cfg.GetDBConnectionString())
	if err != nil {
		log.Fatalf("Failed to connect to database: %v", err)
	}
	defer db.Close()

	if err = db.Ping(); err != nil {
		log.Fatalf("Failed to ping database: %v", err)
	}

	fmt.Println("Database connection successful!")

	// Check if students table exists
	var exists bool
	err = db.QueryRow("SELECT EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'students')").Scan(&exists)
	if err != nil {
		log.Fatalf("Failed to check table existence: %v", err)
	}

	if exists {
		fmt.Println("Students table exists!")
		
		// Count students
		var count int
		err = db.QueryRow("SELECT COUNT(*) FROM students").Scan(&count)
		if err != nil {
			log.Fatalf("Failed to count students: %v", err)
		}
		fmt.Printf("Number of students in table: %d\n", count)

		// Show table structure
		rows, err := db.Query("SELECT column_name, data_type FROM information_schema.columns WHERE table_name = 'students' ORDER BY ordinal_position")
		if err != nil {
			log.Fatalf("Failed to get table structure: %v", err)
		}
		defer rows.Close()

		fmt.Println("\nTable structure:")
		for rows.Next() {
			var columnName, dataType string
			if err := rows.Scan(&columnName, &dataType); err != nil {
				log.Fatalf("Failed to scan column info: %v", err)
			}
			fmt.Printf("- %s: %s\n", columnName, dataType)
		}
	} else {
		fmt.Println("Students table does NOT exist!")
	}
}