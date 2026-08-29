# Task Manager

Gerenciador de Tarefas (Task Manager) com Next.js 14 e PostgreSQL.

> Este repositório contém a aplicação web completa junto com sua infraestrutura em Kubernetes (k3d), automatizada via Terraform e Helm, CI/CD no GitHub Actions e Stack de Observabilidade (Prometheus, Grafana e Loki).

## Demonstração

![Task Manager UI](https://via.placeholder.com/800x500?text=Task+Manager+UI)

## Funcionalidades

- **CRUD completo** de tarefas (Create, Read, Update, Delete)
- **Status das tarefas**: pendente, em-andamento, concluída
- **Prioridades**: baixa, média, alta
- **Dashboard**: estatísticas e filtros
- **API REST**: endpoints para integração
- **Health check**: endpoint para monitoramento

## Stack Tecnológica

- **Frontend**: Next.js 14 (App Router), Tailwind CSS
- **Backend**: Next.js API Routes
- **Banco de dados**: PostgreSQL 15
- **Containerização**: Docker, Docker Compose
- **Testes**: Jest

## Estrutura do Projeto

```
task-manager/
├── app/              # App Next.js (App Router)
│   ├── api/          # API Routes
│   ├── layout.js     # Layout raiz
│   ├── page.js       # Página principal (UI)
│   └── globals.css   # Estilos globais Tailwind
├── lib/              # Funções de banco de dados
│   ├── db.js         # Pool PostgreSQL
│   └── dbConfig.js   # Configuração de conexão
├── tests/            # Testes Jest para API
├── Dockerfile        # Build da imagem Docker
├── docker-compose.yml # Ambiente local com Docker Compose
├── next.config.js    # Config Next.js
├── tailwind.config.js # Config Tailwind CSS
└── package.json      # Dependências
```

## Instalação e Execução Local

### Pré-requisitos

- Docker e Docker Compose
- Node.js 20+ (opcional, para desenvolvimento local sem Docker)

### Com Docker Compose (Recomendado)

```bash
# Iniciar containers
docker compose up -d

# Acessar a aplicação
open http://localhost:3000

# Verificar health check
curl http://localhost:3000/api/health

# Se precisar resetar o banco de dados
docker compose down -v
docker compose up -d
```

### Desenvolvimento Local

```bash
# Instalar dependências
npm install

# Criar arquivo .env (baseado em .env.example)
cp .env.example .env

# Executar migrations e iniciar servidor
npm run dev
```

## API REST

### Endpoints

| Método | Endpoint | Descrição |
|--------|----------|-----------|
| GET | `/api/tasks` | Listar todas as tarefas |
| GET | `/api/tasks/:id` | Buscar tarefa por ID |
| POST | `/api/tasks` | Criar nova tarefa |
| PUT | `/api/tasks/:id` | Atualizar tarefa |
| DELETE | `/api/tasks/:id` | Deletar tarefa |
| GET | `/api/health` | Health check |

### Exemplo de Request

```bash
# Criar tarefa
curl -X POST http://localhost:3000/api/tasks \
  -H "Content-Type: application/json" \
  -d '{"title":"Minha tarefa","description":"Descrição","priority":"alta","status":"pendente"}'

# Listar tarefas
curl http://localhost:3000/api/tasks
```

## Testes

```bash
# Antes de rodar testes, iniciar o servidor
npm run dev &

# Rodar testes
npm test
```

> Nota: Os testes precisam que o servidor esteja rodando em `http://localhost:3000`

## Docker

### Build da Imagem

```bash
docker build -t task-manager .
```

### Executar com Docker

```bash
docker run -p 3000:3000 task-manager
```

## Infraestrutura (Kubernetes, Terraform e Observabilidade)

Este projeto provisiona localmente um cluster Kubernetes com o k3d e utiliza o Terraform (e Helm) para realizar o deploy de toda a aplicação e da stack de observabilidade.

### Tecnologias Utilizadas:
- **k3d**: Cluster Kubernetes local.
- **Terraform**: Infraestrutura como código (IaC).
- **Helm**: Gerenciador de pacotes do Kubernetes (`kube-prometheus-stack` e `loki-stack`).
- **GitHub Actions**: Pipeline de CI/CD construindo a imagem Docker e enviando ao Docker Hub.

### Como Executar (Terraform)

1. Certifique-se de ter o `k3d`, `kubectl` e `terraform` instalados.
2. Acesse o diretório do Terraform:
   ```bash
   cd terraform
   ```
3. Inicie e aplique a infraestrutura:
   ```bash
   terraform init
   terraform apply -auto-approve
   ```
Isso criará o cluster k3d, os namespaces, instalará a observabilidade (Prometheus, Grafana, Loki) e fará o deploy da aplicação Task Manager e do banco PostgreSQL.

### Acessando a Observabilidade (Grafana)

Após o `terraform apply` concluir, a aplicação e os dashboards estarão no ar.

1. Faça o Port-Forward do Grafana para a sua máquina:
   ```bash
   kubectl port-forward svc/monitoring-grafana 3000:80 -n monitoring
   ```
2. Abra o navegador em: **http://localhost:3000**
3. **Usuário:** `admin`
4. **Senha:** _Verifique a secret gerada pelo Helm com o comando abaixo:_
   ```bash
   kubectl get secret monitoring-grafana -n monitoring -o jsonpath="{.data.admin-password}"
   ```
   *(E decodifique de base64, ou utilize a senha gerada aleatoriamente durante o apply).*

Lá você encontrará o dashboard pré-configurado **"Task Manager - Observability"**, exibindo consumo de recursos da aplicação e logs do Loki.

## Licença

MIT
