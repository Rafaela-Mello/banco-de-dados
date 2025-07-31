USE employees;

SELECT * FROM departments;
SELECT * FROM dept_emp;
SELECT * FROM dept_manager;
SELECT * FROM employees;
SELECT * FROM salaries;
SELECT * FROM titles;

-- ESTRUTURA
DELIMITER // -- delimita onde começa o trigger
CREATE TRIGGER nome_trigger
BEFORE INSERT ON nome_tabela
FOR EACH ROW -- para cada linha
BEGIN -- comece
	-- estrutura do que quer que faça
END // -- finalize
DELIMITER ; -- delimita onde acaba o trigger

-- ---------------------------------------------------------------------------------------

-- Questões TRIGGERS
-- 1) Trigger para Inserção de Novo Funcionário
/* Crie um trigger que seja acionado antes de inserir um novo funcionário na tabela
employees. O trigger deve verificar se a data de contratação (hire_date) é válida
(não pode ser no futuro). Se for no futuro, deve impedir a inserção e gerar um erro */
-- INSERT
DELIMITER //
CREATE TRIGGER trg_valida_hire_date
BEFORE INSERT ON employees
FOR EACH ROW
BEGIN
	IF NEW.hire_date > CURDATE() THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Erro: A data de contratação não pode estar no futuro.';
    END IF;
END //
DELIMITER ;

INSERT INTO employees (emp_no, birth_date, first_name, last_name, gender, hire_date) -- consegue
	VALUES (1, '2024-12-01', 'Maria', 'Silva', 'F', '2024-12-01');
INSERT INTO employees (emp_no, birth_date, first_name, last_name, gender, hire_date) -- da o erro
	VALUES (2, '2024-12-01', 'Maria', 'Silva', 'F', '2025-12-06');

-- ---------------------------------
SELECT * FROM employees;
-- ---------------------------------

-- UPDATE
DELIMITER //
CREATE TRIGGER trg_valid_hire_date_update
BEFORE UPDATE ON employees
FOR EACH ROW
BEGIN
	IF NEW.hire_date > CURDATE() THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Erro: A data de contratação não pode estar no futuro.';
    END IF;
END //
DELIMITER ;

UPDATE employees -- da o erro
SET hire_date = '2025-06-06'
WHERE emp_no = 1;


-- ----------------------------------------------------------------------------------


-- 2) Trigger para Atualização de Salário
/* Crie um trigger que seja acionado após a atualização do salário na tabela
salaries. O trigger deve verificar se o novo salário é menor que o salário
atual. Se for menor, deve gerar um erro e impedir a atualização do salário */

DELIMITER //
CREATE TRIGGER update_salaryy
BEFORE UPDATE ON salaries -- antes de fazer o update!!!!!!!
FOR EACH ROW
BEGIN
	IF NEW.salary < OLD.salary THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Erro: O salário não pode ser menor do que o atual.';
	END IF;
END //
DELIMITER ;

UPDATE salaries -- vai
SET salary = 10000
WHERE emp_no = 10001 AND to_date = '9999-01-01';

UPDATE salaries
SET salary = 1000 -- da erro
WHERE emp_no = 10001 AND to_date = '9999-01-01';


-- ----------------------------------------------------------------------------------


-- 3) Trigger para Remoção de Funcionário
/* Crie um trigger que seja acionado antes de excluir um funcionário da tabela employees. O
trigger deve verificar se o funcionário está atualmente vinculado a um departamento ou tem
um título. Se sim, a exclusão deve ser impedida e uma mensagem de erro deve ser gerada */

DELIMITER //
CREATE TRIGGER trg_bloqueia_exclusao_funcionario
BEFORE DELETE ON employees
FOR EACH ROW
BEGIN
  -- Verifica se o funcionário tem vínculo com um departamento
  IF EXISTS (
    SELECT 1 FROM dept_emp -- isso significa que não importa quais dados estão sendo retornados — o que importa é verificar se existe pelo menos uma linha que satisfaça a condição
		-- “Existe pelo menos uma linha que satisfaz essa condição?”
    WHERE emp_no = OLD.emp_no AND to_date = '9999-01-01'
  ) THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Erro: Funcionário ainda está vinculado a um departamento.';
  END IF;

  -- Verifica se o funcionário tem título ativo
  IF EXISTS (
    SELECT 1 FROM titles
    WHERE emp_no = OLD.emp_no AND to_date = '9999-01-01'
  ) THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Erro: Funcionário ainda possui um título ativo.';
  END IF;
END //
DELIMITER ;


DELETE FROM employees WHERE emp_no = 10001; -- vai dar o erro




