# 📝 Implementation Plan - automation-scripts-core

## 🚀 Passo a Passo de Execução

### Fase 1: Setup Local
- [ ] Executar `chmod +x setup-spec-bridge.sh`.
- [ ] Rodar `./setup-spec-bridge.sh`.
- [ ] Validar se as dependências do `apt` foram resolvidas.
- [ ] Confirmar criação do Venv em `.spec-bridge/venv`.

### Fase 2: Geração do Bridge
- [ ] Verificar se `bin/spec-bridge.js` possui permissão de execução.
- [ ] Testar modo CLI: `node bin/spec-bridge.js test`.
- [ ] Testar modo MCP: Ativar no IDE e verificar bolinha verde (Connected).

### Fase 3: Limpeza e Teste de Stress
- [ ] Rodar `test-cleanup-deps.sh`.
- [ ] Confirmar remoção dos diretórios locais.
- [ ] Confirmar que `node -v` e `pip3 -v` falham após o purge (se não for NVM).
- [ ] Re-executar setup e validar auto-recuperação.

## ⚠️ Pontos de Atenção
1. **Permissões**: O script de cleanup exige `sudo` para remover pacotes APT.
2. **Backslashes**: No Windows, garantir que o script `.bat` use `\\` no JSON gerado.