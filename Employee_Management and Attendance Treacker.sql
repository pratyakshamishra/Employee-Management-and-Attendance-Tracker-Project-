create database employee_attendance_db ;
use employee_attendance_db;
-- Departments table
CREATE TABLE departments (
    dept_id SERIAL PRIMARY KEY,
    dept_name VARCHAR(100) NOT NULL
);
select * from departments ;
INSERT INTO departments (dept_name) VALUES 
('HR'), ('Engineering'), ('Sales'), ('Marketing');
CREATE TABLE roles (
    role_id SERIAL PRIMARY KEY,
    role_name VARCHAR(100) NOT NULL
);
-- Insert sample roles
INSERT INTO roles (role_name) VALUES 
('Manager'), ('Developer'), ('Analyst'), ('Clerk');

-- Employees table
CREATE TABLE employees (
    emp_id SERIAL PRIMARY KEY,
    emp_name VARCHAR(100),
    dept_id INT REFERENCES departments(dept_id),
    role_id INT REFERENCES roles(role_id),
    join_date DATE,
    status VARCHAR(20) DEFAULT 'Active'
);
select * from employees;

CREATE TABLE attendance (
    att_id INT AUTO_INCREMENT PRIMARY KEY,
    emp_id BIGINT UNSIGNED,
    check_in TIME,
    check_out TIME,
    att_date datetime ,
    status VARCHAR(20) DEFAULT 'Present',
    FOREIGN KEY (emp_id) REFERENCES employees(emp_id)
);
select* from attendance;

-- Monthly attendance report
SELECT 
    emp_id,
    MONTH(att_date) AS month,
    YEAR(att_date) AS year,
    COUNT(*) AS present_days
FROM attendance
WHERE status = 'Present'
GROUP BY emp_id, YEAR(att_date), MONTH(att_date)
ORDER BY emp_id, year, month;


-- Late arrivals (Check-in after 10:00 AM)
SELECT emp_id, att_date, check_in
FROM attendance
WHERE TIME(check_in) > '10:00:00';

DELIMITER $$

CREATE TRIGGER before_insert_attendance
BEFORE INSERT ON attendance
FOR EACH ROW
BEGIN
  IF NEW.check_in IS NULL THEN
    SET NEW.check_in = CURRENT_TIMESTAMP;
  END IF;
  
  IF NEW.status IS NULL THEN
    SET NEW.status = 'Present';
  END IF;
END$$

DELIMITER ;
-- Create functions to calculate total work hours.
   
DELIMITER $$

CREATE FUNCTION calculate_work_hours(p_date DATE, p_emp_id INT)
RETURNS DECIMAL(5,2)
DETERMINISTIC
BEGIN
  DECLARE work_hours DECIMAL(5,2);

  SELECT
    TIMESTAMPDIFF(SECOND, check_in, check_out) / 3600
  INTO work_hours
  FROM attendance
  WHERE emp_id = p_emp_id AND att_date = p_date;

  RETURN work_hours;
END$$

DELIMITER ;
SELECT calculate_work_hours('2025-05-13', 1);
--  using GROUP BY and HAVING.

-- Monthly Attendance Report (Total Days Present per Employee)
 SELECT 
    emp_id,
    MONTH(att_date) AS month,
    YEAR(att_date) AS year,
    COUNT(*) AS total_days_present
FROM attendance
WHERE status = 'Active'
GROUP BY emp_id, YEAR(att_date), MONTH(att_date)
ORDER BY emp_id, year, month;

-- Employees Present More Than 20 Days in a Month
SELECT 
    emp_id,
    MONTH(att_date) AS month,
    COUNT(*) AS present_days
FROM attendance
WHERE status = 'Active'
GROUP BY emp_id, MONTH(att_date)
HAVING COUNT(*) > 20;

-- Department-wise Employee Count
SELECT 
    d.dept_name,
    COUNT(e.emp_id) AS total_employees
FROM employees e
JOIN departments d ON e.dept_id = d.dept_id
GROUP BY d.dept_name;

-- Employees With Less Than 10 Working Days in a Month
SELECT 
    emp_id,
    MONTH(att_date) AS month,
    COUNT(*) AS active_days
FROM attendance
WHERE status = 'Active'
GROUP BY emp_id, MONTH(att_date)
HAVING active_days < 10;

-- Average Working Hours per Employee per Month
SELECT 
    emp_id,
    MONTH(att_date) AS month,
    ROUND(SUM(TIMESTAMPDIFF(SECOND, check_in, check_out)) / 3600, 2) AS total_hours,
    ROUND(AVG(TIMESTAMPDIFF(SECOND, check_in, check_out)) / 3600, 2) AS avg_hours_per_day
FROM attendance
WHERE status = 'Active'
GROUP BY emp_id, MONTH(att_date)
HAVING total_hours > 0;


















 