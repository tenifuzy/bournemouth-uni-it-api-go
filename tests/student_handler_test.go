package tests

import (
	"bytes"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/bournemouth-uni-it-api-go/handlers"
	"github.com/bournemouth-uni-it-api-go/models"
	"github.com/gin-gonic/gin"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/mock"
)

// MockStudentRepository is a mock implementation of StudentRepository
type MockStudentRepository struct {
	mock.Mock
}

func (m *MockStudentRepository) GetAll() ([]models.Student, error) {
	args := m.Called()
	return args.Get(0).([]models.Student), args.Error(1)
}

func (m *MockStudentRepository) GetByID(id int) (*models.Student, error) {
	args := m.Called(id)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).(*models.Student), args.Error(1)
}

func (m *MockStudentRepository) Create(student *models.Student) error {
	args := m.Called(student)
	return args.Error(0)
}

func (m *MockStudentRepository) Update(student *models.Student) error {
	args := m.Called(student)
	return args.Error(0)
}

func (m *MockStudentRepository) Delete(id int) error {
	args := m.Called(id)
	return args.Error(0)
}

// Setup test router
func setupTestRouter() (*gin.Engine, *MockStudentRepository) {
	gin.SetMode(gin.TestMode)
	r := gin.New()
	mockRepo := new(MockStudentRepository)

	// Create a test handler with the mock repository
	handler := &handlers.StudentHandler{
		Repo: mockRepo,
	}

	// Set up routes
	r.GET("/api/v1/students", handler.GetAllStudents)
	r.GET("/api/v1/students/:id", handler.GetStudentByID)
	r.POST("/api/v1/students", handler.CreateStudent)
	r.PUT("/api/v1/students/:id", handler.UpdateStudent)
	r.DELETE("/api/v1/students/:id", handler.DeleteStudent)
	r.GET("/healthcheck", handler.HealthCheck)

	return r, mockRepo
}

func TestGetAllStudents(t *testing.T) {
	r, mockRepo := setupTestRouter()

	// Mock data
	students := []models.Student{
		{ID: 1, FirstName: "John", LastName: "Doe", Email: "john@example.com", StudentID: "S12346", Course: "IT", YearOfStudy: 2},
		{ID: 2, FirstName: "Jane", LastName: "Smith", Email: "jane@example.com", StudentID: "S67891", Course: "IT", YearOfStudy: 3},
	}

	// Set expectations
	mockRepo.On("GetAll").Return(students, nil)

	// Create request
	req, _ := http.NewRequest("GET", "/api/v1/students", nil)
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)

	// Assert response
	assert.Equal(t, http.StatusOK, w.Code)

	var response []models.Student
	err := json.Unmarshal(w.Body.Bytes(), &response)
	assert.NoError(t, err)
	assert.Len(t, response, 2)
	assert.Equal(t, students[0].ID, response[0].ID)
	assert.Equal(t, students[1].ID, response[1].ID)
}

func TestGetStudentByID(t *testing.T) {
	r, mockRepo := setupTestRouter()

	// Mock data
	student := &models.Student{ID: 1, FirstName: "John", LastName: "Doe", Email: "john@example.com", StudentID: "S12345", Course: "IT", YearOfStudy: 2}

	// Set expectations
	mockRepo.On("GetByID", 1).Return(student, nil)
	mockRepo.On("GetByID", 999).Return(nil, nil)

	// Test existing student
	req, _ := http.NewRequest("GET", "/api/v1/students/1", nil)
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)

	// Assert response
	assert.Equal(t, http.StatusOK, w.Code)

	var response models.Student
	err := json.Unmarshal(w.Body.Bytes(), &response)
	assert.NoError(t, err)
	assert.Equal(t, student.ID, response.ID)

	// Test non-existing student
	req, _ = http.NewRequest("GET", "/api/v1/students/999", nil)
	w = httptest.NewRecorder()
	r.ServeHTTP(w, req)

	// Assert response
	assert.Equal(t, http.StatusNotFound, w.Code)
}

func TestCreateStudent(t *testing.T) {
	r, mockRepo := setupTestRouter()

	// Mock data
	student := models.Student{
		FirstName:   "New",
		LastName:    "Student",
		Email:       "new@example.com",
		StudentID:   "S99999",
		Course:      "IT",
		YearOfStudy: 1,
	}

	// Set expectations
	mockRepo.On("Create", mock.AnythingOfType("*models.Student")).Return(nil).Run(func(args mock.Arguments) {
		s := args.Get(0).(*models.Student)
		s.ID = 3 // Simulate ID assignment
	})

	// Create request
	jsonData, _ := json.Marshal(student)
	req, _ := http.NewRequest("POST", "/api/v1/students", bytes.NewBuffer(jsonData))
	req.Header.Set("Content-Type", "application/json")
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)

	// Assert response
	assert.Equal(t, http.StatusCreated, w.Code)

	var response models.Student
	err := json.Unmarshal(w.Body.Bytes(), &response)
	assert.NoError(t, err)
	assert.Equal(t, 3, response.ID)
	assert.Equal(t, student.FirstName, response.FirstName)
}

func TestUpdateStudent(t *testing.T) {
	r, mockRepo := setupTestRouter()

	// Mock data
	existingStudent := &models.Student{ID: 1, FirstName: "John", LastName: "Doe"}
	updatedStudent := models.Student{
		FirstName:   "Updated",
		LastName:    "Student",
		Email:       "updated@example.com",
		StudentID:   "S11111",
		Course:      "IT",
		YearOfStudy: 2,
	}

	// Set expectations
	mockRepo.On("GetByID", 1).Return(existingStudent, nil)
	mockRepo.On("GetByID", 999).Return(nil, nil)
	mockRepo.On("Update", mock.AnythingOfType("*models.Student")).Return(nil)

	// Test updating existing student
	jsonData, _ := json.Marshal(updatedStudent)
	req, _ := http.NewRequest("PUT", "/api/v1/students/1", bytes.NewBuffer(jsonData))
	req.Header.Set("Content-Type", "application/json")
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)

	// Assert response
	assert.Equal(t, http.StatusOK, w.Code)

	// Test updating non-existing student
	req, _ = http.NewRequest("PUT", "/api/v1/students/999", bytes.NewBuffer(jsonData))
	req.Header.Set("Content-Type", "application/json")
	w = httptest.NewRecorder()
	r.ServeHTTP(w, req)

	// Assert response
	assert.Equal(t, http.StatusNotFound, w.Code)
}

func TestDeleteStudent(t *testing.T) {
	r, mockRepo := setupTestRouter()

	// Mock data
	existingStudent := &models.Student{ID: 1, FirstName: "John", LastName: "Doe"}

	// Set expectations
	mockRepo.On("GetByID", 1).Return(existingStudent, nil)
	mockRepo.On("GetByID", 999).Return(nil, nil)
	mockRepo.On("Delete", 1).Return(nil)

	// Test deleting existing student
	req, _ := http.NewRequest("DELETE", "/api/v1/students/1", nil)
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)

	// Assert response
	assert.Equal(t, http.StatusOK, w.Code)

	// Test deleting non-existing student
	req, _ = http.NewRequest("DELETE", "/api/v1/students/999", nil)
	w = httptest.NewRecorder()
	r.ServeHTTP(w, req)

	// Assert response
	assert.Equal(t, http.StatusNotFound, w.Code)
}

func TestHealthCheck(t *testing.T) {
	r, _ := setupTestRouter()

	// Create request
	req, _ := http.NewRequest("GET", "/healthcheck", nil)
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)

	// Assert response
	assert.Equal(t, http.StatusOK, w.Code)

	var response map[string]interface{}
	err := json.Unmarshal(w.Body.Bytes(), &response)
	assert.NoError(t, err)
	assert.Equal(t, "ok", response["status"])
}
