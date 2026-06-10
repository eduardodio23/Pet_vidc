-- database/seeds.sql
-- Seeds separados para PETVIDA. Pressupõe que `database/schema.sql` já foi executado.

USE pet_vida;

-- ESPÉCIES
INSERT INTO especies (nome) VALUES
('Cachorro'), ('Gato'), ('Pássaro'), ('Peixe'), ('Réptil');

-- VETERINÁRIOS
INSERT INTO veterinarios (nome, crmv, especialidade, telefone) VALUES
('Ana Souza', 'CRMV-BA 123', 'Clínica Geral', '(71) 98567-1011'),
('Carlos Lima', 'CRMV-BA 456', 'Dermatologia', '(71) 98988-4422'),
('Beatriz Silva', 'CRMV-BA 789', 'Cirurgia', '(71) 97690-1333');

-- TUTORES
INSERT INTO tutores (nome, cpf, email, telefone) VALUES
('JOÃO FERREIRA', '100.456.321-22', 'joao@email.com', '(71) 97890-7810'),
('ROBERTO CARLOS', '567.674.214-89', 'roberto@email.com', '(71) 92467-2090'),
('RICARDO NUNES', '864.411.745-97', 'ricardo@email.com', '(71) 99989-3856'),
('LUCAS BARBALHO', '865.336.685-86', 'lucas@email.com', '(71) 97589-4898'),
('ELISANGELA REALE', '540.900.100-75', 'elisangela@email.com', '(71) 97696-5150'),
('MARIA ALMEIDA', '111.222.333-44', 'maria@email.com', '(71) 98888-1111'),
('FERNANDO COSTA', '555.666.777-88', 'fernando@email.com', '(71) 97777-2222'),
('PATRÍCIA LIMA', '999.888.777-66', 'patricia@email.com', '(71) 96666-3333');

-- ANIMAIS (usando especie_id de acordo com ordem inserida em `especies`)
INSERT INTO animais (nome, especie_id, raca, sexo, peso, data_nascimento, tutor_id) VALUES
('Rex', 1, 'Labrador', 'Macho', 22.5, '2020-05-10', 1),
('Thor', 1, 'Poodle', 'Macho', 10.1, '2021-08-15', 1),
('Luna', 2, 'Siamês', 'Fêmea', 5.00, '2019-02-20', 2),
('Bolinha', 2, 'SRD', 'Fêmea', 9.00, '2022-01-10', 2),
('Mel', 1, 'Beagle', 'Fêmea', 15.00, '2021-11-05', 3),
('Pipoca', 3, 'Calopsita', 'Fêmea', 0.1, '2023-03-12', 4),
('Fred', 1, 'Golden', 'Macho', 40.5, '2017-06-30', 5),
('Piu', 3, 'Calopsita', 'Macho', 0.1, '2025-05-01', 6),
('Nemo', 4, 'Palhaço', 'Macho', 0.05, '2026-01-15', 6),
('Dino', 5, 'Iguana', 'Macho', 1.2, '2024-12-10', 7),
('Mia', 2, 'Persa', 'Fêmea', 4.5, '2023-07-22', 8),
('Bidu', 1, 'Schnauzer', 'Macho', 8.0, '2022-09-09', 8),
('Kiko', 3, 'Papagaio', 'Macho', 0.4, '2018-04-14', 1),
('Bela', 1, 'Pug', 'Fêmea', 7.5, '2024-11-11', 2),
('Simba', 2, 'Maine Coon', 'Macho', 9.5, '2021-03-03', 3);

-- CONSULTAS
INSERT INTO consultas (animal_id, veterinario_id, data_hora, diagnostico, valor, status) VALUES
(1, 1, '2026-10-01 10:00:00', 'Vacinação anual', 150.00, 'concluida'),
(2, 1, '2026-10-01 11:30:00', 'Check-up geral', 120.00, 'concluida'),
(3, 2, '2026-10-02 14:00:00', 'Alergia alimentar', 200.00, 'concluida'),
(4, 2, '2026-10-02 15:30:00', 'Otite', 180.00, 'concluida'),
(5, 3, '2026-10-03 09:00:00', 'Avaliação cirúrgica', 250.00, 'concluida'),
(6, 1, '2026-10-03 10:30:00', 'Unhas compridas', 50.00, 'concluida'),
(7, 3, '2026-10-04 13:00:00', 'Limpeza de tártaro', 400.00, 'concluida'),
(8, 2, '2026-10-10 16:00:00', 'Troca de penas', 100.00, 'concluida'),
(9, 1, '2026-10-11 08:30:00', 'Análise de aquário', 80.00, 'concluida'),
(10, 3, '2026-10-12 11:00:00', 'Corte nas garras', 150.00, 'concluida'),
(11, 1, '2026-11-01 09:00:00', 'Vacina V4', 120.00, 'concluida'),
(12, 2, '2026-11-02 10:00:00', 'Dermatite', 180.00, 'concluida'),
(13, 1, '2026-11-03 14:00:00', 'Apareio bico', 90.00, 'concluida'),
(14, 3, '2026-11-04 15:30:00', 'Consulta oftalmológica', 220.00, 'concluida'),
(15, 2, '2026-11-05 16:00:00', 'Check-up renal', 200.00, 'concluida'),
(1, 1, '2026-12-01 09:00:00', NULL, 150.00, 'agendada'),
(2, 2, '2026-12-02 10:30:00', NULL, 180.00, 'agendada'),
(3, 3, '2026-12-03 14:00:00', NULL, 300.00, 'cancelada'),
(4, 1, '2026-12-04 15:00:00', NULL, 120.00, 'agendada'),
(5, 2, '2026-12-05 16:30:00', NULL, 200.00, 'em_atendimento');

-- PAGAMENTOS
INSERT INTO pagamentos (consulta_id, valor_pago, forma_pagamento, data_pagamento, status) VALUES
(1, 150.00, 'pix', '2026-10-01', 'pago'),
(2, 120.00, 'cartao', '2026-10-01', 'pago'),
(3, 200.00, 'dinheiro', '2026-10-02', 'pago'),
(4, 180.00, 'pix', '2026-10-02', 'pago'),
(5, 250.00, 'cartao', '2026-10-03', 'pago'),
(6, 50.00, 'dinheiro', '2026-10-03', 'pago'),
(7, 400.00, 'convenio', '2026-10-04', 'pago'),
(8, 100.00, 'pix', '2026-10-10', 'pago'),
(9, 80.00, 'cartao', '2026-10-11', 'pago'),
(10, 150.00, 'dinheiro', '2026-10-12', 'pago'),
(11, 120.00, 'convenio', '2026-11-01', 'pago'),
(12, 180.00, 'pix', '2026-11-02', 'pago'),
(13, 90.00, 'cartao', '2026-11-03', 'pago'),
(14, 220.00, 'dinheiro', '2026-11-04', 'pago'),
(15, 200.00, 'pix', '2026-11-05', 'pago'),
(16, 150.00, 'cartao', '2026-12-01', 'pendente'),
(17, 180.00, 'convenio', '2026-12-02', 'pendente'),
(18, 0.00, 'pix', '2026-12-03', 'cancelado'),
(19, 120.00, 'dinheiro', '2026-12-04', 'pendente'),
(20, 200.00, 'cartao', '2026-12-05', 'pendente');
