# Roadmap — fatias pequenas, entregas verificáveis

Esta sequência incorpora prioridades do usuário até 2026-11-09. Ajustar ao estado da baseline escolhida.

## P0 — Estabilizar a baseline (obrigatório antes de expandir)

- Identificar versão principal do Claude/Studio e comparar V9; backup e branch.
- Conferir game init e `PersistenceEnabled`; separar scripts ativos de backups.
- Testar carrinho presente, saco normal, hitbox de lâmina, foice/enxada/unha, troca, respawn.
- Testar baús e prompts em PC/touch e lucro não duplicado.
- Testar UI sem sobreposições com hotbar menor.

**Entrega P0:** baseline testada 15–20 min com checklist + logs e ao menos um vídeo de foice/carrinho.

## P1 — Floresta Esquecida (maior desejo atual)

1. Criar blocagem por setores e trilhas sinuosas (não mover vila).
2. Kit modular de árvores orgânicas: ~8–12 variações e sub-bosque.
3. Substituir distribuição regular de pinheiros e corrigir terreno/visibilidade.
4. Usar mato alto da Área de Teste com sistema de corte/recompensa existente.
5. Cabana real do Blender como hero asset e primeiro segredo revelável.
6. Riacho/ponte com geometria correta e rota visível.
7. 3 segredos **funcionais**, mais 3–7 como extensão posterior; teste de baú no matagal.
8. Transição local suave de luz/áudio da vila para floresta; testes mobile.

**Entrega P1:** uma área jogável de floresta de 5–10 min com início, meio e recompensa, aprovada por screenshot/vídeo do usuário. Só então expandir.

## P2 — Progressão de descoberta

- NPC Zeca e primeira missão; 3 itens escondidos, descoberta da cabana.
- Feedback de restauração antes/depois com itens de inventário.
- Mapa de exploração na aba, descobertas persistentes, marcadores sem spoilers.
- Conectar Cartógrafo/Detector à floresta após implementação real e testes.

## P3 — Economia / loja / habilidades em produção

- Telemetria de XP/min, moeda/min, recompensas e ritmo por ferramenta.
- Ativar save com migração e rollback/teste com múltiplas sessões.
- Garantir compra apenas de habilidades com mecânica real. Implementar previstos por ciclos.
- Loja: catálogo e visuais 3D coerentes, raridades das ferramentas manuais, não multiplicadores vazios.
- Baús: loot tables, rarity/roll e proteções anti-farm.

## P4 — Mundo futuro

- Fazenda Abandonada e Rodas Off-Road.
- Parque do Lago.
- Ruínas Antigas / padrões cortados / Mistérios.
- Contratos cooperativos / decoração e oficina.

## Risco de cronograma

É melhor concluir **uma floresta pequena porém densa e com 3 descobertas reais** do que uma floresta enorme com centenas de árvores iguais, sem narrativa nem performance. Trabalhar em fatias verticais: arte + gameplay + UI + reward + teste.
