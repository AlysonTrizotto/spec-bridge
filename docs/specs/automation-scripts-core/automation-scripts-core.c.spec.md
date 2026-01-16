# 📝 Environment Configuration - automation-scripts-core

## ⚙️ Variáveis e Caminhos

### Caminhos Internos
- `TOOLS_PATH`: `.spec-bridge/tools` (Local de clones do context e kit).
- `VENV_PATH`: `.spec-bridge/venv` (Ambiente Python isolado).
- `BRIDGE_BIN`: `bin/spec-bridge.js` (Ponto de entrada do sistema).

### Dependências de Versão
- **Node.js**: >= 18.0.0.
- **Python**: >= 3.11.0.
- **Arquitetura**: x86_64 ou ARM64 (Linux/Windows).

### Configurações de MCP (JSON)
O bridge deve ser configurado no IDE com o seguinte contrato:
```json
{
  "command": "node",
  "args": [".../bin/spec-bridge.js"],
  "enabled": true
}
```

## 🎨 Design de Output
- **Cores (Linux)**: Usa códigos ANSI para GREEN, BLUE, YELLOW e RED.
- **Stderr vs Stdout**: Logs de log/erro são enviados para `stderr` para não quebrar o protocolo JSON-RPC no `stdout`.