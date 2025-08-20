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

	// Serve frontend HTML directly
	r.GET("/", func(c *gin.Context) {
		c.Header("Content-Type", "text/html")
		c.String(http.StatusOK, getIndexHTML())
	})
	r.GET("/index.html", func(c *gin.Context) {
		c.Header("Content-Type", "text/html")
		c.String(http.StatusOK, getIndexHTML())
	})

	// Test route
	r.GET("/test", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{"message": "Server is working", "status": "ok"})
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

// getIndexHTML returns the HTML content for the frontend
func getIndexHTML() string {
	return `<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Bournemouth University IT Students</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: Arial, sans-serif; background: #f5f5f5; }
        .container { max-width: 1200px; margin: 0 auto; padding: 20px; }
        .header { background: #2c3e50; color: white; padding: 20px; text-align: center; margin-bottom: 30px; }
        .form-section { background: white; padding: 20px; border-radius: 8px; margin-bottom: 20px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .form-group { margin-bottom: 15px; }
        label { display: block; margin-bottom: 5px; font-weight: bold; }
        input, select { width: 100%; padding: 8px; border: 1px solid #ddd; border-radius: 4px; }
        button { background: #3498db; color: white; padding: 10px 20px; border: none; border-radius: 4px; cursor: pointer; margin-right: 10px; }
        button:hover { background: #2980b9; }
        .btn-danger { background: #e74c3c; }
        .btn-danger:hover { background: #c0392b; }
        .students-table { background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        table { width: 100%; border-collapse: collapse; }
        th, td { padding: 12px; text-align: left; border-bottom: 1px solid #ddd; }
        th { background: #f8f9fa; font-weight: bold; }
        .actions { display: flex; gap: 5px; }
        .message { padding: 10px; margin: 10px 0; border-radius: 4px; }
        .success { background: #d4edda; color: #155724; border: 1px solid #c3e6cb; }
        .error { background: #f8d7da; color: #721c24; border: 1px solid #f5c6cb; }
        .form-row { display: flex; gap: 15px; }
        .form-row .form-group { flex: 1; }
    </style>
</head>
<body>
    <div class="header">
        <h1>Bournemouth University IT Students Management</h1>
        <p>Student Information System</p>
    </div>
    <div class="container">
        <div id="message"></div>
        <div class="form-section">
            <h2>Add/Edit Student</h2>
            <form id="studentForm">
                <input type="hidden" id="studentId">
                <div class="form-row">
                    <div class="form-group">
                        <label for="firstName">First Name:</label>
                        <input type="text" id="firstName" required>
                    </div>
                    <div class="form-group">
                        <label for="lastName">Last Name:</label>
                        <input type="text" id="lastName" required>
                    </div>
                </div>
                <div class="form-row">
                    <div class="form-group">
                        <label for="email">Email:</label>
                        <input type="email" id="email" required>
                    </div>
                    <div class="form-group">
                        <label for="studentIdField">Student ID:</label>
                        <input type="text" id="studentIdField" required>
                    </div>
                </div>
                <div class="form-row">
                    <div class="form-group">
                        <label for="course">Course:</label>
                        <input type="text" id="course" value="Information Technology" required>
                    </div>
                    <div class="form-group">
                        <label for="yearOfStudy">Year of Study:</label>
                        <select id="yearOfStudy" required>
                            <option value="1">1st Year</option>
                            <option value="2">2nd Year</option>
                            <option value="3">3rd Year</option>
                            <option value="4">4th Year</option>
                        </select>
                    </div>
                </div>
                <button type="submit" id="submitBtn">Add Student</button>
                <button type="button" id="cancelBtn" onclick="resetForm()" style="display:none;">Cancel</button>
            </form>
        </div>
        <div class="students-table">
            <h2>Students List</h2>
            <table id="studentsTable">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Name</th>
                        <th>Email</th>
                        <th>Student ID</th>
                        <th>Course</th>
                        <th>Year</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody id="studentsBody"></tbody>
            </table>
        </div>
    </div>
    <script>
        const API_BASE = '/api/v1';
        let editingId = null;
        document.addEventListener('DOMContentLoaded', loadStudents);
        document.getElementById('studentForm').addEventListener('submit', async (e) => {
            e.preventDefault();
            const student = {
                first_name: document.getElementById('firstName').value,
                last_name: document.getElementById('lastName').value,
                email: document.getElementById('email').value,
                student_id: document.getElementById('studentIdField').value,
                course: document.getElementById('course').value,
                year_of_study: parseInt(document.getElementById('yearOfStudy').value)
            };
            try {
                let response;
                if (editingId) {
                    response = await fetch(\`\${API_BASE}/students/\${editingId}\`, {
                        method: 'PUT',
                        headers: { 'Content-Type': 'application/json' },
                        body: JSON.stringify(student)
                    });
                } else {
                    response = await fetch(\`\${API_BASE}/students\`, {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/json' },
                        body: JSON.stringify(student)
                    });
                }
                if (response.ok) {
                    showMessage(editingId ? 'Student updated successfully!' : 'Student added successfully!', 'success');
                    resetForm();
                    loadStudents();
                } else {
                    const error = await response.json();
                    showMessage(error.error || 'Operation failed', 'error');
                }
            } catch (error) {
                showMessage('Network error: ' + error.message, 'error');
            }
        });
        async function loadStudents() {
            try {
                const response = await fetch(\`\${API_BASE}/students\`);
                if (response.ok) {
                    const students = await response.json();
                    displayStudents(students || []);
                } else {
                    showMessage('Failed to load students', 'error');
                }
            } catch (error) {
                showMessage('Network error: ' + error.message, 'error');
            }
        }
        function displayStudents(students) {
            const tbody = document.getElementById('studentsBody');
            tbody.innerHTML = '';
            students.forEach(student => {
                const row = tbody.insertRow();
                row.innerHTML = \`
                    <td>\${student.id}</td>
                    <td>\${student.first_name} \${student.last_name}</td>
                    <td>\${student.email}</td>
                    <td>\${student.student_id}</td>
                    <td>\${student.course}</td>
                    <td>Year \${student.year_of_study}</td>
                    <td class="actions">
                        <button onclick="editStudent(\${student.id})">Edit</button>
                        <button class="btn-danger" onclick="deleteStudent(\${student.id})">Delete</button>
                    </td>
                \`;
            });
        }
        async function editStudent(id) {
            try {
                const response = await fetch(\`\${API_BASE}/students/\${id}\`);
                if (response.ok) {
                    const student = await response.json();
                    document.getElementById('studentId').value = student.id;
                    document.getElementById('firstName').value = student.first_name;
                    document.getElementById('lastName').value = student.last_name;
                    document.getElementById('email').value = student.email;
                    document.getElementById('studentIdField').value = student.student_id;
                    document.getElementById('course').value = student.course;
                    document.getElementById('yearOfStudy').value = student.year_of_study;
                    editingId = id;
                    document.getElementById('submitBtn').textContent = 'Update Student';
                    document.getElementById('cancelBtn').style.display = 'inline-block';
                } else {
                    showMessage('Failed to load student details', 'error');
                }
            } catch (error) {
                showMessage('Network error: ' + error.message, 'error');
            }
        }
        async function deleteStudent(id) {
            if (!confirm('Are you sure you want to delete this student?')) return;
            try {
                const response = await fetch(\`\${API_BASE}/students/\${id}\`, {
                    method: 'DELETE'
                });
                if (response.ok) {
                    showMessage('Student deleted successfully!', 'success');
                    loadStudents();
                } else {
                    const error = await response.json();
                    showMessage(error.error || 'Delete failed', 'error');
                }
            } catch (error) {
                showMessage('Network error: ' + error.message, 'error');
            }
        }
        function resetForm() {
            document.getElementById('studentForm').reset();
            document.getElementById('studentId').value = '';
            document.getElementById('course').value = 'Information Technology';
            editingId = null;
            document.getElementById('submitBtn').textContent = 'Add Student';
            document.getElementById('cancelBtn').style.display = 'none';
        }
        function showMessage(text, type) {
            const messageDiv = document.getElementById('message');
            messageDiv.innerHTML = \`<div class="message \${type}">\${text}</div>\`;
            setTimeout(() => messageDiv.innerHTML = '', 5000);
        }
    </script>
</body>
</html>\`
}
