USE employees;

SELECT * FROM departments;
SELECT * FROM dept_emp;
SELECT * FROM dept_manager;
SELECT * FROM employees;
SELECT * FROM salaries;
SELECT * FROM titles;

-- Questões Avançadas

-- 1) LEFT JOIN
-- Liste todos os funcionários, mostrando também o título atual, se houver. Funcionários sem título atual devem aparecer com NULL.
SELECT e.first_name, t.title
FROM employees e
LEFT JOIN titles t ON t.emp_no = e.emp_no
	WHERE t.to_date = '9999-01-01';
/*
Problema: o LEFT JOIN vira, na prática, um INNER JOIN.
Ao aplicar o filtro t.to_date = '9999-01-01' depois do JOIN, ele elimina as linhas onde t é NULL.
Ou seja, funcionários sem título atual (com t NULL) são excluídos do resultado.
*/

SELECT e.first_name, t.title
FROM employees e
LEFT JOIN titles t ON t.emp_no = e.emp_no AND t.to_date = '9999-01-01';
/*
A condição t.to_date = '9999-01-01' faz parte do JOIN, então ele só tenta unir
registros de títulos atuais, mas não filtra fora da tabela principal (employees).
	Com isso, funcionários sem título atual aparecem com NULL no t.title.
*/

-- ------------------------------------------------------------------------------------------

-- 2) RIGHT JOIN
-- Liste todos os títulos existentes com os nomes dos empregados atuais que os possuem, mesmo que o título não esteja associado a nenhum funcionário no momento.

-- "Todos os funcionários, mesmo que não tenham títulos correspondentes"
SELECT e.first_name, e.last_name, t.title
FROM titles t
RIGHT JOIN employees e ON t.emp_no = e.emp_no AND t.to_date = '9999-01-01';

-- "Todos os títulos, mesmo que não tenham funcionários correspondentes"
SELECT e.first_name, e.last_name, t.title
FROM employees e
RIGHT JOIN titles t ON t.emp_no = e.emp_no AND t.to_date = '9999-01-01';

-- ------------------------------------------------------------------------------------------

-- 3) ANTI LEFT JOIN 
-- Liste os empregados que não possuem nenhum título atual (funcionários sem título atual)
SELECT e.emp_no, e.first_name, e.last_name
FROM employees e
LEFT JOIN titles t ON e.emp_no = t.emp_no AND t.to_date = '9999-01-01'
	WHERE t.emp_no IS NULL;

-- ------------------------------------------------------------------------------------------

-- 4) GROUP BY e HAVING
/* Liste os títulos e a quantidade de empregados com esse título atualmente, 
apenas os títulos com mais de 1000 funcionários.*/
SELECT title, COUNT(*) as 'quantidade'
FROM titles
	WHERE to_date = '9999-01-01'
GROUP BY title
HAVING COUNT(*) > 1000;

-- ------------------------------------------------------------------------------------------

-- 5) Subconsulta no WHERE
-- Liste os nomes dos funcionários cujo salário atual é maior do que a média dos salários atuais.
SELECT e.first_name, s.salary
FROM employees e
JOIN salaries s ON s.emp_no = e.emp_no
	WHERE 
		s.to_date = '9999-01-01' AND
		s.salary > (
			SELECT AVG(salary)
			FROM salaries
            WHERE to_date = '9999-01-01'
		);

-- ------------------------------------------------------------------------------------------

-- 6) Subconsulta no FROM
/* Liste os nomes dos funcionários e seus salários atuais, junto com
a média de salário geral (trazida de uma subconsulta no FROM) */

SELECT e.first_name, s.salary, avg_salaries.avg_sal
FROM employees e
JOIN salaries s ON e.emp_no = s.emp_no
JOIN (
    SELECT AVG(salary) AS avg_sal
    FROM salaries
    WHERE to_date = '9999-01-01'
) AS avg_salaries ON 1=1
WHERE s.to_date = '9999-01-01';

-- ------------------------------------------------------------------------------------------

-- 7) Subconsulta em uma coluna
-- Liste o nome de cada funcionário e, em uma segunda coluna, o maior salário que ele já recebeu.

SELECT e.first_name, (
	SELECT MAX(salary)
    FROM salaries s
    WHERE e.emp_no = s.emp_no
) AS maior_salario
FROM employees e;

-- ------------------------------------------------------------------------------------------

-- 8) CONCAT
-- Mostre o nome completo dos funcionários (nome e sobrenome) em uma única coluna chamada nome_completo.

SELECT CONCAT (first_name, ' ',last_name) AS nome_completo
FROM employees;

-- ------------------------------------------------------------------------------------------

-- 9) Subconsulta que retorna várias tuplas com IN
/* Liste os nomes dos funcionários que já tiveram os mesmos
salários que qualquer funcionário com o título de “Manager” */

SELECT e.first_name, s.salary
FROM employees e
JOIN salaries s ON s.emp_no = e.emp_no
	WHERE s.to_date = '9999-01-01' AND
		s.salary IN (
			SELECT s2.salary
			FROM salaries s2
            JOIN titles t ON t.emp_no = s2.emp_no
			WHERE title = 'Senior Engineer'
		);

-- ------------------------------------------------------------------------------------------

-- 10) Função de janela ROW_NUMBER()
/* Numere todos os salários atuais em ordem decrescente para
saber quem são os funcionários com os maiores salários */

SELECT e.first_name, s.salary,
	ROW_NUMBER() OVER(ORDER BY s.salary DESC) AS posicao
FROM employees e
JOIN salaries s ON e.emp_no = s.emp_no
	WHERE s.to_date = '9999-01-01';

-- ------------------------------------------------------------------------------------------

-- 11) Funções de janela: RANK(), PARTITION BY, SUM() OVER
/* Para cada departamento, classifique os salários atuais dos funcionários com
RANK() e exiba também a soma acumulada dos salários por departamento */

SELECT e.emp_no, e.first_name, de.dept_no, s.salary,
       RANK() OVER (PARTITION BY de.dept_no ORDER BY s.salary DESC) AS ranking,
       SUM(s.salary) OVER (PARTITION BY de.dept_no ORDER BY s.salary DESC) AS soma_acumulada
FROM employees e
JOIN salaries s ON e.emp_no = s.emp_no AND s.to_date = '9999-01-01'
JOIN dept_emp de ON e.emp_no = de.emp_no AND de.to_date = '9999-01-01';


