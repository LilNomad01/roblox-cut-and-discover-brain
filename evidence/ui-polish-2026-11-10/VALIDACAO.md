# Validação — polimento da UI

**Data:** 2026-11-10 · **IA:** Claude · Play solo no Studio, tela de 1274×461 (layout compacto do menu). PC, teclado.

| Verificação | Antes | Depois |
|---|---|---|
| Abrir menu (M), primeira vez | ~5 s com tela vazia (HUD já oculto) | menu visível em < 0,6 s (`depois-menu-perfil.jpg`) |
| Indicador da aba | 1 aba acima | alinhado com Perfil e Habilidades |
| Card da missão com menu aberto | visível atrás do painel | oculto |
| Folga card × moedas | encostado | 11 px (medido por `AbsolutePosition`) |
| Barra de progresso | 5 px, quase invisível | 10 px com degradê (`depois-hud.jpg`, 8/64) |
| Perfil, segredos | 0/3 (nós da árvore) | 0/18 (segredos da floresta) |
| Pílula PH × "CENTRALIZAR" | sobrepostas | lado a lado (`depois-arvore-v1.jpg`) |
| Nomes dos nós | ~5 px | legíveis (escala do canvas 0,36) |
| Sobreposições na árvore (verificação por retângulo de texto) | categoria × nome na fileira de baixo | **0** categoria × nome, **0** nome × nome |
| Rank "SEGREDO" | truncado | 0 rótulos truncados (`TextFits`) |
| Console | — | sem erros |

`depois-arvore-v1.jpg` é anterior à mudança dos rótulos de categoria. Depois dela, a captura de tela do Studio passou a dar timeout; a verificação final foi numérica (retângulos de texto e `TextFits`).

## Não testado

- Layout largo (tela ≥ 940×560): o Studio do teste só mostrou o layout compacto. O código do layout largo usa as mesmas funções.
- Celular real, controle e animações de pulso/"pop" observadas em vídeo.

Hashes (Studio): `QuestPanel` `10068/221550108` (igual ao arquivo do repositório), `PlayerMenuController` `19704/603937186`, `SkillsPanel` `7588/411952458`, `SkillsTreeNodeComponent` `9747/31318984`, `SkillsTreeRenderer` `12680/285842904`, `PlayerProfilePanel` `7953/180097622`.
