#!/bin/bash
cd "$(dirname "$0")"

# Carregar variáveis de um ficheiro externo (mais seguro que inline com $)
if [ -f /home/master/.cockpit-env.sh ]; then
  source /home/master/.cockpit-env.sh
fi

node ./server/server.js
