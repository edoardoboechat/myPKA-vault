# Procedimento: Git Push no Servidor Metris (Evitar Erros de Deploy Key)

## Contexto e Causa Raiz
No servidor Metris, o utilizador sem `sudo` (`openclaw` / utilizador padrão de sessão) possui a chave SSH configurada com a conta pessoal do GitHub (`edoardoboechat`), detendo permissões totais de **escrita**. 
Por outro lado, o utilizador `root` (`sudo`) utiliza uma chave SSH alternativa que está registada no GitHub estritamente como uma **Deploy Key** (permissão restrita a **leitura**).

## Regra Inquebrável de Git Push no Metris
1. **Nunca utilize `sudo` para comandos `git push`** no servidor Metris.
2. O uso de `sudo` força a troca para o contexto do utilizador `root`, resultando no erro: 
   `ERROR: Permission to ...-hub.git denied to deploy key`.
3. Sempre execute o `git push` utilizando diretamente os privilégios do utilizador corrente (sem `sudo`).

## Exemplo Correto
```bash
git -C /root/workspace push origin main
```
*(Executado sem o prefixo `sudo`, mesmo que o diretório pertença ou exija permissões de leitura mútua).*
