#!/usr/bin/env bash
set -e  # Para em caso de erro crítico

for cmd in "$@"; do
    [[ -z "$cmd" ]] && continue
    
    # Extrai apenas o comando base (sem argumentos)
    cmd_base="${cmd%% *}"
    
    # Verifica se o comando existe de forma mais segura
    if command -v "$cmd_base" >/dev/null 2>&1; then
        echo "Executando: $cmd"
        
        # Executa o comando completo com argumentos
        eval exec "$cmd" &
        
        # Encerra o script após sucesso
        exit 0
    fi
done

# Se nenhum comando for válido
echo "Erro: Nenhum comando válido encontrado" >&2
exit 1
