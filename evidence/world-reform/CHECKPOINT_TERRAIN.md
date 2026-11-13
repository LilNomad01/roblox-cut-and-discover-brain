# Checkpoint de terreno — 2026-11-12

Place: `106412085364108`. Base documental: `bd17159`. A V19 é uma versão salva, não prova de publicação. O arquivo atual contém melhorias posteriores do Claude em missões, relíquias, ferramentas e apresentação de NPCs; foram preservadas.

## Diagnóstico e correção

- O lobby tinha Terrain em aproximadamente -2 studs sob pavimento em +0,22. A base agora está em 0, alinhada ao sistema existente.
- A preservação de retângulos antigos junto a regiões limpas deixava faixas estreitas de morro e bordas verticais. O relevo passou a usar um único campo contínuo de alturas, com proteção orgânica das áreas funcionais.
- A base fina apresentava frestas de renderização a distância. A espessura mínima foi aumentada para 64 studs; a comparação da mesma câmera em `polido-encosta.png` e `consolidado-encosta.png` mostra a correção.
- Materiais nas encostas deixaram de seguir camadas horizontais repetidas.
- A vegetação distante deixou de usar quatro offsets fixos em grade. Cliente, servidor e prévia usam a mesma função pura de distribuição.
- Chão de apoio da Fazenda preservado em 2,8 studs. Pad verde do spawn foi ocultado sem deslocar o SpawnLocation.

## Verificado

- 361 raios verticais ao redor do lobby: todos atingiram solo. Amostras centrais e sob lotes estão em 0.
- Posições dos quatro `Base` e `PlayerSpawn` conferidas, sem deslocamento.
- Build da prévia repetido sem duplicação.
- Compilação Luau das fontes modificadas.
- Iluminação global e sombras restauradas após diagnóstico; nenhum marcador temporário permanece.

## Não aprovado por inferência

- As 44 verificações da caverna e a abertura do baú por E ocorreram numa iteração anterior. Não equivalem a uma regressão completa da versão atual.
- A tentativa de multiplayer foi encerrada sem resultado aprovado. O usuário assumiu esse teste; os harnesses foram removidos.
- Mobile, persistência entre sessões, desempenho em aparelho e reforma final do lobby permanecem pendentes.
- Nesta etapa ainda não foi salvo/publicado um novo número de versão pelo agente.

Referência técnica: [Roblox — materiais de Terrain, limitações de terreno fino](https://create.roblox.com/docs/parts/custom-terrain-materials). A correção foi verificada por captura real da mesma região, não apenas inferida da documentação.
