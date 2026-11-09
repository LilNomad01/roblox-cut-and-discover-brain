# UI/UX e identidade visual

## Identidade aprovada

A UI pública da vila tem botões grandes coloridos, fundo com gradiente, contorno quase preto, sombra offset, cantos arredondados e fonte lúdica legível. Principais botões externos: **MENU verde/mint, LOJA amarelo, UPGRADES azul, PETS rosa, CONFIG cinza**. HUD de nível/XP, moedas, saco e meta do jardim.

A loja externa amarela é o **único fluxo principal de compra**. A aba **Equipamentos** do menu existe como inventário / consulta / equipar, não como segunda Loja concorrente. Upgrades não deve abrir falsamente a mesma Loja sem função distinta.

## Menu do Jogador — abas

1. **Perfil**: avatar, display, nível, XP, moedas, equipado, região, PH, segredos, tempo, grama.
2. **Habilidades**: árvore hexagonal funcional, seleção de nó, painel lateral, PH; integração com mapa.
3. **Equipamentos**: subcategorias Manuais, Cortadores, Especiais; lista owned + ação equipar, detalhes.
4. **Exploração**: mapa e progresso por região; cabana, ponte, floresta e futuros biomas.
5. **Missões**: ativas, disponíveis, concluídas, progresso individual.
6. **Configurações**: intensidade de câmera, vibração, som, qualidade simplificada, etc.

## Problemas visuais relatados

- No passado a barra de 4 ferramentas aparecia por cima da Loja e menu (corrigido em cópias, preservar).
- Menu/Config chegaram a mostrar abas vazias ou árvore inesperada; dependência entre controladores concorrentes.
- Perfil e Equipamentos/Habilidades ficaram visíveis simultaneamente: `Visible` e hierarquia de páginas conflitantes.
- Alguns modais cobriam HUD no topo com textos grandes.
- Barra de 4 ferramentas era **alta e invasiva**, principal pedido recente foi redução de ~20–30%; V9 tem ajuste de ~25% ainda não confirmado visualmente.
- Botão flutuante **NOVO SERVIÇO** era retângulo simples verde cobrindo personagem; pedido: **NPC jardineiro perto do lote**, diálogo/ProximityPrompt, balão mais bonito.
- Layout da árvore pode ficar excessivamente escuro/diminuto em telas grandes, e textos cortados no painel de detalhes.

## Componentes de qualidade

- `ScreenGui` separado para HUD, menus, lojas; **controlador de visibilidade único** e prioridade ZIndex planejada, sem 2 modais ativos ao mesmo tempo.
- Borda/contorno, cores e tipografia consistentes; estado *hover*, *pressed*, *disabled* e *selected* claros.
- Loja: grade responsiva com cards que não cortam texto/preço, scroll vertical independente, modal responsivo e `Close` sempre no safe area.
- Barra: slots 1–4, pequena, ícones bem centralizados e numeral com selo preto. Dimensões via `UIScale`/breakpoints; safe area mobile respeitada.
- Árvores: zoom e pan ancorados no centro, painel lateral fixo (PC) / inferior (mobile), texto com hierarquia/scroll; status bloqueado por requisito claro.
- Perfil: sem cartões vazios enormes; dados relevantes agrupados e botões que levam ao fluxo certo.
- Menus entram com 0,18–0,25 s `Quad/Cubic Out`; close com ~0,15 s; animações interrompíveis.

## Safe areas e acessibilidade

- Não cobrir controles de joystick/chat/CoreGui no mobile; usar `GuiService` safe insets/containers responsivos conforme APIs aplicáveis.
- Botões tocáveis >= ~44–48 px se viável, texto legível ao escalar; evitar elementos fixos em `Offset` gigantes em telefone.
- Contraste branco e contorno, label + ícone (não só cor), navegação por controle.
- Evitar desfoque global pesado, pós-processamento e transparências excessivas que reduzem FPS mobile.

## Princípio de compra

O modelo real da máquina exibida deve corresponder ao item comprado/equipado. Cards não devem anunciar modelos 3D exclusivos que não existem; pode haver fallback explícito **apenas para teste**, sinalizado no manifesto.
