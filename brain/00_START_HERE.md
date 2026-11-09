# START HERE — Contexto em 90 segundos

**Projeto:** Corte & Descubra / Cut & Discover, simulador de jardinagem com exploração no Roblox.  
**Tom:** leve, satisfatório, estilizado, colorido, com mistério aconchegante; priorizar mobile.  
**Diferencial:** cortar o matagal para revelar trilhas, baús, pistas, casas, ruínas e transformar ambientes.

## Loop

`Cortar no lote → ganhar grama/saco → vender → ganhar moedas e XP → comprar ferramenta → desbloquear habilidades → entrar na floresta → abrir trilhas e revelar objetos → missões e restauração → novas áreas`.

## Conhecido e observado

- Vila com **quatro jardins/lotes**, estradas e ponto de venda; loja amarela externa; menu do jogador com **Perfil, Habilidades, Equipamentos, Exploração, Missões e Configurações**.
- Arquivo local mais recente conhecido: **V9**, com **7.296 instâncias e 103 scripts/módulos** conforme leitura binária; há **backups dentro do `.rbxl`** que não devem ser tratados como scripts ativos.
- Existem assets de 5 máquinas, 3 tipos de ferramenta em 5 raridades, 5 baús e pacote 3D de grama; checar se estão importados/equipados corretamente.
- Barra de ferramentas: `1` unha, `2` enxada, `3` foice, `4` carrinho. `F` para golpe manual nos experimentos recentes.
- **O usuário não gostou da última aparência da floresta:** pinheiros triangulares repetidos, chão muito vazio entre tufos, trilhas pouco orgânicas, cabana distante. Reformulação artística é prioridade.
- **Persistência marcada desativada** em um `GameConfig` da V9. Não prometer salvamento.

## Não confundir

- **Decisão de design** ≠ feature existente.
- **Asset Blender/FBX/GLB existente** ≠ asset corretamente importado e montado no Studio.
- **Código inserido no `.rbxl`** ≠ funcionando no Play.
- **Screenshot do usuário** prova visual daquela sessão, não garante ausência de bugs após mudança.
- **V9 local** ≠ versão oficial publicada, a menos que o usuário confirme.

## Focos de trabalho mais urgentes

1. Confirmar baseline/código ativo, corrigir regressões: carrinho, foice, prompts dos baús, NPC.
2. Refazer a floresta **por design de nível e arte**, com árvores orgânicas, camadas de vegetação, trilhas sinuosas e segredos intencionais.
3. Unificar corte por lâmina (grana/recompensa) e mato TALL/SHORT/STUBBLE.
4. Refinar UI mantendo estilo do jogo; corrigir abas e sobreposições.
5. Colocar habilidades de verdade em produção apenas se testadas; auditar persistência e anti-exploit.

Leia `brain/02_ESTADO_REAL_E_VERSOES.md` para detalhes técnicos reais, `brain/06_MUNDO_FLORESTA_ESQUECIDA.md` para a floresta e `brain/15_SINCRONIZACAO_DAS_IAS.md` para colaborar.
