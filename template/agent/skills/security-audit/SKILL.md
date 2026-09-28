---
name: security-audit
description: Auditoria de segurança do código e dependências (segredos, validação de entrada, autenticação/autorização, OWASP Top 10). Use em mudanças de auth, dados de usuário, APIs públicas, upload, pagamentos ou quando solicitado.
---

# 🔐 Auditoria de Segurança

<execution_steps>
1. Defina o escopo (diff, módulo ou repositório) e a superfície de ataque (entradas externas, endpoints, uploads, integrações).
2. **Segredos:** procure chaves, tokens, senhas, connection strings no código, histórico recente, configs e exemplos (`git grep -nEi "(secret|token|passw|api[_-]?key|BEGIN .*PRIVATE)"`). Segredos devem vir de variáveis de ambiente/cofre.
3. **Entrada:** validação/sanitização no servidor, consultas parametrizadas (SQL/NoSQL injection), escape de saída (XSS), proteção de path traversal, SSRF, desserialização insegura, upload (tipo/tamanho).
4. **Autenticação/Autorização:** verificação em TODA rota sensível, checagem de propriedade do recurso (IDOR), expiração/rotação de tokens, hash de senha adequado, CSRF/CORS/cookies (`HttpOnly`, `Secure`, `SameSite`).
5. **Dados:** criptografia em trânsito/repouso quando aplicável, minimização de dados pessoais, logs sem dados sensíveis, mensagens de erro sem vazamento de detalhes internos.
6. **Dependências:** rode o auditor do ecossistema, se disponível (`npm audit`, `pip-audit`, `cargo audit`, `govulncheck`, etc.) e reporte CVEs relevantes.
7. **Configuração:** debug desligado em produção, headers de segurança, permissões mínimas, Docker sem root.
8. Relatório: severidade (Crítica/Alta/Média/Baixa), local `arquivo:linha`, exploração possível, correção recomendada. Corrija só o que estiver em escopo; proponha o resto.
</execution_steps>

<anti_patterns>
- NUNCA imprimir ou registrar segredos encontrados; mascare-os no relatório.
- NUNCA executar testes de invasão contra sistemas de terceiros ou de produção.
</anti_patterns>
