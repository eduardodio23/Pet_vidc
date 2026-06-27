const assert = require('assert');
const http = require('http');
const app = require('../src/app');

async function request(path, options = {}) {
  const server = app.listen(0);
  await new Promise((resolve) => server.once('listening', resolve));
  const { port } = server.address();
  const response = await new Promise((resolve, reject) => {
    const req = http.request(
      {
        hostname: '127.0.0.1',
        port,
        path,
        method: options.method || 'GET',
        headers: options.headers || {},
      },
      (res) => {
        let data = '';
        res.on('data', (chunk) => {
          data += chunk;
        });
        res.on('end', () => {
          resolve({ statusCode: res.statusCode, body: data });
        });
      }
    );
    req.on('error', reject);
    if (options.body) {
      req.write(JSON.stringify(options.body));
    }
    req.end();
  });
  await new Promise((resolve) => server.close(resolve));
  return response;
}

(async () => {
  const veterinarios = await request('/api/veterinarios');
  assert.strictEqual(veterinarios.statusCode, 200, 'GET /api/veterinarios should return 200');
  const vets = JSON.parse(veterinarios.body);
  assert.ok(Array.isArray(vets), 'Veterinários should be an array');

  const animais = await request('/api/animais');
  assert.strictEqual(animais.statusCode, 200, 'GET /api/animais should return 200');
  const pets = JSON.parse(animais.body);
  assert.ok(Array.isArray(pets), 'Animais should be an array');

  const dashboard = await request('/api/relatorios/dashboard');
  assert.strictEqual(dashboard.statusCode, 200, 'GET /api/relatorios/dashboard should return 200');
  const dashboardData = JSON.parse(dashboard.body);
  assert.ok(dashboardData.total_consultas !== undefined, 'Dashboard should include total_consultas');

  console.log('API integration tests passed');
})().catch((error) => {
  console.error(error);
  process.exit(1);
});
