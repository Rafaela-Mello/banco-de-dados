USE employees;

SELECT * FROM departments;
SELECT * FROM dept_emp;
SELECT * FROM dept_manager;
SELECT * FROM employees;
SELECT * FROM salaries;
SELECT * FROM titles;

-- Questões VIEWS
-- 1) Criando uma View para Funcionários Ativos
/* Crie uma view chamada active_employees que mostre o emp_no, first_name, last_name e hire_date de todos
os func. que têm um to_date de salário igual a '9999-01-01'. Devem ser considerados como "ativos" */
CREATE VIEW active_employees AS
	SELECT e.emp_no, e.first_name, e.last_name, e.hire_date
	FROM employees e
    JOIN salaries s ON s.emp_no = e.emp_no
		WHERE s.to_date = '9999-01-01';

SELECT * FROM active_employees;



-- 2) View com Departamentos e Seus Gerentes
/* Crie uma view chamada department_managers que mostre o dept_no, dept_name e o nome completo
do gerente (combinando first_name e last_name dos funcionários) de cada departamento. A view
deve considerar que um departamento pode ter apenas um gerente por vez */
CREATE VIEW department_managers AS
	SELECT d.dept_no, d.dept_name, CONCAT(e.first_name, ' ', e.last_name) as gerente_nome
	FROM departments d
	JOIN dept_manager dm ON dm.dept_no = d.dept_no
	JOIN employees e ON e.emp_no = dm.emp_no
		WHERE dm.to_date = '9999-01-01';

SELECT * FROM department_managers;



-- 3) View com Salários Acima da Média
/* Crie uma view chamada above_average_salaries que mostre o emp_no, first_name, last_name e salary de
todos os funcionários cujo salário é superior à média dos salários de todos os funcionários ativos */
CREATE VIEW above_average_salaries AS
	SELECT e.emp_no, e.first_name, e.last_name, s.salary
    FROM employees e
    JOIN salaries s ON s.emp_no = e.emp_no
    WHERE
		s.to_date = '9999-01-01' AND
		s.salary > (
			SELECT AVG(salary)
            FROM salaries
            WHERE to_date = '9999-01-01'
		);

SELECT * FROM above_average_salaries;



-- 4) View de Títulos de Funcionários por Departamento
/* Crie uma view chamada employee_titles_by_dept que mostre o dept_no, dept_name, emp_no, first_name,
last_name e title de todos os funcionários, organizados por departamento e título. A view
deve garantir que os funcionários que possuem o título mais recente sejam os listados */
CREATE VIEW employee_titles_by_dept AS
	SELECT d.dept_no, d.dept_name, e.emp_no, e.first_name, e.last_name, t.title
	FROM employees e
	JOIN dept_emp de ON e.emp_no = de.emp_no
	JOIN departments d ON d.dept_no = de.dept_no
	JOIN titles t ON t.emp_no = e.emp_no
	WHERE 
		de.to_date = '9999-01-01' AND
		t.to_date = '9999-01-01';

SELECT * FROM employee_titles_by_dept
ORDER BY dept_name, title;



-- 5) View de Histórico de Títulos
/* Crie uma view chamada title_history que mostre o emp_no, title, from_date e to_date
para todos os títulos de todos os funcionários. A view deve filtrar apenas os títulos
cujos to_date sejam diferentes de '9999-01-01', ou seja, excluir títulos atuais */

CREATE VIEW title_history AS
	SELECT e.emp_no, t.title, t.from_date, t.to_date
    FROM employees e
    JOIN titles t ON t.emp_no = e.emp_no
		WHERE t.to_date <> '9999-01-01';

SELECT * FROM title_history;
-- ORDER BY emp_no;
