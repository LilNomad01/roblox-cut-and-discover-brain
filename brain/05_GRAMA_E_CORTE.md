# Vegetação e sistema de corte

## Duas necessidades diferentes, um sistema de regras

1. **Lote/jardim da vila:** 64 unidades visuais ou células lógicas por serviço nas screenshots; gameplay econômico confiável e repetível.
2. **Floresta pública:** massas volumosas de matagal alto que ocultam trilhas, baús e pistas; pode usar outros visuais/densidades, mas **reutiliza a mesma validação de corte e recompensa**.
3. **Área de Teste:** o usuário **gostou muito** daquele mato alto, com folhas compridas e espigas. É a referência visual preferida da floresta, não uma graminha curta genérica.

## Estados visualmente indispensáveis

- `TALL` / `ALTO`: 5–8 studs, ocasionais 9–10 para esconder descoberta. Folhas altas, densas, coloridas, com sementes. Não usar colisão folha a folha.
- `SHORT` / `BAIXO`: 0,9–1,8 studs; primeira passada, cenário revelado.
- `STUBBLE` / `RASTEIRO`: 0,15–0,45 studs; acabamento da limpeza.

Variações: `Grass_A01...A06`, `Grass_B01...B04`, LODs e debris. Nomear e mapear coerentemente os três estágios de cada família, sem troca de modelo de outro tamanho.

## Geometria orgânica do corte

**Problema a evitar:** remover um tile quadrado inteiro ao encostar na grama. A área cortada deve ser o **volume varrido pela lâmina**.

- Unha: região pequena e baixa; requer vários movimentos.
- Enxada: faixa frontal descendente, recorte curto.
- Foice: varredura lateral de arco, com pontos de amostragem ao longo da animação.
- Carrinho motorizado/manual: tira contínua no solo, calculada entre posições anteriores e atuais da lâmina e largura física real.
- Trator: cobertura maior, controle como veículo se for ride-on.

Implementação pode usar células invisíveis/índice espacial, mas sem borda visual retangular: clumps sobrepostos, variantes, bordas irregulares, estágios por microclump; minimizar instâncias por lote e região.

## Segurança de gameplay

- Cliente pede **ação**; servidor valida ferramenta, propriedade, área atingida, cooldown, velocidade plausível, terreno elegível e estado da grama.
- `TALL→SHORT` é corte primário; `SHORT→STUBBLE` é acabamento. Crédito de XP/grama segue `Rewards` e habilidades ativas, com idempotência por célula/serviço/owner.
- Não conceder XP por frame, por folha, por tentativa sem mudança nem pelo mesmo tufo já cortado.
- Respeitar saco, XP, combos e evolução sem duplicidade.
- Forest multiplayer: decidir se matagal compartilhado entre todos ou progresso individual/instanciado. Documentar regra por setor.

## Distribuição

**Vila:** bordas livres dos lotes, manchas entre áreas verdes; sem cobrir ruas, spawn, caçambas, entrada da loja ou controles. **Floresta:** manchas densas com vazios intencionais, trilhas curvas, microclareiras e curvas de visão. Nunca espalhar exatamente igual no chão inteiro.

## Performance

- Preferir MeshParts baixos poly e poucos materiais, instanciados por região; colisão simplificada apenas para troncos/obstáculos.
- **Streaming/LOD por proximidade**, distância de render e pooling para efeitos; limitar duplicação de clones.
- Medir FPS, draw calls e instâncias no mobile. Evitar loop Heartbeat individual para cada tufo.
- Cliente visual pode interpolar transição, mas servidor controla corte e recompensa.

## Estado conhecido

- ZIP GrassPack contém modelos `.glb`, `.blend`, LODs e documentação; usuário reportou antes **54 de 70 GLBs importados**, dado histórico a verificar na versão principal.
- V9 inspecionada tem pasta `GrassPack` e muitos objetos `Grass_*`; isso **não prova** uso correto no mapa atual.
- O usuário aprovou visual da grama da Área de Teste; a qualidade/distribuição na floresta ainda não foi aprovada.
