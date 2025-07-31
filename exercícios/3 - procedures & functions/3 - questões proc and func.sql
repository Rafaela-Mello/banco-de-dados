USE employees;

SELECT * FROM departments;
SELECT * FROM dept_emp;
SELECT * FROM dept_manager;
SELECT * FROM employees;
SELECT * FROM salaries;
SELECT * FROM titles;

-- Questões Procedimentos

-- 1) Procedimento para Retornar Títulos de um Funcionário
/* Crie um procedimento chamado GetEmployeeTitles que recebe o número do funcionário (emp_no) como
parâmetro e retorna todos os títulos associados a esse funcionário, junto com as datas de início e fim */
DELIMITER //
CREATE PROCEDURE GetEmployeeTitles (IN num_func INT)
BEGIN
	SELECT e.first_name, t.title, t.from_date, t.to_date
    FROM employees e
    JOIN titles t ON e.emp_no = t.emp_no
		WHERE
			e.emp_no = num_func; -- fazer a relação do valor inserido com a tabela
END //
DELIMITER ;

CALL GetEmployeeTitles (10007);

-- testar se tem mais de um titulos
SELECT * FROM titles WHERE emp_no = 10007;



-- 2) Procedimento para Retornar Funcionários Dentro de um Intervalo de Salário
/* Crie um procedimento chamado GetEmployeesBySalaryRange que recebe dois parâmetros:
min_salary e max_salary. Esse procedimento deve retornar todos os funcionários cujo
salário esteja dentro desse, juntamente com o salário e o nome do funcionário */
DROP PROCEDURE IF EXISTS GetEmployeesBySalaryRange;

DELIMITER //
CREATE PROCEDURE GetEmployeesBySalaryRange(IN min_salary INT, IN max_salary INT)
BEGIN
	SELECT e.first_name, s.salary
    FROM employees e
    JOIN salaries s ON s.emp_no = e.emp_no
		WHERE
			s.to_date = '9999-01-01' AND
			s.salary BETWEEN min_salary AND max_salary;
END //
DELIMITER ;

CALL GetEmployeesBySalaryRange(60000, 66000);



-- 3) Procedimento para Atualizar o Salário de um Funcionário
/* Crie um procedimento chamado UpdateEmployeeSalary que recebe um emp_no e um novo valor de salário.
Ele deve atualizar o salário do funcionário especificado, mas antes de fazer a alteração, ele deve
verificar se o novo salário é maior do que o salário anterior. Caso contrário, ele deve lança um erro */

DELIMITER //
CREATE PROCEDURE UpdateEmployeeSalary(IN codigo INT, IN novo_salario INT)
BEGIN
    DECLARE salario_atual INT;

	-- Buscar o salário atual
    SELECT salary INTO salario_atual -- INTO serve para capturar resultados de uma consulta e guardar
    FROM salaries                -- dentro de uma variável declarada com DECLARE no início do proc/func.
    WHERE emp_no = codigo AND to_date = '9999-01-01';

	-- Verificar se o novo salário é maior
    IF novo_salario <= salario_atual THEN
        SIGNAL SQLSTATE '45000' -- comando SIGNAL é usado para lançar um erro personalizado
        						-- o código '45000' é um código de erro genérico definido pelo usuário
        SET MESSAGE_TEXT = 'O novo salário deve ser maior que o salário atual.';
			-- comando SET é usado para atribuir um valor a uma variável ou definir um parâmetro
    ELSE
        -- Encerrar o salário anterior
        UPDATE salaries
        SET to_date = CURDATE() -- from_date = CURDATE() → a data de início é hoje
        WHERE emp_no = codigo AND to_date = '9999-01-01'; -- to_date = '9999-01-01' → indica que este é o salário vigente

        -- Inserir novo salário
        INSERT INTO salaries (emp_no, salary, from_date, to_date)
        VALUES (codigo, novo_salario, CURDATE(), '9999-01-01');
    END IF;
END //
DELIMITER ;

SELECT * FROM salaries;
CALL UpdateEmployeeSalary(10001, 90000);



-- ------------------------------------------------------------------------------------------



-- Questões sobre Funções

-- 1) Função para Calcular o Número de Funcionários em um Departamento
/* Crie uma função chamada GetDepartmentEmployeeCount que recebe o número do departamento (dept_no)
como parâmetro e retorna o número total de funcionários alocados nesse departamento */

DELIMITER //
CREATE FUNCTION GetDepartmentEmployeeCount (num_dept INT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE total_func INT;

    -- conta os funcionários do departamento informado
    SELECT COUNT(*) INTO total_func
    FROM dept_emp
    WHERE dept_no = num_dept;

    RETURN total_func;
END //
DELIMITER ;

-- usar a função no select
SELECT GetDepartmentEmployeeCount('d005') AS total_funcionarios;
--
SELECT d.dept_name, GetDepartmentEmployeeCount(d.dept_no) AS total_funcionarios
FROM departments d;
--
SELECT d.dept_name, GetDepartmentEmployeeCount(d.dept_no) AS total_funcionarios
FROM departments d
WHERE d.dept_no = 'd005';



-- 2) Função para Calcular Média de Salário de um Funcionário
/* Crie uma função chamada CalculateAverageSalary que recebe um emp_no como parâmetro
e retorna o salário médio de todos os títulos desse funcionário ao longo do tempo */

DELIMITER //
CREATE FUNCTION CalculateAverageSalaryByTitle (codigo INT, cargo VARCHAR(50))
RETURNS FLOAT
DETERMINISTIC
BEGIN
    DECLARE salary_avg FLOAT;
    
    SELECT AVG(s.salary) INTO salary_avg
    FROM salaries s
    JOIN titles t ON t.emp_no = s.emp_no
    WHERE s.emp_no = codigo
      AND t.title = cargo
      AND s.from_date BETWEEN t.from_date AND t.to_date;
    
    RETURN salary_avg;
END //
DELIMITER ;

SELECT CalculateAverageSalaryByTitle(10001, 'Senior Engineer') AS media_por_titulo;

SELECT e.first_name, CalculateAverageSalaryByTitle(e.emp_no, 'Senior Engineer') AS media_por_titulo
FROM employees e
WHERE e.emp_no = 10001;



-- 3) Função para Determinar o Status de um Funcionário
/* Crie uma função chamada GetEmployeeStatus que recebe o emp_no de um funcionário e retorna um texto com a
situação do funcionário. Se o salário do func. for maior que 50.000, o status deve ser "Alto Salário",
caso contrário, "Baixo Salário". Se o func. estiver sem título atual, o status deve ser "Sem Título" */
DROP FUNCTION IF EXISTS GetEmployeeStatus;

DELIMITER //
CREATE FUNCTION GetEmployeeStatus (codigo INT)
RETURNS VARCHAR(100)
DETERMINISTIC
BEGIN
    DECLARE salario_atual INT;
    DECLARE titulo_atual VARCHAR(100);

    -- Buscar salário atual
    SELECT salary INTO salario_atual
    FROM salaries
    WHERE emp_no = codigo AND to_date = '9999-01-01'
    LIMIT 1;

    -- Buscar título atual
    SELECT title INTO titulo_atual
    FROM titles
    WHERE emp_no = codigo AND to_date = '9999-01-01'
    LIMIT 1;

    -- Verificar se tem título
    IF titulo_atual IS NULL THEN
        RETURN 'Sem Título';
    ELSEIF salario_atual > 50000 THEN
        RETURN 'Alto Salário';
    ELSE
        RETURN 'Baixo Salário';
    END IF;
END //
DELIMITER ;

SELECT emp_no, GetEmployeeStatus(emp_no) AS `status`
FROM employees
WHERE emp_no = 10001;

