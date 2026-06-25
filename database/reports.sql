USE pet_vida;

-- 1) Ranking de tutores que mais gastam
SET @rank := 0;
SELECT
    @rank := @rank + 1 AS posicao,
    r.nome_tutor AS tutor,
    r.total_gasto AS total,
    r.qtd_consultas AS qtd_consultas
FROM (
    SELECT
        t.nome AS nome_tutor,
        SUM(c.valor) AS total_gasto,
        COUNT(c.id_consulta) AS qtd_consultas
    FROM tutores t
    JOIN animais a ON a.tutor_id = t.id_tutor
    JOIN consultas c ON c.animal_id = a.id_animal
    WHERE c.status = 'concluida'
    GROUP BY t.id_tutor, t.nome
) AS r
ORDER BY r.total_gasto DESC;

-- 2) Faturamento mensal
SELECT
    YEAR(c.data_hora) AS ano,
    MONTH(c.data_hora) AS mes,
    COUNT(DISTINCT c.id_consulta) AS total_consultas,
    COALESCE(SUM(c.valor), 0) AS bruto,
    COALESCE(SUM(CASE WHEN p.status = 'pago' THEN p.valor_pago ELSE 0 END), 0) AS recebido,
    COALESCE(SUM(CASE WHEN p.status = 'pendente' THEN p.valor_pago ELSE 0 END), 0) AS pendente
FROM consultas c
LEFT JOIN pagamentos p ON p.consulta_id = c.id_consulta
WHERE c.status = 'concluida'
GROUP BY YEAR(c.data_hora), MONTH(c.data_hora)
ORDER BY ano DESC, mes DESC;

-- 3) Animais sem consulta há 6+ meses (inclui nunca consultados)
SELECT
    a.id_animal,
    a.nome AS animal,
    t.nome AS tutor,
    e.nome AS especie,
    MAX(c.data_hora) AS ultima_consulta,
    CASE
        WHEN MAX(c.data_hora) IS NULL THEN 'Nunca'
        ELSE CAST(DATEDIFF(CURRENT_DATE, MAX(c.data_hora)) AS CHAR)
    END AS dias_desde_ultima_consulta
FROM animais a
JOIN tutores t ON a.tutor_id = t.id_tutor
JOIN especies e ON a.especie_id = e.id_especie
LEFT JOIN consultas c ON c.animal_id = a.id_animal
GROUP BY a.id_animal, a.nome, t.nome, e.nome
HAVING MAX(c.data_hora) IS NULL
    OR DATEDIFF(CURRENT_DATE, MAX(c.data_hora)) >= 180
ORDER BY ultima_consulta ASC;

-- 4) Dashboard financeiro
SELECT
    COUNT(DISTINCT c.id_consulta) AS total_consultas,
    COALESCE(SUM(c.valor), 0) AS bruto,
    COALESCE(SUM(CASE WHEN p.status = 'pago' THEN p.valor_pago ELSE 0 END), 0) AS recebido,
    COALESCE(SUM(CASE WHEN p.status = 'pendente' THEN p.valor_pago ELSE 0 END), 0) AS pendente,
    ROUND(
        IF(COALESCE(SUM(c.valor), 0) = 0, 0,
           COALESCE(SUM(CASE WHEN p.status = 'pendente' THEN p.valor_pago ELSE 0 END), 0) / SUM(c.valor) * 100
        ),
        2
    ) AS perc_inadimplencia
FROM consultas c
LEFT JOIN pagamentos p ON p.consulta_id = c.id_consulta
WHERE c.status = 'concluida';

-- 5) Veterinário do mês
SELECT
    v.id_veterinario,
    v.nome AS veterinario,
    COUNT(c.id_consulta) AS qtd_consultas,
    COALESCE(SUM(c.valor), 0) AS faturamento_mes
FROM consultas c
JOIN veterinarios v ON c.veterinario_id = v.id_veterinario
WHERE c.status = 'concluida'
  AND YEAR(c.data_hora) = YEAR(CURRENT_DATE)
  AND MONTH(c.data_hora) = MONTH(CURRENT_DATE)
GROUP BY v.id_veterinario, v.nome
ORDER BY faturamento_mes DESC
LIMIT 1;

-- 6) Distribuição por espécie
SELECT
    e.nome AS especie,
    COUNT(a.id_animal) AS qtd_animais,
    ROUND(
        IF(total.total_animais = 0, 0,
           COUNT(a.id_animal) / total.total_animais * 100
        ),
        2
    ) AS percentual
FROM especies e
LEFT JOIN animais a ON a.especie_id = e.id_especie
CROSS JOIN (SELECT COUNT(*) AS total_animais FROM animais) AS total
GROUP BY e.id_especie, e.nome
ORDER BY qtd_animais DESC;
