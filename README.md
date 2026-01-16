# 🚀 Spec-Bridge: RPIC Taxonomy Generator

O **Spec-Bridge** é uma ferramenta de automação de fluxo de trabalho projetada para unificar o `ai-coders-context` e o `spec-kit`. Ele prepara o ambiente de engenharia e gera automaticamente a taxonomia **RPIC** para novas funcionalidades, garantindo que o contexto do código seja preservado em cada especificação.

---

## 🛠️ O que é a Taxonomia RPIC?

O bridge organiza a documentação técnica em quatro pilares fundamentais:

*   **Research (`.r.spec.md`)**: Definições de negócio, requisitos e "verdades" do produto.
*   **Planning (`.p.spec.md`)**: Arquitetura, contratos de API e planejamento técnico.
*   **Implementation (`.i.spec.md`)**: Guia de execução passo a passo (checklist de código).
*   **Configuration (`.c.spec.md`)**: Variáveis de ambiente, infraestrutura e dependências.

---

## 📋 Pré-requisitos

O Spec-Bridge unifica ferramentas em Node.js e Python. O instalador tentará detectar e instalar as seguintes tecnologias automaticamente no Linux (Ubuntu):

*   **Git**: Essencial para clonar os módulos base.
*   **Node.js (v18+) & NPM**: Necessários para o core do bridge e o `ai-coders-context`.
*   **Python (v3.11+) & Pip**: Necessários para o motor de especificações do `spec-kit`.

---

## ⚙️ Instalação e Setup

O setup automatizado irá clonar os repositórios necessários, instalar as dependências do NPM e criar o executável do bridge na sua máquina.

### No Windows
1. Localize o arquivo `setup-spec-bridge.bat`.
2. Execute-o como **Administrador** (necessário para configuração de caminhos e permissões).

### No Linux (Ubuntu) ou macOS
1. Abra o terminal na raiz do projeto.
2. Dê permissão de execução e inicie o setup:

```bash
chmod +x setup-spec-bridge.sh
./setup-spec-bridge.sh
```

---

## 🤖 Configuração de IA (MCP)

O Spec-Bridge funciona como um servidor **MCP (Model Context Protocol)**, permitindo que IAs como Cursor e Windsurf executem comandos de geração de specs diretamente pelo chat.

### 1. Antigravity IDE / Cursor
1. Vá em **Settings** > **Features** > **MCP**.
2. Clique em **+ Add New MCP Server**.
3. Configure como:
   - **Name**: `spec-bridge`
   - **Type**: `command`
   - **Command**: `node bin/spec-bridge.js`

### 2. Windsurf
1. Acesse **Settings** > **AI Tools** ou o dashboard do **Cascade**.
2. Adicione um novo comando externo:
   - **Name**: `spec-bridge`
   - **Command**: `node bin/spec-bridge.js`
   - **Arguments**: `{{feature_name}}`

### 3. Configuração via JSON (Avançado)
Se você preferir configurar editando o arquivo de configurações do seu IDE (ex: `cursor-settings.json`), adicione este bloco ao objeto `mcpServers`:

```json
{
  "mcpServers": {
    "spec-bridge": {
      "command": "node",
      "args": ["/caminho/absoluto/para/bin/spec-bridge.js"],
      "enabled": true
    }
  }
}
```

> [!TIP]
> Em alguns ambientes, pode ser necessário fornecer o caminho absoluto para o comando:
> `node /home/alyson/Documentos/work/spec-bridge/bin/spec-bridge.js`

---

## 🚀 Como usar via Terminal

Se desejar gerar as especificações manualmente sem usar a interface da IA:

```bash
node bin/spec-bridge.js nome-da-minha-feature
```

> [!NOTE]
> **Resultado**: Uma nova pasta será criada em `docs/specs/nome-da-minha-feature/` contendo os 4 arquivos da taxonomia devidamente preenchidos com o contexto atual do projeto.

---

## 📂 Estrutura do Projeto após Setup

```text
.
├── bin/
│   └── spec-bridge.js         # O script unificador (Bridge)
├── docs/
│   └── specs/                 # Destino das especificações geradas
├── .spec-bridge/
│   └── tools/                 # Repositórios clonados (context & kit)
├── setup-spec-bridge.bat      # Instalador Windows
└── setup-spec-bridge.sh       # Instalador Linux/Mac
```