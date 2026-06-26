const express = require('express');
const router = express.Router();
const pool = require('../config/database');

async function query(sql, params = []) {
  const [rows] = await pool.execute(sql, params);
  return rows;
}

router.get('/health', async (req, res) => {
  try {
    await query('SELECT 1');
    res.status(200).json({ status: 'ok', database: 'connected' });
  } catch (error) {
    res.status(500).json({ status: 'error', message: error.message });
  }
});

router.get('/veterinarios', async (req, res) => {
  try {
    const veterinarios = await query('SELECT * FROM veterinarios');
    res.json(veterinarios);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

router.get('/animais', async (req, res) => {
  try {
    const animais = await query(
      `SELECT a.id_animal, a.nome, a.raca, a.sexo, a.peso, a.data_nascimento,
              t.nome AS tutor, e.nome AS especie
       FROM animais a
       JOIN tutores t ON a.tutor_id = t.id_tutor
       JOIN especies e ON a.especie_id = e.id_especie`
    );
    res.json(animais);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

router.get('/consultas', async (req, res) => {
  try {
    const consultas = await query(
      `SELECT c.id_consulta, c.data_hora, c.diagnostico, c.valor, c.status,
              a.nome AS animal, t.nome AS tutor, v.nome AS veterinario
       FROM consultas c
       JOIN animais a ON c.animal_id = a.id_animal
       JOIN tutores t ON a.tutor_id = t.id_tutor
       JOIN veterinarios v ON c.veterinario_id = v.id_veterinario`
    );
    res.json(consultas);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

router.get('/pagamentos', async (req, res) => {
  try {
    const pagamentos = await query(
      `SELECT p.id_pagamento, p.consulta_id, p.valor_pago, p.forma_pagamento, p.data_pagamento, p.status,
              a.nome AS animal, c.data_hora AS consulta_data_hora
       FROM pagamentos p
       JOIN consultas c ON p.consulta_id = c.id_consulta
       JOIN animais a ON c.animal_id = a.id_animal`
    );
    res.json(pagamentos);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

router.get('/relatorios', async (req, res) => {
  try {
    const faturamento = await query(
      `SELECT COALESCE(SUM(c.valor),0) AS faturamento_total,
              COALESCE(SUM(CASE WHEN p.status = 'pago' THEN p.valor_pago ELSE 0 END),0) AS total_recebido,
              COALESCE(SUM(CASE WHEN p.status = 'pendente' THEN p.valor_pago ELSE 0 END),0) AS total_pendente
       FROM consultas c
       LEFT JOIN pagamentos p ON p.consulta_id = c.id_consulta`
    );
    const por_veterinario = await query(
      `SELECT v.id_veterinario, v.nome AS veterinario, COUNT(c.id_consulta) AS total_consultas,
              COALESCE(SUM(c.valor),0) AS faturamento
       FROM consultas c
       JOIN veterinarios v ON c.veterinario_id = v.id_veterinario
       GROUP BY v.id_veterinario, v.nome
       ORDER BY faturamento DESC`
    );
    res.json({ faturamento: faturamento[0], por_veterinario });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;
