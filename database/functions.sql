USE pet_vida;

-- 1) Idade do animal: retorna "X anos e Y meses"
DROP FUNCTION IF EXISTS fn_idade_animal;
DELIMITER $$
CREATE FUNCTION fn_idade_animal(p_data_nascimento DATE)
RETURNS VARCHAR(50)
DETERMINISTIC
BEGIN
    DECLARE v_anos INT DEFAULT 0;
    DECLARE v_meses INT DEFAULT 0;
    IF p_data_nascimento IS NULL THEN
        RETURN NULL;
    END IF;
    SET v_anos = TIMESTAMPDIFF(YEAR, p_data_nascimento, CURDATE());
    SET v_meses = TIMESTAMPDIFF(MONTH, p_data_nascimento, CURDATE()) - (v_anos * 12);
    RETURN CONCAT(v_anos, ' anos e ', v_meses, ' meses');
END $$
DELIMITER ;

-- 2) Total gasto por tutor (soma o valor de consultas dos animais desse tutor, exceto canceladas)
DROP FUNCTION IF EXISTS fn_total_gasto_tutor;
DELIMITER $$
CREATE FUNCTION fn_total_gasto_tutor(p_tutor_id INT)
RETURNS DECIMAL(12,2)
DETERMINISTIC
BEGIN
    DECLARE v_total DECIMAL(12,2) DEFAULT 0.00;
    SELECT IFNULL(SUM(c.valor), 0.00) INTO v_total
    FROM consultas c
    INNER JOIN animais a ON c.animal_id = a.id_animal
    WHERE a.tutor_id = p_tutor_id
      AND c.status != 'cancelada';
    RETURN v_total;
END $$
DELIMITER ;

-- 3) Quantidade de consultas de um animal
DROP FUNCTION IF EXISTS fn_qtd_consultas_animal;
DELIMITER $$
CREATE FUNCTION fn_qtd_consultas_animal(p_animal_id INT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE v_qtd INT DEFAULT 0;
    SELECT COUNT(*) INTO v_qtd
    FROM consultas
    WHERE animal_id = p_animal_id;
    RETURN v_qtd;
END $$
DELIMITER ;

-- 4) Status com emoji
DROP FUNCTION IF EXISTS fn_status_emoji;
DELIMITER $$
CREATE FUNCTION fn_status_emoji(p_status VARCHAR(50))
RETURNS VARCHAR(50)
DETERMINISTIC
BEGIN
    RETURN CASE p_status
        WHEN 'agendada' THEN 'Agendada'
        WHEN 'concluida' THEN 'Concluida'
        WHEN 'cancelada' THEN 'Cancelada'
        WHEN 'em_atendimento' THEN 'Em Atendimento'
        ELSE p_status
    END;
END $$
DELIMITER ;

-- 5) Classificar valor
DROP FUNCTION IF EXISTS fn_classificar_valor;
DELIMITER $$
CREATE FUNCTION fn_classificar_valor(p_valor DECIMAL(10,2))
RETURNS VARCHAR(50)
DETERMINISTIC
BEGIN
    RETURN CASE
        WHEN p_valor < 100 THEN 'Consulta Simples'
        WHEN p_valor BETWEEN 100 AND 300 THEN 'Consulta Padrão'
        ELSE 'Procedimento Especial'
    END;
END $$
DELIMITER ;

-- Testes em SELECTs reais
SELECT nome, fn_idade_animal(data_nascimento) AS idade FROM animais;
SELECT nome, fn_total_gasto_tutor(id_tutor) AS total_gasto FROM tutores;
SELECT nome, fn_qtd_consultas_animal(id_animal) AS qtd_consultas FROM animais;
SELECT id_consulta, status, fn_status_emoji(status) AS status_emoji FROM consultas;
SELECT id_consulta, valor, fn_classificar_valor(valor) AS classificacao FROM consultas;
