@echo off
setlocal enabledelayedexpansion

echo ===========================================
echo ===       SPEC-BRIDGE SETUP (WIN)       ===
echo ===========================================

:: 0. Verificar Dependencias Cruciais
echo [0/5] Verificando tecnologias base...
where node >nul 2>nul
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Node.js nao encontrado. Por favor, instale em https://nodejs.org/
    exit /b 1
) else (
    echo [OK] Node.js detectado.
)

where npm >nul 2>nul
if %ERRORLEVEL% neq 0 (
    echo [ERROR] NPM nao encontrado.
    exit /b 1
) else (
    echo [OK] NPM detectado.
)

where python >nul 2>nul
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Python nao encontrado. Por favor, instale em https://python.org/
    exit /b 1
) else (
    echo [OK] Python detectado.
)

:: Verificar se o modulo venv esta disponivel (incluindo ensurepip)
python -c "import venv, ensurepip" >nul 2>nul
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Modulo 'venv' ou 'ensurepip' do Python nao detectado. 
    echo Por favor, reinstale o Python e garanta que 'pip' e 'venv' estao marcados na instalacao.
    exit /b 1
) else (
    echo [OK] Modulo 'venv' detectado.
)

:: 1. Criar estrutura de diretorios
echo [1/5] Criando diretorios de sistema...
if not exist ".spec-bridge\tools" mkdir ".spec-bridge\tools"
if not exist "docs\specs" mkdir "docs\specs"
if not exist "bin" mkdir "bin"

:: 1.1 Preparar Virtual Environment
if not exist ".spec-bridge\venv" (
    echo [*] Criando ambiente virtual Python...
    python -m venv .spec-bridge\venv
    if %ERRORLEVEL% neq 0 (
        echo [ERROR] Falha ao criar ambiente virtual.
        exit /b 1
    )
)
set VENV_PIP=.spec-bridge\venv\Scripts\pip.exe

if not exist "%VENV_PIP%" (
    echo [ERROR] Venv criado mas %VENV_PIP% nao encontrado.
    echo Tentando recriar...
    rmdir /s /q .spec-bridge\venv
    python -m venv .spec-bridge\venv
    if not exist "%VENV_PIP%" (
        echo [ERROR] Falha critica ao preparar o ambiente Python.
        exit /b 1
    )
)

:: 2. Clonar e Instalar ai-coders-context
echo [2/5] Instalando ai-coders-context...
if not exist ".spec-bridge\tools\ai-coders-context" (
    git clone https://github.com/vinilana/ai-coders-context .spec-bridge\tools\ai-coders-context
    pushd .spec-bridge\tools\ai-coders-context
    call npm install
    call npm run build
    popd
) else (
    echo ai-coders-context ja instalado. Garantindo build...
    pushd .spec-bridge\tools\ai-coders-context
    call npm run build
    popd
)

:: 3. Clonar e Instalar spec-kit
echo [3/5] Instalando spec-kit...
if not exist ".spec-bridge\tools\spec-kit" (
    git clone https://github.com/github/spec-kit .spec-bridge\tools\spec-kit
)

if exist ".spec-bridge\tools\spec-kit\pyproject.toml" (
    echo [OK] Instalando dependencias Python do spec-kit no Venv...
    call %VENV_PIP% install -e .spec-bridge\tools\spec-kit
) else (
    echo spec-kit ja instalado ou sem arquivo de dependencias. Garantindo Venv...
    call %VENV_PIP% install -e .spec-bridge\tools\spec-kit
)

:: 4. Criar o Bridge Inteligente (Node.js)
echo [4/5] Criando o script de integracao (Spec-Bridge)...
(
echo const { execSync } = require('child_process'^);
echo const fs = require('fs'^);
echo const path = require('path'^);
echo const readline = require('readline'^);
echo.
echo const TOOLS_PATH = '.spec-bridge/tools';
echo const BASE_SPECS_PATH = 'docs/specs';
echo const CONTEXT_TOOL = path.join(TOOLS_PATH, 'ai-coders-context/dist/index.js'^);
echo.
echo function generateSpecs(featureName^) {
echo     const FEATURE_PATH = path.join(BASE_SPECS_PATH, featureName^);
echo     try {
echo         if (!fs.existsSync(FEATURE_PATH^)^) fs.mkdirSync(FEATURE_PATH, { recursive: true }^);
echo         console.error(`[1/3] Varrendo codebase com ai-coders-context...`^);
echo         try {
echo             execSync(`node ${CONTEXT_TOOL} init . --lang pt-BR`, { stdio: 'inherit' }^);
echo         } catch (e^) {
echo             console.error("Aviso: Falha ao rodar init completo, procedendo com geracao de specs basica."^);
echo         }
echo         let contextSummary = "Contexto base nao capturado.";
echo         const contextFile = '.context/docs/project-overview.md';
echo         if (fs.existsSync(contextFile^)^) {
echo             contextSummary = fs.readFileSync(contextFile, 'utf8'^).substring(0, 800^) + "...";
echo         }
echo         console.error(`[2/3] Preparando base tecnica (Taxonomia RPIC^)...`^);
echo         const files = [
echo             { ext: 'r.spec.md', title: 'Research ^& Business Truth' },
echo             { ext: 'p.spec.md', title: 'Technical Planning ^& Contracts' },
echo             { ext: 'i.spec.md', title: 'Implementation Plan' },
echo             { ext: 'c.spec.md', title: 'Environment Configuration' }
echo         ];
echo         console.error(`[3/3] Gerando arquivos de especificacao...`^);
echo         files.forEach(file =^> {
echo             const fileName = `${featureName}.${file.ext}`;
echo             const fullPath = path.join(FEATURE_PATH, fileName^);
echo             if (!fs.existsSync(fullPath^)^) {
echo                 const dateHeader = new Date(^).toLocaleString('pt-BR'^);
echo                 const content = `# 📝 ${file.title} - ${featureName}\n\n^> Gerado via Spec-Bridge em ${dateHeader}\n\n## 🔍 Contexto Tecnico Base\n${contextSummary}\n\n---\n## 📋 Checklist de Engenharia\n- [ ] Validado contexto local\n- [ ] Revisado arquitetura\n- [ ] Alinhado com requisitos de negocio`;
echo                 fs.writeFileSync(fullPath, content^);
echo                 console.error(`   OK Criado: ${fileName}`^);
echo             } else {
echo                 console.error(`   !! Pulado (ja existe^): ${fileName}`^);
echo             }
echo         }^);
echo         return `Sucesso! Specs para "${featureName}" geradas em ${FEATURE_PATH}`;
echo     } catch (err^) {
echo         throw new Error(`Falha no bridge: ${err.message}`^);
echo     }
echo }
echo.
echo async function handleMCP(^) {
echo     const rl = readline.createInterface({ input: process.stdin, terminal: false }^);
echo     rl.on('line', (line^) =^> {
echo         try {
echo             const request = JSON.parse(line^);
echo             let response = { jsonrpc: "2.0", id: request.id };
echo             switch (request.method^) {
echo                 case 'initialize':
echo                     response.result = { protocolVersion: "2024-11-05", capabilities: { tools: {} }, serverInfo: { name: "spec-bridge", version: "1.0.0" } };
echo                     break;
echo                 case 'tools/list':
echo                     response.result = { tools: [{ name: "generate_specs", description: "Gera as especificacoes RPIC baseadas no contexto do projeto.", inputSchema: { type: "object", properties: { feature_name: { type: "string" } }, required: ["feature_name"] } }] };
echo                     break;
echo                 case 'tools/call':
echo                     if (request.params.name === 'generate_specs'^) {
echo                         const result = generateSpecs(request.params.arguments.feature_name^);
echo                         response.result = { content: [{ type: "text", text: result }] };
echo                     }
echo                     break;
echo                 case 'notifications/initialized': return;
echo                 default: response.error = { code: -32601, message: "Metodo nao encontrado" };
echo             }
echo             process.stdout.write(JSON.stringify(response^) + '\n'^);
echo         } catch (e^) { console.error("Erro MCP:", e.message^); }
echo     }^);
echo }
echo.
echo const cliArg = process.argv[2];
echo if (cliArg^) {
echo     try { console.log(generateSpecs(cliArg^)^); } catch (e^) { console.error(e.message^); process.exit(1^); }
echo } else { handleMCP(^); }
) > bin\spec-bridge.js

echo.
echo [5/5] Setup concluido com sucesso!
echo ================================================================
echo         COPIE E COLE ISSO NO SEU IDE (Antigravity/Cursor)       
echo ================================================================
echo Va em Settings ^> Features ^> MCP ^> Add New MCP Server:
echo   - Name: spec-bridge
echo   - Type: command
echo   - Command: node %CD%\bin\spec-bridge.js
echo ================================================================
echo.
echo Para Windsurf (Cascade Tools):
echo   - Command: node %CD%\bin\spec-bridge.js ${feature_name}
echo ================================================================
echo.
echo OU adicione este JSON ao seu arquivo de configuracoes (Avancado):
echo {
echo   "mcpServers": {
echo     "spec-bridge": {
echo       "command": "node",
echo       "args": ["%CD:\=\\%\\bin\\spec-bridge.js"],
echo       "enabled": true
echo     }
echo   }
echo }
echo ================================================================
echo.
echo Para teste manual: node bin\spec-bridge.js teste-feature
pause