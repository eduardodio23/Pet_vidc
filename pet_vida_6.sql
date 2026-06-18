USE pet_vida;
SHOW TABLES;
SELECT COUNT(*) FROM animais;
SELECT * FROM animais LIMIT 5;-- PET_VIDA_6: Segurança, GRANT/REVOKE e rotina de backup
USE pet_vida;

-- Procedures de wrapper para perfis específicos
DROP PROCEDURE IF EXISTS sp_agendar;
DELIMITER $$
CREATE PROCEDURE sp_agendar(
    IN p_animal_id INT,
    IN p_vet_id INT,
    IN p_data_hora DATETIME,
    IN p_valor DECIMAL(10,2)
)
BEGIN
    CALL sp_agendar_consulta(p_animal_id, p_vet_id, p_data_hora, p_valor);
END $$

DROP PROCEDURE IF EXISTS sp_concluir;
CREATE PROCEDURE sp_concluir(
    IN p_consulta_id INT,
    IN p_diagnostico TEXT
)
BEGIN
    CALL sp_concluir_consulta(p_consulta_id, p_diagnostico);
END $$

DROP PROCEDURE IF EXISTS sp_cadastrar;
CREATE PROCEDURE sp_cadastrar(
    IN p_nome VARCHAR(50),
    IN p_especie_id INT,
    IN p_raca VARCHAR(50),
    IN p_nascimento DATE,
    IN p_tutor_id INT
)
BEGIN
    CALL sp_cadastrar_animal(p_nome, p_especie_id, p_raca, p_nascimento, p_tutor_id);
END $$
DELIMITER ;

-- Criação dos perfis de usuário
CREATE USER IF NOT EXISTS 'recepcionista'@'localhost' IDENTIFIED BY 'recep123';
CREATE USER IF NOT EXISTS 'veterinario'@'localhost' IDENTIFIED BY 'vet123';
CREATE USER IF NOT EXISTS 'gerente'@'localhost' IDENTIFIED BY 'gerente123';
CREATE USER IF NOT EXISTS 'admin'@'localhost' IDENTIFIED BY 'admin123';

-- Recepcionista
GRANT SELECT, INSERT ON pet_vida.tutores TO 'recepcionista'@'localhost';
GRANT SELECT, INSERT ON pet_vida.animais TO 'recepcionista'@'localhost';
GRANT SELECT, INSERT ON pet_vida.consultas TO 'recepcionista'@'localhost';
GRANT SELECT, INSERT ON pet_vida.especies TO 'recepcionista'@'localhost';
GRANT EXECUTE ON PROCEDURE pet_vida.sp_agendar TO 'recepcionista'@'localhost';
GRANT EXECUTE ON PROCEDURE pet_vida.sp_cadastrar TO 'recepcionista'@'localhost';

-- Veterinário
GRANT SELECT ON pet_vida.* TO 'veterinario'@'localhost';
GRANT UPDATE (diagnostico, status) ON pet_vida.consultas TO 'veterinario'@'localhost';
GRANT EXECUTE ON PROCEDURE pet_vida.sp_concluir TO 'veterinario'@'localhost';

-- Gerente
GRANT SELECT, INSERT, UPDATE ON pet_vida.* TO 'gerente'@'localhost';
GRANT DELETE ON pet_vida.consultas TO 'gerente'@'localhost';
GRANT EXECUTE ON PROCEDURE pet_vida.sp_agendar TO 'gerente'@'localhost';
GRANT EXECUTE ON PROCEDURE pet_vida.sp_concluir TO 'gerente'@'localhost';
GRANT EXECUTE ON PROCEDURE pet_vida.sp_cadastrar TO 'gerente'@'localhost';

-- Admin
GRANT ALL PRIVILEGES ON pet_vida.* TO 'admin'@'localhost' WITH GRANT OPTION;

-- Revoga acessos da recepcionista como solicitado
REVOKE EXECUTE ON PROCEDURE pet_vida.sp_agendar FROM 'recepcionista'@'localhost';
REVOKE EXECUTE ON PROCEDURE pet_vida.sp_cadastrar FROM 'recepcionista'@'localhost';
REVOKE SELECT, INSERT ON pet_vida.tutores FROM 'recepcionista'@'localhost';
REVOKE SELECT, INSERT ON pet_vida.animais FROM 'recepcionista'@'localhost';
REVOKE SELECT, INSERT ON pet_vida.consultas FROM 'recepcionista'@'localhost';
REVOKE SELECT, INSERT ON pet_vida.especies FROM 'recepcionista'@'localhost';

FLUSH PRIVILEGES;

SHOW GRANTS FOR 'admin'@'localhost';
-- Rotina de backup em database/backup.sh
-- Execute no shell:
-- chmod +x database/backup.sh
-- DB_USER=root DB_PASS=suasenha ./database/backup.sh
