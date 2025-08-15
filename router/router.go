package router

import (
	"database/sql"

	"github.com/bournemouth-uni-it-api-go/handlers"
	"github.com/bournemouth-uni-it-api-go/middleware"
	"github.com/gin-gonic/gin"
)

// SetupRouter configures the API routes
func SetupRouter(db *sql.DB) *gin.Engine {
	r := gin.New()
	
	// Use middleware
	r.Use(gin.Recovery())
	r.Use(middleware.Logger())
	
	// Create handlers
	studentHandler := handlers.NewStudentHandler(db)

	// Serve static files from frontend directory
	r.Static("/static", "./frontend/static")
	
	// Serve the main HTML file at root
	r.GET("/", func(c *gin.Context) {
		c.File("./frontend/index.html")
	})
	
	// Add a test route to verify the server is working
	r.GET("/test", func(c *gin.Context) {
		c.JSON(200, gin.H{"message": "Server is working"})
	})

	// Health check endpoint
	r.GET("/healthcheck", studentHandler.HealthCheck)

	// API v1 routes
	v1 := r.Group("/api/v1")
	{
		students := v1.Group("/students")
		{
			students.GET("", studentHandler.GetAllStudents)
			students.GET("/:id", studentHandler.GetStudentByID)
			students.POST("", studentHandler.CreateStudent)
			students.PUT("/:id", studentHandler.UpdateStudent)
			students.DELETE("/:id", studentHandler.DeleteStudent)
		}
	}

	return r
}