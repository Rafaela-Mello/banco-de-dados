-- Atividade BD2

SELECT * FROM employees;
SELECT * FROM salaries;
SELECT * FROM titles;
SELECT * FROM departments;
SELECT * FROM dept_emp;
SELECT * FROM dept_manager;

/*
1° Usando INNER JOIN
	Utilizando a base de dados "employees", faça uma consulta com INNER JOIN para obter detalhes sobre
    os funcionários, incluindo o número do funcionário, nome do departamento em que trabalham e o salário
    atual. A consulta deve incluir apenas os funcionários atuais (cuja data de término é '9999-01-01').
*/
    
SELECT
    em.emp_no AS "N° Funcionário",
    em.first_name AS "Nome",
    d.dept_name AS "Departamento",
    s.salary AS "Salário"
FROM
    employees em
INNER JOIN
    dept_emp de ON em.emp_no = de.emp_no
INNER JOIN
    departments d ON de.dept_no = d.dept_no
INNER JOIN
    salaries s ON em.emp_no = s.emp_no
WHERE
    de.to_date = '9999-01-01'
    AND s.to_date = '9999-01-01';

-- ------------------------------------------------------------------------------------------------

/*
2° Usando LEFT JOIN e GROUP BY
	Escreva uma consulta que exiba a média salarial por departamento, considerando apenas os funcionários
	atuais (data de término '9999-01-01'). Utilize LEFT JOIN para incluir todos os departamentos, mesmo
	aqueles sem funcionários, e aplique GROUP BY para calcular a média salarial de cada departamento.
	Ordene o resultado pelo salário.
*/

SELECT
    d.dept_name AS "Departamento",
    AVG(s.salary) AS "Média Salarial"
FROM
    departments d
LEFT JOIN
    dept_emp de ON d.dept_no = de.dept_no AND de.to_date = '9999-01-01'
LEFT JOIN
    salaries s ON de.emp_no = s.emp_no AND s.to_date = '9999-01-01'
GROUP BY
    d.dept_name
ORDER BY
    AVG(s.salary) DESC;

-- ------------------------------------------------------------------------------------------------

/*
3° Subconsultas na cláusula WHERE
	Crie uma consulta que retorne todos os funcionários que ganham mais do que a média salarial da
	empresa. Utilize uma subconsulta na cláusula WHERE para comparar os salários individuais com a média
	salarial global. Utilize apenas os salários atuais (data de término '9999-01-01').
*/

SELECT
	em.emp_no AS "Código Func.",
    em.first_name AS "Funcionário",
    s.salary AS "Salário > Média"
FROM
    employees em
INNER JOIN
    salaries s ON em.emp_no = s.emp_no
WHERE
    s.to_date = '9999-01-01'
    AND s.salary > (
        SELECT AVG(salary)
        FROM salaries
        WHERE to_date = '9999-01-01'
    );

-- ------------------------------------------------------------------------------------------------

/*
4° Subconsultas nos atributos
	Escreva uma consulta que retorne todos os funcionários junto com o departamento atual em que
	trabalham. Utilize subconsultas nos atributos para obter as informações do departamento com base nas
	tabelas relacionadas.
*/

SELECT
	em.emp_no AS "Código Func.",
    em.first_name AS "Funcionário",
    (
        SELECT d.dept_name
        FROM dept_emp de
        JOIN departments d ON d.dept_no = de.dept_no
        WHERE de.emp_no = em.emp_no
          AND de.to_date = '9999-01-01'
        LIMIT 1
    ) AS "Departamento Atual"
FROM
    employees em;

-- ------------------------------------------------------------------------------------------------

/*
5° Consulta com RANK(), OVER(), PARTITION BY
	Elabore uma consulta que retorne os 10 maiores salários por departamento, considerando apenas os
    salários atuais (com a data de término do salário igual a '9999-01-01')
*/

SELECT * FROM (
    SELECT
        d.dept_name AS "Departamento",
        em.first_name AS "Funcionário",
        s.salary AS "Salário",
        RANK() OVER (PARTITION BY d.dept_no ORDER BY s.salary DESC) AS posicao
    FROM
        employees em
    INNER JOIN salaries s ON em.emp_no = s.emp_no
    INNER JOIN dept_emp de ON em.emp_no = de.emp_no
    INNER JOIN departments d ON de.dept_no = d.dept_no
    WHERE
        s.to_date = '9999-01-01'
        AND de.to_date = '9999-01-01'
) AS ranking
WHERE posicao <= 10;