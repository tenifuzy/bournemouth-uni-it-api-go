package router

import (
	"database/sql"
	"net/http"

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

	// Serve frontend
	r.StaticFile("/", "./frontend/index.html")
	r.StaticFile("/index.html", "./frontend/index.html")

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