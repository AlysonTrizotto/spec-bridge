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

where git >nul 2>nul
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Git nao encontrado.
    exit /b 1
) else (
    echo [OK] Git detectado.
)

:: Detecacao inteligente do Executavel Python
set PYTHON_EXE=

python --version >nul 2>nul
if %ERRORLEVEL% equ 0 (
    set PYTHON_EXE=python
    goto :FoundPython
)

python3 --version >nul 2>nul
if %ERRORLEVEL% equ 0 (
    set PYTHON_EXE=python3
    goto :FoundPython
)

py --version >nul 2>nul
if %ERRORLEVEL% equ 0 (
    set PYTHON_EXE=py
    goto :FoundPython
)

echo [ERROR] Python nao encontrado ou e apenas um atalho da Microsoft Store.
echo Por favor, instale o Python oficial em https://python.org/
exit /b 1

:FoundPython
echo [OK] Usando interpretador: %PYTHON_EXE%
%PYTHON_EXE% --version

:: Verificar modulo venv
set USE_VIRTUALENV=false
%PYTHON_EXE% -c "import venv" >nul 2>nul
if %ERRORLEVEL% equ 0 (
    echo [OK] Modulo 'venv' detectado.
    goto :CreateDirs
)

echo [WARN] Modulo nativo 'venv' nao encontrado.
echo [*] Tentando instalar 'virtualenv' via PIP como fallback...

call %PYTHON_EXE% -m pip install --user virtualenv
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Falha ao instalar 'virtualenv'.
    echo O Python detectado (%PYTHON_EXE%) nao possui 'venv' nem 'pip' funcionais.
    exit /b 1
)

set USE_VIRTUALENV=true
echo [OK] 'virtualenv' instalado com sucesso.

:CreateDirs
:: 1. Criar estrutura de diretorios
echo [1/5] Criando diretorios de sistema...
if not exist ".spec-bridge\tools" mkdir ".spec-bridge\tools"
if not exist "docs\specs" mkdir "docs\specs"
if not exist "bin" mkdir "bin"

:: 1.1 Preparar Virtual Environment
if exist ".spec-bridge\venv" goto :PipCheck

echo [*] Criando ambiente virtual Python...
if "%USE_VIRTUALENV%"=="true" goto :UseVirtualEnv

:UseNativeVenv
call %PYTHON_EXE% -m venv ".spec-bridge\venv"
if %ERRORLEVEL% neq 0 goto :VenvFail
goto :PipCheck

:UseVirtualEnv
call %PYTHON_EXE% -m virtualenv ".spec-bridge\venv"
if %ERRORLEVEL% neq 0 goto :VenvFail
goto :PipCheck

:VenvFail
echo [ERROR] Falha ao criar ambiente virtual.
exit /b 1

:PipCheck
set VENV_PIP=.spec-bridge\venv\Scripts\pip.exe

if exist "%VENV_PIP%" goto :SuccessVenv

echo [ERROR] Venv criado mas %VENV_PIP% nao encontrado.
echo Tentando recriar...
if exist ".spec-bridge\venv" rmdir /s /q ".spec-bridge\venv"

if "%USE_VIRTUALENV%"=="true" (
    call %PYTHON_EXE% -m virtualenv ".spec-bridge\venv"
) else (
    call %PYTHON_EXE% -m venv ".spec-bridge\venv"
)

if not exist "%VENV_PIP%" (
    echo [ERROR] Falha critica ao preparar o ambiente Python.
    exit /b 1
)

:SuccessVenv

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
echo         if (^^!fs.existsSync(FEATURE_PATH^)^) fs.mkdirSync(FEATURE_PATH, { recursive: true }^);
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
echo             { ext: 'r.spec.md', title: 'Research and Business Truth' },
echo             { ext: 'p.spec.md', title: 'Technical Planning and Contracts' },
echo             { ext: 'i.spec.md', title: 'Implementation Plan' },
echo             { ext: 'c.spec.md', title: 'Environment Configuration' }
echo         ];
echo         console.error(`[3/3] Gerando arquivos de especificacao...`^);
echo         files.forEach(file =^> {
echo             const fileName = `${featureName}.${file.ext}`;
echo             const fullPath = path.join(FEATURE_PATH, fileName^);
echo             if (^^!fs.existsSync(fullPath^)^) {
echo                 const dateHeader = new Date(^).toLocaleString('pt-BR'^);
echo                 const content = `# 📝 ${file.title} - ${featureName}\n\n^> Gerado via Spec-Bridge em ${dateHeader}\n\n## 🔍 Contexto Tecnico Base\n${contextSummary}\n\n---\n## 📋 Checklist de Engenharia\n- [ ] Validado contexto local\n- [ ] Revisado arquitetura\n- [ ] Alinhado com requisitos de negocio`;
echo                 fs.writeFileSync(fullPath, content^);
echo                 console.error(`   OK Criado: ${fileName}`^);
echo             } else {
echo                 console.error(`   ^^!^^! Pulado (ja existe^): ${fileName}`^);
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