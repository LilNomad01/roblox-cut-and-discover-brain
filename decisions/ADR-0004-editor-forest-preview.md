# ADR-0004 — Prévia estática da floresta no editor

- Data: 2026-11-10
- Estado: implementado e validado na transição Edit/Play/Edit
- Base: `8a6f71c`

## Contexto

A floresta era criada exclusivamente em Play. O usuário precisa enxergá-la no editor. Materializar a prévia como floresta funcional existente impediria a inicialização dos registros de corte, segredos e comércio do gerador atual.

## Decisão

Guardar uma prévia identificada fora de GameWorld, reutilizando os builders e assets existentes. Ela contém cenário estático e a cobertura distante de grama, sem serviços de jogadores ou interações ativas. Remover somente essa prévia no início de GameServer, antes de gerar a floresta funcional.

Preparar o terreno também em Edit, preservando TerrainRegion e pivôs originais para restauração. Adaptar a exploração para trabalhar com o root recebido, sem caminho fixo para a floresta de Play.

## Consequências

A floresta fica visível no editor e não duplica durante Play. A prévia é salva no place. Edições visuais nela não alteram o gerador: alterações permanentes continuam no código de cenário. A geração da prévia deve ser repetida após mudanças nos builders; o instalador recusa substituir módulo já existente sem inspeção.
