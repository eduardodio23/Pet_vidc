-- Parte 1
DROP DATABASE IF EXISTS pet_vida;
CREATE DATABASE IF NOT EXISTS pet_vida;
USE pet_vida;

-- TABELA DE VETERINARIOS
CREATE TABLE veterinarios (
 id_veterinario INT AUTO_INCREMENT PRIMARY KEY,
 nome VARCHAR(100) NOT NULL,
 crmv VARCHAR(20) NOT NULL UNIQUE,
 especialidade VARCHAR(50) NOT NULL, 
 telefone VARCHAR(20) NOT NULL
); 

-- TABELA DE TUTORES  
CREATE TABLE tutores (
 id_tutor INT AUTO_INCREMENT PRIMARY KEY,
 nome VARCHAR(100) NOT NULL,
 cpf VARCHAR(14) NOT NULL UNIQUE,
 email VARCHAR(100) NOT NULL,
 telefone VARCHAR(20) NOT NULL
);
 
-- TABELA DE ANIMAIS
CREATE TABLE animais (
 id_animal INT AUTO_INCREMENT PRIMARY KEY,
 nome VARCHAR(50) NOT NULL,
 especie VARCHAR(30) NOT NULL,
 raca VARCHAR(50),
 sexo VARCHAR(9),
 peso FLOAT NOT NULL,
 data_nascimento DATE,
 tutor_id INT NOT NULL,
 
 CONSTRAINT fk_animal_tutor
 FOREIGN KEY (tutor_id) 
 REFERENCES tutores(id_tutor) 
);

-- TABELA DE CONSULTAS
CREATE TABLE consultas (
 id_consulta INT AUTO_INCREMENT PRIMARY KEY,
 animal_id INT NOT NULL,
 veterinario_id INT NOT NULL,
 data_hora DATETIME NOT NULL,
 diagnostico TEXT,
 valor DECIMAL(10, 2) NOT NULL,

 CONSTRAINT fk_consultas_animais
 FOREIGN KEY (animal_id)
 REFERENCES animais(id_animal),

 CONSTRAINT fk_consultas_veterinarios 
 FOREIGN KEY (veterinario_id)
 REFERENCES veterinarios(id_veterinario) 
);

-- Parte 2

-- INSERINDO VETERINÁRIOS
INSERT INTO veterinarios (nome, crmv, especialidade, telefone) VALUES
('Ana Souza', 'CRMV-BA 123', 'Clínica Geral', '(71) 98567-1011'),
('Carlos Lima', 'CRMV-BA 456', 'Dermatologia', '(71) 98988-4422'),
('Beatriz Silva', 'CRMV-BA 789', 'Cirurgia', '(71) 97690-1333');

-- INSERINDO TUTORES
INSERT INTO tutores (nome, cpf, email, telefone) VALUES
('JOÃO FERREIRA', '100.456.321-22', 'joao@email.com', '(71) 97890-7810'),
('ROBERTO CARLOS', '567.674.214-89', 'roberto@email.com', '(71) 92467-2090'),
('RICARDO NUNES', '864.411.745-97', 'ricardo@email.com', '(71) 99989-3856'),
('LUCAS BARBALHO', '865.336.685-86', 'lucas@email.com', '(71) 97589-4898'),
('ELISANGELA REALE', '540.900.100-75', 'elisangela@email.com', '(71) 97696-5150');

-- INSERINDO ANIMAIS (Agora com sexo e peso corretos)
INSERT INTO animais (nome, especie, raca, sexo, peso, data_nascimento, tutor_id) VALUES 
('Rex', 'Cão', 'Labrador', 'Macho', 22.5, '2020-05-10', 1),
('Thor', 'Cão', 'Poodle', 'Macho', 10.1, '2021-08-15', 1),
('Luna', 'Gato', 'Siamês', 'Fêmea', 5.00, '2019-02-20', 2),
('Bolinha', 'Gato', 'SRD', 'Fêmea', 9.00, '2022-01-10', 2),
('Mel', 'Cão', 'Beagle', 'Macho', 30.00, '2018-11-05', 3),
('Pipoca', 'Hamster', 'Sírio', 'Fêmea', 1.5, '2023-03-12', 4),
('Fred', 'Cão', 'Golden', 'Macho', 40.5, '2017-06-30', 5);

-- INSERINDO CONSULTAS
INSERT INTO consultas (animal_id, veterinario_id, data_hora, diagnostico, valor) VALUES 
(1, 1, '2023-10-01 10:00:00', 'Vacinação anual', 150.00),
(2, 1, '2023-10-01 11:30:00', 'Check-up geral', 120.00),
(3, 2, '2023-10-02 14:00:00', 'Alergia alimentar', 200.00),
(4, 2, '2023-10-02 15:30:00', 'Otite', 180.00),
(5, 3, '2023-10-03 09:00:00', 'Avaliação cirúrgica', 250.00),
(6, 1, '2023-10-03 10:30:00', 'Unhas compridas', 50.00),
(7, 3, '2023-10-04 13:00:00', 'Limpeza de tártaro', 400.00),
(1, 2, '2023-10-10 16:00:00', 'Coceira nas patas', 190.00),
(3, 1, '2023-10-11 08:30:00', 'Vermifugação', 100.00),
(5, 3, '2023-10-12 11:00:00', 'Cirurgia castração', 600.00);

-- Parte 3
SELECT animais.nome AS Nome_Animal, tutores.nome AS Nome_Tutor
FROM animais
INNER JOIN tutores ON animais.tutor_id = tutores.id_tutor;

SELECT animais.nome AS Nome_Animal, tutores.nome AS Nome_Tutor, veterinarios.nome AS Nome_Veterinario, consultas.data_hora, consultas.valor
FROM consultas
INNER JOIN animais ON consultas.animal_id = animais.id_animal
INNER JOIN tutores ON animais.tutor_id = tutores.id_tutor
INNER JOIN veterinarios ON consultas.veterinario_id = veterinarios.id_veterinario;

SELECT consultas.data_hora, animais.nome AS Nome_Animal, consultas.diagnostico
FROM consultas
INNER JOIN animais ON consultas.animal_id = animais.id_animal
INNER JOIN veterinarios ON consultas.veterinario_id = veterinarios.id_veterinario
WHERE veterinarios.nome = 'Ana Souza';

SELECT nome, raca, sexo
FROM animais
WHERE especie = 'Cão';

SELECT tutores.nome AS Nome_Tutor, COUNT(animais.id_animal) AS Quantidade_Animais
FROM tutores
INNER JOIN animais ON tutores.id_tutor = animais.tutor_id
GROUP BY tutores.id_tutor, tutores.nome
HAVING COUNT(animais.id_animal) > 1;



SELECT SUM(valor) AS Faturamento_Total
FROM consultas;


-- Parte 4

UPDATE tutores 
SET telefone = '(75) 98522-7047' 
WHERE id_tutor = 1;


UPDATE consultas 
SET diagnostico = 'Paciente apresentou melhora após antibiótico. Alta médica concedida.' 
WHERE id_consulta = 2;


DELETE FROM consultas 
WHERE id_consulta = 3;


-- Parte 5
-- Garantir que não exista antes de criar
DROP PROCEDURE IF EXISTS agendar_consulta;

DELIMITER $$

CREATE PROCEDURE agendar_consulta(
    IN p_animal_id INT,
    IN p_veterinario_id INT,
    IN p_data_hora DATETIME,
    IN p_valor DECIMAL(10, 2)
)
BEGIN
    DECLARE v_existe INT;
    
    -- Verifica se o animal existe na tabela animais
    SELECT COUNT(*) INTO v_existe FROM animais WHERE id_animal = p_animal_id;
    
    IF v_existe = 0 THEN
        -- Retorna um erro caso o animal não exista
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Erro: Animal não encontrado no sistema!';
    ELSE
        -- Insere a consulta caso o animal exista
        INSERT INTO consultas (animal_id, veterinario_id, data_hora, diagnostico, valor)
        VALUES (p_animal_id, p_veterinario_id, p_data_hora, NULL, p_valor);
        
        -- Retorna a mensagem de sucesso com o ID gerado
        SELECT CONCAT('Consulta agendada com sucesso! ID da Consulta: ', LAST_INSERT_ID()) AS Mensagem_Sucesso;
    END IF;
END $$

DELIMITER ;


-- Teste de Sucesso (Animal existe):
CALL agendar_consulta(1, 1, '2023-11-20 10:00:00', 150.00);
-- Teste de Erro (Animal 9 não existe):
-- CALL agendar_consulta(9, 1, '2026-11-20 10:00:00', 150.00);

-- Parte 6
-- Garantir que não exista antes de criar
DROP FUNCTION IF EXISTS total_consultas_animal;

DELIMITER $$

CREATE FUNCTION total_consultas_animal(p_animal_id INT) 
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE v_total INT;
    
    -- Conta quantas consultas o animal possui e guarda na variável
    SELECT COUNT(*) INTO v_total 
    FROM consultas 
    WHERE animal_id = p_animal_id;
    
    RETURN v_total;
END $$

DELIMITER ;

SELECT total_consultas_animal(1) AS Total_Consultas_Do_Animal;

-- Parte 7

-- 1. Criando os usuários (necessário para conseguir aplicar os GRANTs)
CREATE USER IF NOT EXISTS 'recepcionista'@'localhost' IDENTIFIED BY 'senha123';
CREATE USER IF NOT EXISTS 'veterinario_sistema'@'localhost' IDENTIFIED BY 'senha123';
CREATE USER IF NOT EXISTS 'admin_clinica'@'localhost' IDENTIFIED BY 'senha123';

-- 2. GRANT para a RECEPCIONISTA (SELECT e INSERT nas tabelas específicas)
GRANT SELECT, INSERT ON pet_vida.tutores TO 'recepcionista'@'localhost';
GRANT SELECT, INSERT ON pet_vida.animais TO 'recepcionista'@'localhost';
GRANT SELECT, INSERT ON pet_vida.consultas TO 'recepcionista'@'localhost';

-- 3. GRANT para o VETERINARIO_SISTEMA (SELECT em tudo, UPDATE apenas em diagnóstico)
GRANT SELECT ON pet_vida.* TO 'veterinario_sistema'@'localhost';
GRANT UPDATE (diagnostico) ON pet_vida.consultas TO 'veterinario_sistema'@'localhost';

-- 4. GRANT para o ADMIN_CLINICA (Acesso total)
GRANT ALL PRIVILEGES ON pet_vida.* TO 'admin_clinica'@'localhost';

-- Atualiza os privilégios no banco
FLUSH PRIVILEGES;


-- REVOKE (Caso a recepcionista saia da clínica)

REVOKE ALL PRIVILEGES, GRANT OPTION FROM 'recepcionista'@'localhost';
