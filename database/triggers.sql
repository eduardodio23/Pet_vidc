USE pet_vida;

CREATE TABLE IF NOT EXISTS log_auditoria (
    id INT AUTO_INCREMENT PRIMARY KEY,
    tabela_afetada VARCHAR(100) NOT NULL,
    acao VARCHAR(50) NOT NULL,
    registro_id INT NOT NULL,
    detalhes TEXT,
    data_hora TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DROP TRIGGER IF EXISTS trg_after_insert_consulta;
DROP TRIGGER IF EXISTS trg_after_update_consulta_status;
DROP TRIGGER IF EXISTS trg_before_delete_consulta;
DROP TRIGGER IF EXISTS trg_after_insert_animal;
DROP TRIGGER IF EXISTS trg_before_update_pagamento;

DELIMITER $$

CREATE TRIGGER trg_after_insert_consulta
AFTER INSERT ON consultas
FOR EACH ROW
BEGIN
    INSERT INTO log_auditoria (tabela_afetada, acao, registro_id, detalhes)
    VALUES (
        'consultas',
        'INSERT',
        NEW.id_consulta,
        CONCAT('Nova consulta para animal_id=', NEW.animal_id, ', valor=', NEW.valor, ', status=', NEW.status)
    );
END $$

CREATE TRIGGER trg_after_update_consulta_status
AFTER UPDATE ON consultas
FOR EACH ROW
BEGIN
    IF NOT (OLD.status <=> NEW.status) THEN
        INSERT INTO log_auditoria (tabela_afetada, acao, registro_id, detalhes)
        VALUES (
            'consultas',
            'UPDATE',
            NEW.id_consulta,
            CONCAT('status de ', OLD.status, ' para ', NEW.status)
        );
    END IF;
END $$

CREATE TRIGGER trg_before_delete_consulta
BEFORE DELETE ON consultas
FOR EACH ROW
BEGIN
    IF EXISTS (SELECT 1 FROM pagamentos WHERE consulta_id = OLD.id_consulta AND status = 'pago') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Não é permitido excluir consulta com pagamento pago';
    END IF;
    IF OLD.status != 'cancelada' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Só é permitido excluir consultas canceladas';
    END IF;
END $$

CREATE TRIGGER trg_after_insert_animal
AFTER INSERT ON animais
FOR EACH ROW
BEGIN
    INSERT INTO log_auditoria (tabela_afetada, acao, registro_id, detalhes)
    VALUES (
        'animais',
        'INSERT',
        NEW.id_animal,
        CONCAT('Novo animal ', NEW.nome, ' cadastrado para tutor_id=', NEW.tutor_id)
    );
END $$

CREATE TRIGGER trg_before_update_pagamento
BEFORE UPDATE ON pagamentos
FOR EACH ROW
BEGIN
    IF NOT (OLD.status <=> NEW.status) AND NEW.status = 'pago' THEN
        SET NEW.data_pagamento = CURDATE();
    END IF;
END $$

DELIMITER ;

-- Testes sugeridos:
-- INSERT INTO consultas (animal_id, veterinario_id, data_hora, diagnostico, valor, status) VALUES (1,1,NOW(), 'Teste', 120.00, 'agendada');
-- UPDATE consultas SET status = 'concluida' WHERE id_consulta = <id>;
-- DELETE FROM consultas WHERE id_consulta = <id>;
-- UPDATE pagamentos SET status = 'pago' WHERE id_pagamento = <id>;
