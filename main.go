package main

import (
	"log"

	"github.com/bournemouth-uni-it-api-go/config"
	"github.com/bournemouth-uni-it-api-go/db"
	"github.com/bournemouth-uni-it-api-go/router"
	"github.com/joho/godotenv"
)

func main() {
	// Load environment variables
	if err := godotenv.Load(); err != nil {
		log.Println("Warning: .env file not found")
	}

	// Initialize configuration
	cfg := config.LoadConfig()

	// Run migrations (this will create the database if it doesn't exist)
	if err := db.RunMigrations(cfg); err != nil {
		log.Fatalf("Failed to run migrations: %v", err)
	}

	// Initialize database connection
	database, err := db.InitDB(cfg)
	if err != nil {
		log.Fatalf("Failed to connect to database: %v", err)
	}
	defer database.Close()

	// Insert sample data if table is empty
	if err := db.InsertSampleData(database); err != nil {
		log.Printf("Warning: Failed to insert sample data: %v", err)
	}

	// Setup router
	r := router.SetupRouter(database)

	// Start server
	log.Printf("Server starting on port %s", cfg.ServerPort)
	if err := r.Run(":" + cfg.ServerPort); err != nil {
		log.Fatalf("Failed to start server: %v", err)
	}
}
