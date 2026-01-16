#!/bin/bash

# Cores para o output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${RED}===========================================${NC}"
echo -e "${RED}===      CLEANUP TEST ENVIRONMENT       ===${NC}"
echo -e "${RED}===========================================${NC}"
echo -e "${YELLOW}[!] AVISO: Este script removerá Node.js, NPM e Pip3.${NC}"
echo -e "${YELLOW}[!] O Python3 BASE não será removido por segurança.${NC}"
echo -e ""

read -p "Você tem certeza que deseja prosseguir? (s/N): " confirm
if [[ $confirm != [sS] ]]; then
    echo -e "${BLUE}[*] Abortado.${NC}"
    exit 0
fi

# 1. Limpar arquivos do Spec-Bridge
echo -e "${GREEN}[1/3]${NC} Removendo binários e ferramentas locais..."
rm -rf .spec-bridge/tools
rm -rf .spec-bridge/venv
rm -f bin/spec-bridge.js
echo -e "   [✓] Limpeza local concluída."

# 2. Desinstalar Node.js e NPM
echo -e "${GREEN}[2/3]${NC} Verificando procedência do Node..."
NODE_PATH=$(which node)
if [[ "$NODE_PATH" == *".nvm"* ]]; then
    echo -e "${YELLOW}[!] Node detectado via NVM: $NODE_PATH${NC}"
    echo -e "O 'apt' não pode remover o NVM. Deseja ocultar temporariamente o NVM para testar o setup? (s/N)"
    read -p "> " hide_nvm
    if [[ $hide_nvm == [sS] ]]; then
        # Pega a pasta da versão atual (ex: .../v22.14.0/bin/node -> .../v22.14.0)
        VERSION_DIR=$(dirname $(dirname "$NODE_PATH"))
        mv "$VERSION_DIR" "${VERSION_DIR}_hidden"
        echo -e "   [✓] Pasta $VERSION_DIR renomeada para _hidden."
        echo -e "   [!] Nota: Para restaurar depois, renomeie de volta ou use 'nvm install'."
    fi
else
    echo -e "${BLUE}[*] Desinstalando Node/NPM via APT...${NC}"
    sudo apt-get remove --purge -y nodejs npm
fi
sudo apt-get autoremove -y

# 3. Desinstalar Pip3 e Venv (Mantenha o Python3 base!)
echo -e "${GREEN}[3/3]${NC} Desinstalando Python3-Pip e Venv..."
sudo apt-get remove --purge -y python3-pip python3-venv
sudo apt-get autoremove -y
echo -e "   [✓] Pip3 e Venv removidos."

echo -e ""
echo -e "${BLUE}===========================================${NC}"
echo -e "${GREEN}Ambiente resetado para teste de instalação!${NC}"
echo -e "Se você 'escondeu' o NVM, o setup agora deve tentar instalar via APT.${NC}"
echo -e "Execute: ${YELLOW}./setup-spec-bridge.sh${NC}"
echo -e "${BLUE}===========================================${NC}"
