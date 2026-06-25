# Pet_vidc

## Como conectar ao banco de dados

### 1) Instalar MySQL

No Windows, instale o MySQL Community Server e o MySQL Shell/Client.

### 2) Iniciar o servidor MySQL

- Abra o MySQL Server como serviço no Windows ou use o MySQL Workbench.
- Se estiver usando a linha de comando, verifique se o serviço está em execução.

### 3) Conectar usando o cliente MySQL

No terminal `cmd`, execute:

```bash
mysql -u root -p
```

Depois digite a senha do usuário `root`.

Para conectar diretamente ao banco de dados `pet_vida`:

```bash
mysql -u root -p pet_vida
```

> Substitua `root` pelo seu usuário e digite a senha quando solicitado.

#### Problema: `'mysql' não é reconhecido`

Se aparecer este erro, significa que o cliente não está no PATH do Windows ou o servidor MySQL não está configurado corretamente.

1) Verifique se o MySQL está instalado.
2) No seu sistema, o executável está em:

```bash
"C:\Program Files\MySQL\MySQL Server 8.3\bin\mysql.exe"
```

3) Use o caminho completo para conectar:

```bash
"C:\Program Files\MySQL\MySQL Server 8.3\bin\mysql.exe" -u root -p pet_vida
```

4) Se ainda houver erro, pode ser que o servidor MySQL não esteja em execução:
- Abra o `MySQL Installer` ou o `Services` do Windows.
- Procure por um serviço como `MySQL80` ou `MySQL`.
- Inicie o serviço.

5) Para deixar o comando `mysql` disponível em qualquer terminal, adicione ao PATH:
- Abra o Painel de Controle > Sistema > Configurações avançadas do sistema.
- Clique em `Variáveis de Ambiente`.
- Em `Path`, adicione:

```text
C:\Program Files\MySQL\MySQL Server 8.3\bin
```

6) Feche e reabra o terminal `cmd` e tente novamente.

### 4) Importar o esquema e os dados

Execute os scripts SQL na ordem correta:

```bash
mysql -u root -p < pet_vida_1.sql
mysql -u root -p < pet_vida_2.sql
mysql -u root -p < pet_vida_3.sql
mysql -u root -p < pet_vida_4.sql
mysql -u root -p < pet_vida_5.sql
mysql -u root -p < pet_vida_6.sql
mysql -u root -p pet_vida < pet_vida_7.sql
```

### 5) Executar relatórios

Dentro do banco `pet_vida`, você pode rodar o arquivo de relatórios:

```bash
mysql -u root -p pet_vida < database/reports.sql
```

### 6) Conectar com ferramentas gráficas

Se preferir, use:

- MySQL Workbench
- HeidiSQL
- DBeaver

Basta configurar conexão para:

- Host: `localhost`
- Porta: `3306`
- Banco: `pet_vida`
- Usuário: `root` (ou outro que você tenha)
- Senha: sua senha MySQL

### 7) Conectar via VS Code

#### Opção 1: Terminal integrado

1. Abra o terminal integrado no VS Code: `Ctrl + ``.
2. Navegue até o projeto:
   ```bash
   cd c:\Users\aluno.den\Documents\Pet_vidc
   ```
3. Conecte com o cliente MySQL:
   ```bash
   mysql -u root -p pet_vida
   ```
4. Se `mysql` não for reconhecido, use o caminho completo do executável:
   ```bash
   "C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe" -u root -p pet_vida
   ```

#### Opção 2: Extensão de banco de dados no VS Code

1. Instale uma extensão como `SQLTools`, `MySQL`, `MySQL Manager` ou `MySQL Shell`.
2. Crie uma nova conexão com:
   - Host: `localhost`
   - Porta: `3306`
   - Usuário: `root`
   - Senha: sua senha MySQL
   - Banco: `pet_vida`
3. Abra ou crie um arquivo `.sql` e execute as consultas com a extensão.

> A vantagem do VS Code é que você pode editar os arquivos SQL e rodá-los no mesmo ambiente, sem sair do editor.
