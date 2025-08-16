package middleware

import (
	"log"
	"time"

	"github.com/gin-gonic/gin"
)

// Logger is a middleware that logs request details
func Logger() gin.HandlerFunc {
	return func(c *gin.Context) {
		// Start timer
		start := time.Now()
		path := c.Request.URL.Path
		method := c.Request.Method

		// Process request
		c.Next()

		// Log request details
		latency := time.Since(start)
		statusCode := c.Writer.Status()
		clientIP := c.ClientIP()

		log.Printf("[%s] %s %s %d %s %s",
			method,
			path,
			clientIP,
			statusCode,
			latency,
			c.Errors.String(),
		)
	}
}
