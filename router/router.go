package router

import (
	"database/sql"
	"path/filepath"

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

	// Absolute path to frontend inside the container
	frontendPath := "/root/frontend"

	// Serve all static files (CSS, JS, images, etc.)
	r.Static("/static", filepath.Join(frontendPath, "static"))

	// Serve main HTML file at root
	r.GET("/", func(c *gin.Context) {
		c.File(filepath.Join(frontendPath, "index.html"))
	})
	r.GET("/index.html", func(c *gin.Context) {
		c.File(filepath.Join(frontendPath, "index.html"))
	})

	// Optional test route
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
