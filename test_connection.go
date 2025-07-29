package main

import (
	"database/sql"
	"log"

	"github.com/joho/godotenv"
	_ "github.com/lib/pq"
)

func main() {
	// Load environment variables
	if err := godotenv.Load(); err != nil {
		log.Println("Warning: .env file not found")
	}

	// Test different connection strings
	testConnections := []struct {
		name   string
		connStr string
	}{
		{"Default postgres", "host=localhost port=5432 user=postgres password=abcdef dbname=postgres sslmode=disable"},
		{"Student DB", "host=localhost port=5432 user=postgres password=abcdef dbname=student_db sslmode=disable"},
	}

	for _, test := range testConnections {
		log.Printf("Testing connection: %s", test.name)
		db, err := sql.Open("postgres", test.connStr)
		if err != nil {
			log.Printf("  ❌ Failed to open: %v", err)
			continue
		}

		if err = db.Ping(); err != nil {
			log.Printf("  ❌ Failed to ping: %v", err)
		} else {
			log.Printf("  ✅ Connection successful!")
		}
		db.Close()
	}
}