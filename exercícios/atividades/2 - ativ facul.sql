-- Questão 5
SELECT 
  e.first_name,
  s.salary,
  calcula_bonus(s.salary, 15) AS bonus
FROM employees e
JOIN salaries s ON e.emp_no = s.emp_no;


-- Questão 6
CREATE VIEW funcionarios_baixo_salario AS
SELECT 
  e.first_name,
  e.last_name,
  s.salary
FROM employees e
JOIN salaries s ON e.emp_no = s.emp_no
WHERE s.salary < 40000;

SELECT * FROM funcionarios_baixo_salario;


-- Questão 7
DELIMITER //
CREATE PROCEDURE salario_maior_que(IN sal_base INT)
BEGIN
  SELECT 
    e.first_name,
    e.last_name,
    s.salary
  FROM employees e
  JOIN salaries s ON e.emp_no = s.emp_no
  WHERE s.salary > sal_base;
END //
DELIMITER ;

CALL salario_maior_que(24000);


-- Questão 8

CREATE TABLE salary_changes_history(
	id INT AUTO_INCREMENT PRIMARY KEY,
    emp_no INT, 
    old_salary DECIMAL(10,2),
    new_salary DECIMAL(10,2),
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DELIMITER //
CREATE TRIGGER after_salary_update
AFTER UPDATE ON salaries
FOR EACH ROW
BEGIN
	DECLARE dept_atual CHAR(4);
	DECLARE gerente_emp_no INT;
	DECLARE salario_gerente INT;

	-- Pega o departamento atual do funcionário
	SELECT dept_no INTO dept_atual
	FROM dept_emp
	WHERE emp_no = NEW.emp_no
		AND to_date = '9999-01-01'
	LIMIT 1;

	-- Pega o gerente atual do departamento
	SELECT emp_no INTO gerente_emp_no
	FROM dept_manager
	WHERE dept_no = dept_atual
		AND to_date = '9999-01-01'
	LIMIT 1;

	-- Pega o salário atual do gerente
	SELECT salary INTO salario_gerente
	FROM salaries
	WHERE emp_no = gerente_emp_no
		AND to_date = '9999-01-01'
	LIMIT 1;

	-- Compara os salários e insere no histórico se necessário
	IF NEW.salary > salario_gerente THEN
		INSERT INTO salary_changes_history (emp_no, old_salary, new_salary)
		VALUES (NEW.emp_no, OLD.salary, NEW.salary);
	END IF;
END //
DELIMITER ;

-- Teste do trigger
UPDATE salaries
SET salary = 80000
WHERE emp_no = 10002 AND to_date = '9999-01-01';

SELECT * FROM salaries;
SELECT * FROM salary_changes_history;




