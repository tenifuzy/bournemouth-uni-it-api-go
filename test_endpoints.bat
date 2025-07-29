@echo off
echo Testing API endpoints...
echo.

echo 1. Testing Health Check:
curl -X GET http://localhost:8080/healthcheck
echo.
echo.

echo 2. Testing Create Student:
curl -X POST http://localhost:8080/api/v1/students ^
  -H "Content-Type: application/json" ^
  -d "{\"first_name\":\"John\",\"last_name\":\"Doe\",\"email\":\"john.doe@example.com\",\"student_id\":\"S12345\",\"course\":\"Information Technology\",\"year_of_study\":2}"
echo.
echo.

echo 3. Testing Get All Students:
curl -X GET http://localhost:8080/api/v1/students
echo.
echo.

echo 4. Testing Get Student by ID (ID=1):
curl -X GET http://localhost:8080/api/v1/students/1
echo.
echo.

echo 5. Testing Update Student (ID=1):
curl -X PUT http://localhost:8080/api/v1/students/1 ^
  -H "Content-Type: application/json" ^
  -d "{\"first_name\":\"John\",\"last_name\":\"Smith\",\"email\":\"john.smith@example.com\",\"student_id\":\"S12345\",\"course\":\"Information Technology\",\"year_of_study\":3}"
echo.
echo.

echo 6. Testing Delete Student (ID=1):
curl -X DELETE http://localhost:8080/api/v1/students/1
echo.
echo.

echo Testing completed!
pause