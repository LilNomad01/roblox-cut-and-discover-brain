# Plano de implementação — Issue #6

Base documental: `0fe1289`. Base inspecionada no Studio: place `106412085364108`, universe `10775723165`, em Edit. A identificação como build oficial permanece não confirmada; nenhuma cópia V1–V9 será carregada sobre o Studio.

Escopo: comerciantes Guto/Lia/Teca/Nilo, mochilas integradas ao saco existente, três pontos de venda, equipamentos funcionais de exploração, coleta e contratos individuais. Preservar o conteúdo anterior, os quatro lotes, a loja principal, habilidades e corte.

Etapas verificáveis:

1. Auditoria dos scripts ativos e cópia das fontes antes de alterações.
2. Catálogo, estado individual validado, recálculo de capacidade e transação de venda existente.
3. Cenário dos comerciantes, coleta, equipamentos e contratos; integração com o gnomo existente.
4. Interface cartoon exclusiva, feedback e entradas PC/toque/controle.
5. Compilação, testes determinísticos de invariantes, execução em Studio quando autorizada a base, e registro dos testes pendentes.

Dados: manter `schemaVersion=2` e `PersistenceEnabled=false`. Adicionar extensão opcional `ForestEconomy`, com defaults para perfis legados e validação estrita quando presente. Nenhuma gravação de banco ou migração de dados armazenados será executada. A ativação futura do save exige autorização, backup dos perfis, teste isolado de migração e reconexão. Rollback: restaurar as fontes copiadas e remover os novos módulos; perfis sem a extensão continuam aceitos. Nunca apagar moeda, equipamentos ou `SkillData`.

Git: branch `ai/forest-economy`; commits por etapa e push no repositório indicado pelo usuário. Nenhuma publicação do jogo autorizada.
