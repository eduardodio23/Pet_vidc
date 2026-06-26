const app = require('./src/app');
require('dotenv').config();

const PORT = process.env.PORT || 3001;

app.listen(PORT, () => {
    console.log(`PetVida api rodando na porta ${PORT}`);
    console.log(`teste: http://localhost:${PORT}/api`);
});
