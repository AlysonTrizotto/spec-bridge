# 📝 Technical Planning & Contracts - automation-scripts-core

## 🏗️ Arquitetura de Automação

### 1. Fluxo de Dependências
O setup segue a seguinte árvore de inicialização:
1. **Core Runtime**: Node.js & NPM (Necessário para o Bridge e Context Tool).
2. **Spec Engine**: Python 3.11+ & Pip.
3. **Isolamento**: Criação do Venv em `.spec-bridge/venv` para evitar conflitos de sistema.
4. **Módulos Base**: 
   - `ai-coders-context`: Clonado e buildado (`npm run build`).
   - `spec-kit`: Clonado e instalado via Pip `-e` no Venv.

### 2. Detalhamento dos Scripts

#### [setup-spec-bridge.sh](file:///home/alyson/Documentos/work/spec-bridge/setup-spec-bridge.sh)
- **Função `check_dependency`**: Valida binários e módulos Python (com check específico para `venv` no Ubuntu).
- **Auto-Instalação**: Usa `sudo apt` para instalar dependências faltantes no Linux.
- **Venv Management**: Cria e valida o ambiente virtual, garantindo que o `pip` interno esteja funcional.
- **Heredoc Generation**: Gera o `bin/spec-bridge.js` dinamicamente com suporte a MCP.

#### [setup-spec-bridge.bat](file:///home/alyson/Documentos/work/spec-bridge/setup-spec-bridge.bat)
- **Paridade**: Implementa a mesma lógica de verificação de dependências e criação de Venv para Windows.
- **Escapamento**: Resolve problemas de caminhos com backslash (`\`) para o JSON do MCP.

#### [test-cleanup-deps.sh](file:///home/alyson/Documentos/work/spec-bridge/test-cleanup-deps.sh)
- **Cleanup Local**: Remove `.spec-bridge/tools`, `.spec-bridge/venv` e `bin/spec-bridge.js`.
- **System Purge**: Remove `nodejs`, `npm`, `python3-pip` e `python3-venv` via `apt`.
- **Smart NVM**: Detecta se o Node é do NVM e oferece renomear a pasta para "esconder" do PATH.

### 3. Definição do Bridge (MCP Protocol)
O arquivo gerado `bin/spec-bridge.js` implementa o protocolo JSON-RPC via stdio para integração nativa com o Antigravity IDE.