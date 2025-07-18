package handlers

import (
	"database/sql"
	"log"
	"net/http"
	"strconv"

	"github.com/bournemouth-uni-it-api-go/models"
	"github.com/gin-gonic/gin"
)

// StudentHandler handles HTTP requests for students
type StudentHandler struct {
	Repo models.StudentRepository
}

// NewStudentHandler creates a new StudentHandler
func NewStudentHandler(db *sql.DB) *StudentHandler {
	return &StudentHandler{
		Repo: models.NewPostgresStudentRepository(db),
	}
}

// GetAllStudents handles GET requests to retrieve all students
func (h *StudentHandler) GetAllStudents(c *gin.Context) {
	students, err := h.Repo.GetAll()
	if err != nil {
		log.Printf("Error getting all students: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to retrieve students"})
		return
	}

	c.JSON(http.StatusOK, students)
}

// GetStudentByID handles GET requests to retrieve a student by ID
func (h *StudentHandler) GetStudentByID(c *gin.Context) {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid student ID"})
		return
	}

	student, err := h.Repo.GetByID(id)
	if err != nil {
		log.Printf("Error getting student by ID: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to retrieve student"})
		return
	}

	if student == nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Student not found"})
		return
	}

	c.JSON(http.StatusOK, student)
}

// CreateStudent handles POST requests to create a new student
func (h *StudentHandler) CreateStudent(c *gin.Context) {
	var student models.Student
	if err := c.ShouldBindJSON(&student); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	if err := h.Repo.Create(&student); err != nil {
		log.Printf("Error creating student: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create student"})
		return
	}

	c.JSON(http.StatusCreated, student)
}

// UpdateStudent handles PUT requests to update an existing student
func (h *StudentHandler) UpdateStudent(c *gin.Context) {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid student ID"})
		return
	}

	// Check if student exists
	existingStudent, err := h.Repo.GetByID(id)
	if err != nil {
		log.Printf("Error checking student existence: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to retrieve student"})
		return
	}

	if existingStudent == nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Student not found"})
		return
	}

	// Bind request body to student model
	var student models.Student
	if err := c.ShouldBindJSON(&student); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Set the ID from the URL parameter
	student.ID = id

	// Update the student
	if err := h.Repo.Update(&student); err != nil {
		log.Printf("Error updating student: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update student"})
		return
	}

	c.JSON(http.StatusOK, student)
}

// DeleteStudent handles DELETE requests to remove a student
func (h *StudentHandler) DeleteStudent(c *gin.Context) {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid student ID"})
		return
	}

	// Check if student exists
	existingStudent, err := h.Repo.GetByID(id)
	if err != nil {
		log.Printf("Error checking student existence: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to retrieve student"})
		return
	}

	if existingStudent == nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Student not found"})
		return
	}

	// Delete the student
	if err := h.Repo.Delete(id); err != nil {
		log.Printf("Error deleting student: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to delete student"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Student deleted successfully"})
}

// HealthCheck handles GET requests to check API health
func (h *StudentHandler) HealthCheck(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{
		"status": "ok",
		"message": "API is running",
	})
}