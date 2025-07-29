@echo off
echo Setting up PostgreSQL database...
echo.

echo Please make sure PostgreSQL is running and you have the correct credentials.
echo Current settings from .env file:
echo DB_HOST=localhost
echo DB_PORT=5432
echo DB_USER=postgres
echo DB_PASSWORD=abcdef
echo DB_NAME=student_db
echo.

echo Running psql command to create database and table...
echo You may be prompted for the postgres user password.
echo.

psql -h localhost -p 5432 -U postgres -c "CREATE DATABASE student_db;" 2>nul
psql -h localhost -p 5432 -U postgres -d student_db -f setup_db.sql

echo.
echo Database setup completed!
pause