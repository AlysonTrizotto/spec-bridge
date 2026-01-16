#!/bin/bash

# Cores para o output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Função para verificar e instalar dependências
check_dependency() {
    local cmd=$1
    local pkg=$2
    local is_module=$3
    
    local check_cmd
    if [ "$is_module" == "true" ]; then
        # Check if module exists AND can run (some systems have the module but not ensurepip)
        check_cmd="python3 -m $cmd --help"
        if [ "$cmd" == "venv" ]; then
             # More robust check for Ubuntu: venv needs ensurepip to be useful
             check_cmd="python3 -c 'import venv, ensurepip'"
        fi
    else
        check_cmd="command -v $cmd"
    fi

    if ! eval "$check_cmd" &> /dev/null; then
        echo -e "${YELLOW}[!] $cmd não encontrado ou incompleto.${NC}"
        if [[ "$OSTYPE" == "linux-gnu"* ]]; then
            echo -e "${BLUE}[*] Tentando instalar $pkg automaticamente...${NC}"
            sudo apt update && sudo apt install -y "$pkg"
        else
            echo -e "${RED}[x] Auto-instalação não disponível para este SO. Por favor, instale $pkg manualmente.${NC}"
            exit 1
        fi
    else
        echo -e "${GREEN}[✓] $cmd detectado.${NC}"
    fi
}

echo -e "${BLUE}===========================================${NC}"
echo -e "${BLUE}===       SPEC-BRIDGE SETUP (UNIX)      ===${NC}"
echo -e "${BLUE}===========================================${NC}"

# 0. Verificar Dependências Cruciais
echo -e "${GREEN}[0/5]${NC} Verificando tecnologias base..."
check_dependency "node" "nodejs"
check_dependency "npm" "npm"
check_dependency "python3" "python3"
check_dependency "pip3" "python3-pip"
# Garante venv E ensurepip (comum falhar no Ubuntu se faltar python3-venv)
check_dependency "venv" "python3-venv" "true"

# 0.1 Preparar Virtual Environment
if [ ! -d ".spec-bridge/venv" ]; then
    echo -e "${BLUE}[*] Criando ambiente virtual Python...${NC}"
    if ! python3 -m venv .spec-bridge/venv; then
        echo -e "${RED}[x] Falha ao criar ambiente virtual. Tentando instalar python3-venv explicitamente...${NC}"
        sudo apt install -y python3-venv
        python3 -m venv .spec-bridge/venv || { echo -e "${RED}[x] Falha crítica na criação do Venv.${NC}"; exit 1; }
    fi
fi

VENV_PIP=".spec-bridge/venv/bin/pip"
if [ ! -f "$VENV_PIP" ]; then
    echo -e "${RED}[x] Erro: O Venv foi criado mas o PIP não está presente.${NC}"
    echo -e "${YELLOW}[!] Tentando corrigir instalando python3-venv e recriando...${NC}"
    rm -rf .spec-bridge/venv
    sudo apt install -y python3-venv
    python3 -m venv .spec-bridge/venv
fi

# 1. Criar estrutura de diretórios
echo -e "${GREEN}[1/5]${NC} Criando diretórios de sistema..."
mkdir -p .spec-bridge/tools
mkdir -p docs/specs
mkdir -p bin

# 2. Clonar e Instalar ai-coders-context
echo -e "${GREEN}[2/5]${NC} Instalando ai-coders-context..."
if [ ! -d ".spec-bridge/tools/ai-coders-context" ]; then
    git clone https://github.com/vinilana/ai-coders-context .spec-bridge/tools/ai-coders-context
    (cd .spec-bridge/tools/ai-coders-context && npm install && npm run build)
else
    echo -e "${YELLOW}[-] ai-coders-context já instalado. Garantindo build...${NC}"
    (cd .spec-bridge/tools/ai-coders-context && npm run build)
fi

# 3. Clonar e Instalar spec-kit
echo -e "${GREEN}[3/5]${NC} Instalando spec-kit..."
if [ ! -d ".spec-bridge/tools/spec-kit" ]; then
    git clone https://github.com/github/spec-kit .spec-bridge/tools/spec-kit
    # Tenta instalar dependências Python se houver pyproject.toml
    if [ -f ".spec-bridge/tools/spec-kit/pyproject.toml" ]; then
        echo -e "${BLUE}[*] Instalando dependências Python do spec-kit no Venv...${NC}"
        $VENV_PIP install -e .spec-bridge/tools/spec-kit
    else
        echo -e "${YELLOW}[!] spec-kit não possui arquivo de dependências Python (pyproject.toml).${NC}"
    fi
else
    echo -e "${YELLOW}[-] spec-kit já instalado. Garantindo dependências no Venv...${NC}"
    $VENV_PIP install -e .spec-bridge/tools/spec-kit
fi

# 4. Criar o Bridge Inteligente (Node.js)
echo -e "${GREEN}[4/5]${NC} Criando o script de integração (Spec-Bridge)..."
cat << 'EOF' > bin/spec-bridge.js
const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');
const readline = require('readline');

const TOOLS_PATH = '.spec-bridge/tools';
const BASE_SPECS_PATH = 'docs/specs';
const CONTEXT_TOOL = path.join(TOOLS_PATH, 'ai-coders-context/dist/index.js');

function generateSpecs(featureName) {
    const FEATURE_PATH = path.join(BASE_SPECS_PATH, featureName);
    try {
        if (!fs.existsSync(FEATURE_PATH)) {
            fs.mkdirSync(FEATURE_PATH, { recursive: true });
        }

        console.error(`[1/3] Varrendo codebase com ai-coders-context...`);
        try {
            execSync(`node ${CONTEXT_TOOL} init . --lang pt-BR`, { stdio: 'inherit' });
        } catch (e) {
            console.error("Aviso: Falha ao rodar init completo, procedendo com geração de specs básica.");
        }

        let contextSummary = "Contexto base não capturado.";
        const contextFile = '.context/docs/project-overview.md';
        if (fs.existsSync(contextFile)) {
            contextSummary = fs.readFileSync(contextFile, 'utf8').substring(0, 800) + "...";
        }

        console.error(`[2/3] Preparando base técnica (Taxonomia RPIC)...`);
        const files = [
            { ext: 'r.spec.md', title: 'Research & Business Truth' },
            { ext: 'p.spec.md', title: 'Technical Planning & Contracts' },
            { ext: 'i.spec.md', title: 'Implementation Plan' },
            { ext: 'c.spec.md', title: 'Environment Configuration' }
        ];

        console.error(`[3/3] Gerando arquivos de especificação...`);
        files.forEach(file => {
            const fileName = `${featureName}.${file.ext}`;
            const fullPath = path.join(FEATURE_PATH, fileName);
            if (!fs.existsSync(fullPath)) {
                const dateHeader = new Date().toLocaleString('pt-BR');
                const content = `# 📝 ${file.title} - ${featureName}\n\n> Gerado via Spec-Bridge em ${dateHeader}\n\n## 🔍 Contexto Técnico Base\n${contextSummary}\n\n---\n## 📋 Checklist de Engenharia\n- [ ] Validado contexto local\n- [ ] Revisado arquitetura\n- [ ] Alinhado com requisitos de negócio`;
                fs.writeFileSync(fullPath, content);
                console.error(`   ✅ Criado: ${fileName}`);
            } else {
                console.error(`   ⚠️  Pulado (já existe): ${fileName}`);
            }
        });

        return `Sucesso! Specs para "${featureName}" geradas em ${FEATURE_PATH}`;
    } catch (err) {
        throw new Error(`Falha no bridge: ${err.message}`);
    }
}

async function handleMCP() {
    const rl = readline.createInterface({ input: process.stdin, terminal: false });
    rl.on('line', (line) => {
        try {
            const request = JSON.parse(line);
            let response = { jsonrpc: "2.0", id: request.id };
            switch (request.method) {
                case 'initialize':
                    response.result = { protocolVersion: "2024-11-05", capabilities: { tools: {} }, serverInfo: { name: "spec-bridge", version: "1.0.0" } };
                    break;
                case 'tools/list':
                    response.result = { tools: [{ name: "generate_specs", description: "Gera as especificações RPIC baseadas no contexto do projeto.", inputSchema: { type: "object", properties: { feature_name: { type: "string" } }, required: ["feature_name"] } }] };
                    break;
                case 'tools/call':
                    if (request.params.name === 'generate_specs') {
                        const result = generateSpecs(request.params.arguments.feature_name);
                        response.result = { content: [{ type: "text", text: result }] };
                    }
                    break;
                case 'notifications/initialized': return;
                default: response.error = { code: -32601, message: "Método não encontrado" };
            }
            process.stdout.write(JSON.stringify(response) + '\n');
        } catch (e) { console.error("Erro MCP:", e.message); }
    });
}

const cliArg = process.argv[2];
if (cliArg) {
    try { console.log(generateSpecs(cliArg)); } catch (e) { console.error(e.message); process.exit(1); }
} else { handleMCP(); }
EOF

# 5. Dar permissão de execução
chmod +x bin/spec-bridge.js

echo -e "\n${GREEN}[5/5] Setup concluído com sucesso!${NC}"
echo -e "${YELLOW}================================================================${NC}"
echo -e "${YELLOW}        COPIE E COLE ISSO NO SEU IDE (Antigravity/Cursor)       ${NC}"
echo -e "${YELLOW}================================================================${NC}"
echo -e "Vá em Settings > Features > MCP > Add New MCP Server:"
echo -e "  - Name: ${BLUE}spec-bridge${NC}"
echo -e "  - Type: ${BLUE}command${NC}"
echo -e "  - Command: ${GREEN}node $(pwd)/bin/spec-bridge.js${NC}"
echo -e "${YELLOW}================================================================${NC}"
echo -e "\nPara Windsurf (Cascade Tools):"
echo -e "  - Command: ${GREEN}node $(pwd)/bin/spec-bridge.js \${feature_name}${NC}"
echo -e "${YELLOW}================================================================${NC}"

echo -e "\n${YELLOW}OU adicione este JSON ao seu arquivo de configurações (Avançado):${NC}"
echo -e "${GREEN}"
echo -e "{"
echo -e "  \"mcpServers\": {"
echo -e "    \"spec-bridge\": {"
echo -e "      \"command\": \"node\","
echo -e "      \"args\": [\"$(pwd)/bin/spec-bridge.js\"],"
echo -e "      \"enabled\": true"
echo -e "    }"
echo -e "  }"
echo -e "}"
echo -e "${NC}"
echo -e "${YELLOW}================================================================${NC}"

echo -e "\nPara teste manual: ${BLUE}node bin/spec-bridge.js teste-feature${NC}"