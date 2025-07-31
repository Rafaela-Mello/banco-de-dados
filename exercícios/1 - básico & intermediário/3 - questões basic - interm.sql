USE employees;

SELECT * FROM departments;
SELECT * FROM dept_emp;
SELECT * FROM dept_manager;
SELECT * FROM employees;
SELECT * FROM salaries;
SELECT * FROM titles;

-- Questões Básicas / Intermediária

-- 1) WHERE
-- Liste os nomes e sobrenomes dos funcionários contratados após o ano 2000 e não estão mais no departamento.
SELECT e.first_name, e.last_name, de.from_date
FROM employees e
JOIN dept_emp de ON de.emp_no = e.emp_no
WHERE de.from_date > '2000-01-01' AND de.to_date <> '9999-01-01'; -- e que não trabalhe mais (<> diferente)


-- 2) Operadores Aritméticos
-- 1. Liste o número do empregado e o dobro do salário atual.
SELECT e.emp_no, e.first_name, s.salary as 'antes', (s.salary * 2) as 'depois'
FROM salaries s
JOIN employees e ON e.emp_no = s.emp_no
	WHERE s.to_date = '9999-01-01';
    
-- 2. Liste os funcionários com salário entre 50.000 e 60.000.
SELECT e.first_name, s.salary
FROM employees e
JOIN salaries s ON s.emp_no = e.emp_no
	WHERE salary BETWEEN 50000 AND 60000
    AND s.to_date = '9999-01-01' -- para não repetir nomes
ORDER BY s.salary ASC;
    

-- 3) DISTINCT
-- Liste todos os títulos diferentes que os funcionários já tiveram.
SELECT DISTINCT title
FROM titles;


-- 4) LIKE
-- Liste todos os departamentos cujo nome começa com “S”.
SELECT dept_name
FROM departments
WHERE dept_name LIKE 's%';


-- 5) Comparação envolvendo NULL
-- Liste os títulos que ainda estão ativos (com to_date nulo).
SELECT title 
FROM titles
WHERE to_date IS NULL; -- ou '9999-01-01' pois nao tem o NULL


-- 6) ALL
-- Liste os empregados cujo salário atual é maior que todos os salários registrados no ano de 1995.
SELECT e.first_name, s.salary, s.from_date
FROM employees e
JOIN salaries s ON s.emp_no = e.emp_no
	WHERE 
		s.to_date = '9999-01-01' AND
		s.salary > ALL (
			SELECT salary
			FROM salaries
			WHERE YEAR(from_date) = 1995 AND to_date = '9999-01-01'
		);


-- 7) UNION -> DEVEM RETORNAR O MESMO N° DE COLUNAS (2 colunas: emp_no e first_name)
-- Liste todos os números de empregados que são gerentes ou que já tiveram o título de “Senior Engineer”.

-- Empregados que são gerentes
SELECT e.emp_no, e.first_name
FROM employees e
JOIN dept_manager dm ON dm.emp_no = e.emp_no
WHERE dm.to_date = '9999-01-01'
UNION
-- Empregados que já tiveram o título de "Senior Engineer"
SELECT e.emp_no, e.first_name, t.title
FROM employees e
JOIN titles t ON t.emp_no = e.emp_no
WHERE t.title = 'Senior Engineer';

-- Nome dos Gerentes e pegar quem são... uma boa kkkkk
SELECT e.emp_no, e.first_name, t.title
FROM employees e
JOIN dept_manager dm ON dm.emp_no = e.emp_no
JOIN titles t ON t.emp_no = e.emp_no
WHERE dm.to_date = '9999-01-01'
  AND t.to_date = '9999-01-01';


-- 8) ORDER BY
-- Liste os 10 maiores salários atuais, ordenados do maior para o menor.
SELECT e.first_name, s.salary
FROM employees e
JOIN salaries s ON s.emp_no = e.emp_no
	WHERE s.to_date = '9999-01-01'
ORDER BY s.salary DESC
LIMIT 10;


-- 9) Join
-- Liste os nomes e salários dos funcionários com salário acima da média de todos os salários, ordenados em ordem alfabética.
SELECT e.first_name, s.salary
FROM employees e
JOIN salaries s ON s.emp_no = e.emp_no
	WHERE 
		s.to_date = '9999-01-01' AND
		s.salary > (
			SELECT AVG(salary)
			FROM salaries
			WHERE to_date = '9999-01-01'
		)
ORDER BY e.first_name;
