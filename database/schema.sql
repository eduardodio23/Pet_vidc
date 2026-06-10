-- database/schema.sql
-- Esquema do banco PETVIDA (criação do database e tabelas)

DROP DATABASE IF EXISTS pet_vida;
CREATE DATABASE IF NOT EXISTS pet_vida;
USE pet_vida;

-- 1. TABELA DE ESPÉCIES
CREATE TABLE especies (
    id_especie INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(50) NOT NULL
);

-- 2. TABELA DE VETERINARIOS
CREATE TABLE veterinarios (
    id_veterinario INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    crmv VARCHAR(20) NOT NULL UNIQUE,
    especialidade VARCHAR(50) NOT NULL,
    telefone VARCHAR(20) NOT NULL
);

-- 3. TABELA DE TUTORES
CREATE TABLE tutores (
    id_tutor INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cpf VARCHAR(14) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL,
    telefone VARCHAR(20) NOT NULL
);

-- 4. TABELA DE ANIMAIS
CREATE TABLE animais (
    id_animal INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(50) NOT NULL,
    especie_id INT NOT NULL,
    raca VARCHAR(50),
    sexo VARCHAR(9),
    peso FLOAT NOT NULL,
    data_nascimento DATE,
    tutor_id INT NOT NULL,
    CONSTRAINT fk_animais_especies FOREIGN KEY (especie_id) REFERENCES especies(id_especie),
    CONSTRAINT fk_animais_tutor FOREIGN KEY (tutor_id) REFERENCES tutores(id_tutor)
);

-- 5. TABELA DE CONSULTAS
CREATE TABLE consultas (
    id_consulta INT AUTO_INCREMENT PRIMARY KEY,
    animal_id INT NOT NULL,
    veterinario_id INT NOT NULL,
    data_hora DATETIME NOT NULL,
    diagnostico TEXT,
    valor DECIMAL(10,2) NOT NULL,
    status ENUM('agendada','em_atendimento','concluida','cancelada') NOT NULL,
    CONSTRAINT fk_consultas_animais FOREIGN KEY (animal_id) REFERENCES animais(id_animal),
    CONSTRAINT fk_consultas_veterinarios FOREIGN KEY (veterinario_id) REFERENCES veterinarios(id_veterinario)
);

-- 6. TABELA DE PAGAMENTOS
CREATE TABLE pagamentos (
    id_pagamento INT AUTO_INCREMENT PRIMARY KEY,
    consulta_id INT NOT NULL,
    valor_pago DECIMAL(10,2) NOT NULL,
    forma_pagamento ENUM('pix','cartao','dinheiro','convenio') NOT NULL,
    data_pagamento DATE NOT NULL,
    status ENUM('pago','pendente','cancelado') NOT NULL,
    CONSTRAINT fk_pagamentos_consultas FOREIGN KEY (consulta_id) REFERENCES consultas(id_consulta)
);

-- INDEXES
CREATE INDEX idx_consultas_data_hora ON consultas(data_hora);
CREATE INDEX idx_animais_tutor_id ON animais(tutor_id);
CREATE INDEX idx_pagamentos_consulta_id ON pagamentos(consulta_id);

-- Opcional: criar usuários/privilegios em script separado quando necessário
