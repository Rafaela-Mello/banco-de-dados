-- PROVA DE TERÇA

-- questão 1 - LETRA A
SELECT * FROM employees;
SELECT * FROM dept_manager;

-- -------------------------------------------------------------------------------------------------------------------

-- questão 2 - LETRA B

-- -------------------------------------------------------------------------------------------------------------------

-- questão 3 - LETRA A

-- -------------------------------------------------------------------------------------------------------------------

-- questão 4 - explicação:
/*
- JOIN: Une as tabelas departments (d) e dept_manager (dm) com base no código do departamento (dept_no).
	Permite obter os nomes dos departamentos junto com suas informações de gerentes.
- WHERE dm.to_date = '9999-01-01': Filtra apenas os registros de gerentes atuais, assumindo que a data 9999-01-01 indica
	vínculo ainda ativo com o departamento.
- GROUP BY d.dept_name: Agrupa os resultados por nome do departamento.
	Isso permite contar quantos gerentes ativos cada departamento possui.
- HAVING qtd_gerentes > 1: Filtra os grupos (departamentos) para manter somente aqueles que têm mais de um gerente ativo.
*/

-- -------------------------------------------------------------------------------------------------------------------

-- questão 5
/*
Classifica um salário em três categorias:
	'Baixo': se o salário for menor que 40.000.
	'Médio': se o salário for maior ou igual a 40.000 e menor que 80.000.
	'Alto': se o salário for igual ou superior a 80.000.
Ela retorna uma string (VARCHAR(20)) com essa classificação.
*/
-- Exemplo:
SELECT emp_no, salary, classifica_salario(salary) AS classificacao
FROM salaries
WHERE to_date = '9999-01-01';

-- -------------------------------------------------------------------------------------------------------------------

-- questão 6
CREATE VIEW vw_departamentos_atuais AS
	SELECT de.emp_no, d.dept_name, de.from_date
	FROM dept_emp de
	JOIN departments d ON de.dept_no = d.dept_no
	JOIN employees e ON de.emp_no = e.emp_no
	WHERE de.to_date = '9999-01-01';

SELECT * FROM vw_departamentos_atuais;

-- -------------------------------------------------------------------------------------------------------------------

-- questão 7
DELIMITER //
CREATE PROCEDURE buscar_por_departamento(IN cod_departamento CHAR(4))
BEGIN
    SELECT e.emp_no, e.first_name, e.last_name, d.dept_name
    FROM employees e
    JOIN dept_emp de ON e.emp_no = de.emp_no
    JOIN departments d ON de.dept_no = d.dept_no
    WHERE 
        de.to_date = '9999-01-01'
        AND de.dept_no = cod_departamento;
END //
DELIMITER ;

CALL buscar_por_departamento('d001');

-- -------------------------------------------------------------------------------------------------------------------

-- questão 8
CREATE TABLE log_admissoes (
	emp_no INT,
    nome_completo VARCHAR(32),
    data_admissao DATE,
    registrado_em DATETIME
);

DELIMITER //
CREATE TRIGGER trg_log_admissao
AFTER INSERT ON employees -- depois que inserir o funcionário, ele faz esse trigger!!!
FOR EACH ROW
BEGIN
  INSERT INTO log_admissoes (emp_no, nome_completo, data_admissao, registrado_em)
  VALUES (
    NEW.emp_no,
    CONCAT(NEW.first_name, ' ', NEW.last_name),
    NEW.hire_date,
    NOW()
  );
END //
DELIMITER ;

INSERT INTO employees (emp_no, birth_date, first_name, last_name, gender, hire_date)
	VALUES (11, '1995-07-10', 'João', 'Silva', 'M', '2025-02-05');

SELECT * FROM employees;
SELECT * FROM log_admissoes WHERE emp_no = 11;