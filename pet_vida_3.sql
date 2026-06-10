USE pet_vida;

DELIMITER $$


DROP PROCEDURE IF EXISTS sp_agendar_consulta $$
CREATE PROCEDURE sp_agendar_consulta(
    IN p_animal_id INT,
    IN p_vet_id INT,
    IN p_data_hora DATETIME,
    IN p_valor DECIMAL(10, 2)
)
BEGIN
    DECLARE v_consulta_id INT;
    

    DECLARE EXIT HANDLER FOR SQLEXCEPTION 
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    -- VALIDAÇÕES:
    IF NOT EXISTS (SELECT 1 FROM animais WHERE id_animal = p_animal_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Erro: Animal não encontrado.';
    END IF;

    
    IF NOT EXISTS (SELECT 1 FROM veterinarios WHERE id_veterinario = p_vet_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Erro: Veterinário não encontrado.';
    END IF;

   
    IF EXISTS (SELECT 1 FROM consultas WHERE veterinario_id = p_vet_id AND data_hora = p_data_hora AND status != 'cancelada') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Erro: Veterinário indisponível neste horário.';
    END IF;

    
    START TRANSACTION;
    
   
    INSERT INTO consultas (animal_id, veterinario_id, data_hora, diagnostico, valor, status)
    VALUES (p_animal_id, p_vet_id, p_data_hora, NULL, p_valor, 'agendada');
    
    
    SET v_consulta_id = LAST_INSERT_ID();
    
    
    INSERT INTO pagamentos (consulta_id, valor_pago, forma_pagamento, data_pagamento, status)
    VALUES (v_consulta_id, p_valor, 'dinheiro', DATE(p_data_hora), 'pendente');
    
    COMMIT;
END $$


DROP PROCEDURE IF EXISTS sp_concluir_consulta $$
CREATE PROCEDURE sp_concluir_consulta(
    IN p_consulta_id INT,
    IN p_diagnostico TEXT
)
BEGIN
   -- VALIDAÇÃO DE CONSULTA EXISTENTE
    IF NOT EXISTS (SELECT 1 FROM consultas WHERE id_consulta = p_consulta_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Erro: Consulta não encontrada.';
    END IF;

    -- ATUALIZA A CONSULTA
    UPDATE consultas 
    SET status = 'concluida', diagnostico = p_diagnostico 
    WHERE id_consulta = p_consulta_id;
END $$




DROP PROCEDURE IF EXISTS sp_registrar_pagamento $$
CREATE PROCEDURE sp_registrar_pagamento(
    IN p_consulta_id INT,
    IN p_forma ENUM('pix', 'cartao', 'dinheiro', 'convenio')
)
BEGIN
    DECLARE v_status_atual VARCHAR(20);

    -- VALIDAÇÕES DE PAGAMENTO E ATUALIZAÇÃO DE STATUS
    SELECT status INTO v_status_atual FROM pagamentos WHERE consulta_id = p_consulta_id;
    
    IF v_status_atual IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Erro: Pagamento não encontrado para esta consulta.';
    END IF;

  
    IF v_status_atual = 'pago' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Erro: Este pagamento já foi realizado.';
    END IF;

  
    UPDATE pagamentos 
    SET status = 'pago', forma_pagamento = p_forma, data_pagamento = CURDATE()
    WHERE consulta_id = p_consulta_id;
END $$




DROP PROCEDURE IF EXISTS sp_cancelar_consulta $$
CREATE PROCEDURE sp_cancelar_consulta(
    IN p_consulta_id INT
)
BEGIN
   
    DECLARE EXIT HANDLER FOR SQLEXCEPTION 
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    
    IF NOT EXISTS (SELECT 1 FROM consultas WHERE id_consulta = p_consulta_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Erro: Consulta não encontrada.';
    END IF;

    START TRANSACTION;
    
    
    UPDATE consultas SET status = 'cancelada' WHERE id_consulta = p_consulta_id;
    
   
    UPDATE pagamentos SET status = 'cancelado' WHERE consulta_id = p_consulta_id;
    
    COMMIT;
END $$



DROP PROCEDURE IF EXISTS sp_cadastrar_animal $$
CREATE PROCEDURE sp_cadastrar_animal(
    IN p_nome VARCHAR(50),
    IN p_especie_id INT,
    IN p_raca VARCHAR(50),
    IN p_nascimento DATE,
    IN p_tutor_id INT
)
BEGIN
    -- VALIDAÇÕES PARA CADASTRO DE PET
    IF NOT EXISTS (SELECT 1 FROM especies WHERE id_especie = p_especie_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Erro: Espécie não cadastrada.';
    END IF;

    
    IF NOT EXISTS (SELECT 1 FROM tutores WHERE id_tutor = p_tutor_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Erro: Tutor não encontrado.';
    END IF;

    
    INSERT INTO animais (nome, especie_id, raca, sexo, peso, data_nascimento, tutor_id)
    VALUES (p_nome, p_especie_id, p_raca, NULL, 0.1, p_nascimento, p_tutor_id);
    
  
    SELECT LAST_INSERT_ID() AS id_animal_cadastrado;
END $$

DELIMITER ;

-- SUCESSO: Agendando consulta válida (Animal 1, Vet 1)
CALL sp_agendar_consulta(1, 1, '2026-06-06 15:00:00', 150.00);

-- ERRO: Ao Tentar agendar no mesmo horário e vet (vai disparar o SIGNAL)
CALL sp_agendar_consulta(2, 1, '2026-06-06 15:00:00', 120.00);

-- ERRO: Animal inexistente (Animal 999)
CALL sp_agendar_consulta(999, 1, '2026-06-06 10:00:00', 100.00);


-- SUCESSO: Concluindo a consulta agendada acima (usando o id 21)
CALL sp_concluir_consulta(21, 'Animal saudável, vacina aplicada com sucesso.');

-- ERRO: Ao  Tentar concluir consulta que não existe (usando o id 999)
CALL sp_concluir_consulta(999, 'Diagnóstico fake');

-- SUCESSO: Pagar a consulta concluída acima usando pix
CALL sp_registrar_pagamento(21, 'pix');

-- Preparação: Agendar uma nova consulta para testar o cancelamento
CALL sp_agendar_consulta(3, 2, '2026-06-10 10:00:00', 200.00);

-- SUCESSO: Cancelar a consulta (ID gerado foi 22). 
-- Vai atualizar consultas e pagamentos via transação.
CALL sp_cancelar_consulta(22);

-- ERRO: Cancelar consulta inexistente
CALL sp_cancelar_consulta(999);

-- SUCESSO: Cadastrar um novo Cachorro (espécie 1) para o Tutor 1
CALL sp_cadastrar_animal('Max', 1, 'Bulldog', '2026-06-10', 1);

-- ERRO: Espécie inexistente (Espécie 99)
CALL sp_cadastrar_animal('Rex II', 99, 'Pug', '2026-06-11', 1);


-- ERRO: Tutor inexistente (Tutor 999)
CALL sp_cadastrar_animal('Bolinha', 2, 'SRD', '2020-05-05', 999);

