-- database/schema.sql
-- Esquema do banco PETVIDA (criação do database e tabelas)

DROP DATABASE IF EXISTS pet_vida;
CREATE DATABASE IF NOT EXISTS pet_vida
  DEFAULT CHARACTER SET utf8mb4
  DEFAULT COLLATE utf8mb4_unicode_ci;
USE pet_vida;

-- 1. TABELA DE ESPÉCIES
CREATE TABLE especies (
    id_especie INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(50) NOT NULL UNIQUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 2. TABELA DE VETERINARIOS
CREATE TABLE veterinarios (
    id_veterinario INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    crmv VARCHAR(20) NOT NULL UNIQUE,
    especialidade VARCHAR(50) NOT NULL,
    telefone VARCHAR(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 3. TABELA DE TUTORES
CREATE TABLE tutores (
    id_tutor INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cpf VARCHAR(14) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL,
    telefone VARCHAR(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 4. TABELA DE ANIMAIS
CREATE TABLE animais (
    id_animal INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(50) NOT NULL,
    especie_id INT NOT NULL,
    raca VARCHAR(50),
    sexo VARCHAR(9),
    peso DECIMAL(5,2) NOT NULL,
    data_nascimento DATE,
    tutor_id INT NOT NULL,
    CONSTRAINT fk_animais_especies FOREIGN KEY (especie_id) REFERENCES especies(id_especie)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_animais_tutor FOREIGN KEY (tutor_id) REFERENCES tutores(id_tutor)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CHECK (peso > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE INDEX idx_animais_especie_id ON animais(especie_id);
CREATE INDEX idx_animais_tutor_id ON animais(tutor_id);

-- 5. TABELA DE CONSULTAS
CREATE TABLE consultas (
    id_consulta INT AUTO_INCREMENT PRIMARY KEY,
    animal_id INT NOT NULL,
    veterinario_id INT NOT NULL,
    data_hora DATETIME NOT NULL,
    diagnostico TEXT,
    valor DECIMAL(10,2) NOT NULL,
    status ENUM('agendada','em_atendimento','concluida','cancelada') NOT NULL,
    CONSTRAINT fk_consultas_animais FOREIGN KEY (animal_id) REFERENCES animais(id_animal)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_consultas_veterinarios FOREIGN KEY (veterinario_id) REFERENCES veterinarios(id_veterinario)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE INDEX idx_consultas_data_hora ON consultas(data_hora);
CREATE INDEX idx_consultas_animal_id ON consultas(animal_id);
CREATE INDEX idx_consultas_veterinario_id ON consultas(veterinario_id);
CREATE INDEX idx_consultas_status ON consultas(status);

-- 6. TABELA DE PAGAMENTOS
CREATE TABLE pagamentos (
    id_pagamento INT AUTO_INCREMENT PRIMARY KEY,
    consulta_id INT NOT NULL,
    valor_pago DECIMAL(10,2) NOT NULL,
    forma_pagamento ENUM('pix','cartao','dinheiro','convenio') NOT NULL,
    data_pagamento DATE NOT NULL,
    status ENUM('pago','pendente','cancelado') NOT NULL,
    CONSTRAINT fk_pagamentos_consultas FOREIGN KEY (consulta_id) REFERENCES consultas(id_consulta)
        ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE INDEX idx_pagamentos_consulta_id ON pagamentos(consulta_id);

-- Esquema otimizado com integridade referencial e índices para consultas frequentes.
