# 📝 Research & Business Truth - automation-scripts-core

> Gerado via Spec-Bridge em 16/01/2026, 16:01:43
> Refinado para detalhamento dos scripts de automação.

## 🔍 Contexto Técnico Base
Este módulo contém o núcleo de automação do Spec-Bridge, responsável pelo setup multiplataforma e gestão de dependências.

### User Stories
- **Portabilidade**: Como desenvolvedor, quero rodar um único comando para preparar meu ambiente de especificação tanto no Linux quanto no Windows.
- **Isolamento**: Como engenheiro de software, quero que as dependências Python não interfiram no sistema global (PEP 668).
- **Consistência**: Quero que o bridge (`spec-bridge.js`) seja gerado de forma idêntica em ambos os sistemas.

### Regras de Negócio (The Truth)
1. **Segurança de Dados**: O script de limpeza (`test-cleanup-deps.sh`) NUNCA deve remover o Python 3 base do sistema Linux.
2. **Auto-Correção**: O instalador deve detectar se o `python3-venv` está incompleto (falta `ensurepip`) e tentar corrigir via `apt`.
3. **Imutabilidade do Bridge**: Versões geradas do `bin/spec-bridge.js` devem encapsular toda a lógica de MCP e CLI sem dependências de node_modules externos (além das ferramentas buildadas).
- .md (1 files)
- .js (1 files)

## Entry Points
- [`bin/spec-bridge.js`](bin/spec-bridge.js)

## Key Exports
- *No major exports detected.*

## File Structure & Code Organization
- `bin/` — TODO: Describe the purpose of this directory.
- `docs/` — Living documentation produced by this tool.
- `README.md/` — TODO: Describe the purpose of this directory.
- `setup-spec-bridge.bat/` — TODO: Describe the purpose of this directory.
- `setup-spec-bridge.sh/` — TODO: Describe the purpose of this directory.
- `test-cleanup-deps.sh...

---
## 📋 Checklist de Engenharia
- [ ] Validado contexto local
- [ ] Revisado arquitetura
- [ ] Alinhado com requisitos de negócio