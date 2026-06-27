USE pet_vida;

DROP VIEW IF EXISTS vw_animais_detalhados;
CREATE VIEW vw_animais_detalhados AS
SELECT
    a.id_animal,
    a.nome,
    a.raca,
    a.sexo,
    a.peso,
    a.data_nascimento,
    t.nome AS tutor,
    e.nome AS especie
FROM animais a
JOIN tutores t ON a.tutor_id = t.id_tutor
JOIN especies e ON a.especie_id = e.id_especie;

DROP VIEW IF EXISTS vw_consultas_completas;
CREATE VIEW vw_consultas_completas AS
SELECT
    c.id_consulta,
    c.data_hora,
    c.diagnostico,
    c.valor,
    c.status,
    a.nome AS animal,
    t.nome AS tutor,
    v.nome AS veterinario
FROM consultas c
JOIN animais a ON c.animal_id = a.id_animal
JOIN tutores t ON a.tutor_id = t.id_tutor
JOIN veterinarios v ON c.veterinario_id = v.id_veterinario;

DROP VIEW IF EXISTS vw_inadimplentes;
CREATE VIEW vw_inadimplentes AS
SELECT
    c.id_consulta,
    c.data_hora,
    a.nome AS animal,
    t.nome AS tutor,
    v.nome AS veterinario,
    c.valor,
    COALESCE(p.valor_pago, 0) AS valor_pago,
    ROUND(c.valor - COALESCE(p.valor_pago, 0), 2) AS saldo_devedor,
    COALESCE(p.status, 'pendente') AS status_pagamento
FROM consultas c
JOIN animais a ON c.animal_id = a.id_animal
JOIN tutores t ON a.tutor_id = t.id_tutor
JOIN veterinarios v ON c.veterinario_id = v.id_veterinario
LEFT JOIN pagamentos p ON p.consulta_id = c.id_consulta
WHERE c.status = 'concluida'
  AND COALESCE(p.status, 'pendente') <> 'pago';
