# ADR-0005 — Arte do lobby separada dos sistemas funcionais

Data: 2026-11-12. Estado: aplicado, validação final pendente.

## Contexto

A reforma visual precisa aparecer no editor e no jogo, preservando quatro jardins, NPCs, vendas, missões e spawns existentes. A cópia atual contém trabalho recente de outras IAs.

## Decisão

Manter a decoração em um builder nativo idempotente, `LobbyGardenArt`, com raiz própria `GameWorld.LobbyGardenReform`. Reutilizar quadros funcionais por referência, preservando nomes, GUIs e prompts. Pintar trilhas sobre Terrain existente em vez de usar lajes em uma cota fixa. Separar a animação ambiental local do moinho em um único LocalScript.

## Consequências

Atualizações de arte não exigem recriar lotes ou sistemas. Props rurais novos são decorativos, sem anunciar mecânicas inexistentes. O backup inclui modelos anteriores, propriedades e pivôs. O custo visual deve ser medido em aparelho móvel; não se presume desempenho aprovado. O fechamento do Studio impediu confirmar novo save e concluir os testes deste checkpoint.
