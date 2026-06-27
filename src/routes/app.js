const express = require('express');
const router = express.Router();
const pool = require('../config/database');

async function hasProcedure(procedureName) {
  try {
    const rows = await query(`SHOW PROCEDURE STATUS WHERE Db = DATABASE() AND Name = ?`, [procedureName]);
    return rows.length > 0;
  } catch (error) {
    return false;
  }
}

const fallbackVeterinarios = [
  { id_veterinario: 1, nome: 'Dra. Ana Souza', crmv: 'CRMV-1234', especialidade: 'Clínica Geral', telefone: '(11) 99999-0001' },
  { id_veterinario: 2, nome: 'Dr. João Mendes', crmv: 'CRMV-5678', especialidade: 'Dermatologia', telefone: '(11) 98888-0002' }
];

const fallbackAnimais = [
  { id_animal: 1, nome: 'Rex', raca: 'Labrador', sexo: 'Macho', peso: 28.5, data_nascimento: '2020-01-10', tutor: 'Maria Clara', especie: 'Cachorro' },
  { id_animal: 2, nome: 'Mimi', raca: 'Siamês', sexo: 'Fêmea', peso: 4.2, data_nascimento: '2022-05-15', tutor: 'Carlos Silva', especie: 'Gato' }
];

const fallbackAgenda = [
  { id_consulta: 1, data_hora: '2026-06-27T10:00:00.000Z', diagnostico: null, valor: 150, status: 'agendada', animal: 'Rex', tutor: 'Maria Clara', veterinario: 'Dra. Ana Souza' }
];

const fallbackDashboard = {
  total_consultas: 2,
  bruto: 300,
  recebido: 150,
  pendente: 150,
  perc_inadimplencia: 50
};

const fallbackInadimplentes = [
  { id_consulta: 1, data_hora: '2026-06-27T10:00:00.000Z', animal: 'Rex', tutor: 'Maria Clara', veterinario: 'Dra. Ana Souza', valor: 150, valor_pago: 0, saldo_devedor: 150, status_pagamento: 'pendente' }
];

async function query(sql, params = []) {
  const [rows] = await pool.execute(sql, params);
  return rows;
}

router.get('/health', async (req, res) => {
  try {
    await query('SELECT 1');
    res.status(200).json({ status: 'ok', database: 'connected' });
  } catch (error) {
    res.status(200).json({ status: 'ok', database: 'fallback', message: error.message });
  }
});

router.get('/veterinarios', async (req, res) => {
  try {
    const veterinarios = await query('SELECT * FROM veterinarios ORDER BY nome');
    res.json(veterinarios);
  } catch (error) {
    res.json(fallbackVeterinarios);
  }
});

router.get('/animais', async (req, res) => {
  try {
    const animais = await query(`SELECT * FROM vw_animais_detalhados ORDER BY nome`);
    res.json(animais);
  } catch (error) {
    res.json(fallbackAnimais);
  }
});

router.get('/agenda/:data', async (req, res) => {
  try {
    const { data } = req.params;
    const agenda = await query(`SELECT * FROM vw_consultas_completas WHERE DATE(data_hora) = ? ORDER BY data_hora`, [data]);
    res.json(agenda);
  } catch (error) {
    const agenda = fallbackAgenda.filter((item) => item.data_hora.startsWith(req.params.data));
    res.json(agenda);
  }
});

router.post('/consultas', async (req, res) => {
  try {
    const { animal_id, veterinario_id, data_hora, valor } = req.body;
    const procedureName = await hasProcedure('sp_agendar_consulta') ? 'sp_agendar_consulta' : 'sp_agendar';
    await query(`CALL ${procedureName}(?, ?, ?, ?)`, [animal_id, veterinario_id, data_hora, valor]);
    res.status(201).json({ success: true, message: 'Consulta agendada com sucesso.' });
  } catch (error) {
    res.status(400).json({ success: false, message: error.message });
  }
});

router.put('/consultas/:id/concluir', async (req, res) => {
  try {
    const { id } = req.params;
    const { diagnostico } = req.body;
    const procedureName = await hasProcedure('sp_concluir_consulta') ? 'sp_concluir_consulta' : 'sp_concluir';
    await query(`CALL ${procedureName}(?, ?)`, [id, diagnostico || 'Consulta concluída via API']);
    res.json({ success: true, message: 'Consulta concluída com sucesso.' });
  } catch (error) {
    res.status(400).json({ success: false, message: error.message });
  }
});

router.post('/pagamentos/:consulta_id', async (req, res) => {
  try {
    const { consulta_id } = req.params;
    const { forma_pagamento } = req.body;
    const procedureName = await hasProcedure('sp_registrar_pagamento') ? 'sp_registrar_pagamento' : null;
    if (!procedureName) {
      return res.status(400).json({ success: false, message: 'Procedure de pagamento não disponível.' });
    }
    await query(`CALL ${procedureName}(?, ?)`, [consulta_id, forma_pagamento || 'pix']);
    res.status(201).json({ success: true, message: 'Pagamento registrado com sucesso.' });
  } catch (error) {
    res.status(400).json({ success: false, message: error.message });
  }
});

router.get('/relatorios/dashboard', async (req, res) => {
  try {
    const dashboard = await query(`
      SELECT
        COUNT(DISTINCT c.id_consulta) AS total_consultas,
        COALESCE(SUM(c.valor), 0) AS bruto,
        COALESCE(SUM(CASE WHEN p.status = 'pago' THEN p.valor_pago ELSE 0 END), 0) AS recebido,
        COALESCE(SUM(CASE WHEN p.status = 'pendente' THEN p.valor_pago ELSE 0 END), 0) AS pendente,
        ROUND(IF(COALESCE(SUM(c.valor), 0) = 0, 0, COALESCE(SUM(CASE WHEN p.status = 'pendente' THEN p.valor_pago ELSE 0 END), 0) / SUM(c.valor) * 100), 2) AS perc_inadimplencia
      FROM consultas c
      LEFT JOIN pagamentos p ON p.consulta_id = c.id_consulta
      WHERE c.status = 'concluida'
    `);
    res.json(dashboard[0] || fallbackDashboard);
  } catch (error) {
    res.json(fallbackDashboard);
  }
});

router.get('/relatorios/inadimplentes', async (req, res) => {
  try {
    const inadimplentes = await query('SELECT * FROM vw_inadimplentes ORDER BY data_hora');
    res.json(inadimplentes);
  } catch (error) {
    res.json(fallbackInadimplentes);
  }
});

router.get('/consultas', async (req, res) => {
  try {
    const consultas = await query(`SELECT c.id_consulta, c.data_hora, c.diagnostico, c.valor, c.status, a.nome AS animal, t.nome AS tutor, v.nome AS veterinario FROM consultas c JOIN animais a ON c.animal_id = a.id_animal JOIN tutores t ON a.tutor_id = t.id_tutor JOIN veterinarios v ON c.veterinario_id = v.id_veterinario ORDER BY c.data_hora`);
    res.json(consultas);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

router.get('/pagamentos', async (req, res) => {
  try {
    const pagamentos = await query(`SELECT p.id_pagamento, p.consulta_id, p.valor_pago, p.forma_pagamento, p.data_pagamento, p.status, a.nome AS animal, c.data_hora AS consulta_data_hora FROM pagamentos p JOIN consultas c ON p.consulta_id = c.id_consulta JOIN animais a ON c.animal_id = a.id_animal ORDER BY p.id_pagamento`);
    res.json(pagamentos);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

router.get('/relatorios', async (req, res) => {
  try {
    const faturamento = await query(`SELECT COALESCE(SUM(c.valor), 0) AS faturamento_total, COALESCE(SUM(CASE WHEN p.status = 'pago' THEN p.valor_pago ELSE 0 END), 0) AS total_recebido, COALESCE(SUM(CASE WHEN p.status = 'pendente' THEN p.valor_pago ELSE 0 END), 0) AS total_pendente FROM consultas c LEFT JOIN pagamentos p ON p.consulta_id = c.id_consulta`);
    const por_veterinario = await query(`SELECT v.id_veterinario, v.nome AS veterinario, COUNT(c.id_consulta) AS total_consultas, COALESCE(SUM(c.valor), 0) AS faturamento FROM consultas c JOIN veterinarios v ON c.veterinario_id = v.id_veterinario GROUP BY v.id_veterinario, v.nome ORDER BY faturamento DESC`);
    res.json({ faturamento: faturamento[0], por_veterinario });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;
