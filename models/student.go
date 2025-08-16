package models

import (
	"database/sql"
	"log"
	"time"
)

// Student represents a student entity
type Student struct {
	ID          int       `json:"id"`
	FirstName   string    `json:"first_name" binding:"required"`
	LastName    string    `json:"last_name" binding:"required"`
	Email       string    `json:"email" binding:"required"`
	StudentID   string    `json:"student_id" binding:"required"`
	Course      string    `json:"course" binding:"required"`
	YearOfStudy int       `json:"year_of_study" binding:"required"`
	CreatedAt   time.Time `json:"created_at"`
	UpdatedAt   time.Time `json:"updated_at"`
}

// StudentRepository defines the interface for student data operations
type StudentRepository interface {
	GetAll() ([]Student, error)
	GetByID(id int) (*Student, error)
	Create(student *Student) error
	Update(student *Student) error
	Delete(id int) error
}

// PostgresStudentRepository implements StudentRepository for PostgreSQL
type PostgresStudentRepository struct {
	DB *sql.DB
}

// NewPostgresStudentRepository creates a new PostgresStudentRepository
func NewPostgresStudentRepository(db *sql.DB) *PostgresStudentRepository {
	return &PostgresStudentRepository{DB: db}
}

// GetAll retrieves all students from the database
func (r *PostgresStudentRepository) GetAll() ([]Student, error) {
	rows, err := r.DB.Query(`
		SELECT id, first_name, last_name, email, student_id, course, year_of_study, created_at, updated_at 
		FROM students
	`)
	if err != nil {
		return nil, err
	}
	defer func() {
		if closeErr := rows.Close(); closeErr != nil {
			log.Printf("Error closing rows: %v", closeErr)
		}
	}()

	var students []Student
	for rows.Next() {
		var s Student
		if err := rows.Scan(&s.ID, &s.FirstName, &s.LastName, &s.Email, &s.StudentID, &s.Course, &s.YearOfStudy, &s.CreatedAt, &s.UpdatedAt); err != nil {
			return nil, err
		}
		students = append(students, s)
	}

	if err := rows.Err(); err != nil {
		return nil, err
	}

	return students, nil
}

// GetByID retrieves a student by ID
func (r *PostgresStudentRepository) GetByID(id int) (*Student, error) {
	var s Student
	err := r.DB.QueryRow(`
		SELECT id, first_name, last_name, email, student_id, course, year_of_study, created_at, updated_at 
		FROM students WHERE id = $1
	`, id).Scan(&s.ID, &s.FirstName, &s.LastName, &s.Email, &s.StudentID, &s.Course, &s.YearOfStudy, &s.CreatedAt, &s.UpdatedAt)

	if err != nil {
		if err == sql.ErrNoRows {
			return nil, nil
		}
		return nil, err
	}

	return &s, nil
}

// Create adds a new student to the database
func (r *PostgresStudentRepository) Create(student *Student) error {
	return r.DB.QueryRow(`
		INSERT INTO students (first_name, last_name, email, student_id, course, year_of_study)
		VALUES ($1, $2, $3, $4, $5, $6)
		RETURNING id, created_at, updated_at
	`, student.FirstName, student.LastName, student.Email, student.StudentID, student.Course, student.YearOfStudy).
		Scan(&student.ID, &student.CreatedAt, &student.UpdatedAt)
}

// Update updates an existing student
func (r *PostgresStudentRepository) Update(student *Student) error {
	err := r.DB.QueryRow(`
		UPDATE students
		SET first_name = $1, last_name = $2, email = $3, student_id = $4, course = $5, year_of_study = $6, updated_at = CURRENT_TIMESTAMP
		WHERE id = $7
		RETURNING created_at, updated_at
	`, student.FirstName, student.LastName, student.Email, student.StudentID, student.Course, student.YearOfStudy, student.ID).
		Scan(&student.CreatedAt, &student.UpdatedAt)

	return err
}

// Delete removes a student from the database
func (r *PostgresStudentRepository) Delete(id int) error {
	result, err := r.DB.Exec("DELETE FROM students WHERE id = $1", id)
	if err != nil {
		return err
	}

	rowsAffected, err := result.RowsAffected()
	if err != nil {
		return err
	}

	if rowsAffected == 0 {
		return sql.ErrNoRows
	}

	return nil
}
