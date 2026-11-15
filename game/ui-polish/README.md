# Polimento da UI — HUD da missão, menu e árvore de habilidades

**Data:** 2026-11-10 · **IA:** Claude · **Place:** `106412085364108` · **Pedido do usuário:** melhorar a UI (HUD da missão, menu, árvore), mantendo o estilo atual.

Backups de todos os scripts alterados: `ServerStorage.UIPolishBackup_20261110`. Para reverter, copie o `Source` de cada backup de volta para o script de mesmo nome.

## Problemas encontrados (auditoria em Play, tela 1274×461)

| Onde | Problema | Causa |
|---|---|---|
| Menu | Primeira abertura levava ~5 s: o HUD sumia e nada aparecia | `obterControles()` fazia `WaitForChild("PlayerModule", 5)`; esta place não tem `PlayerModule` em `PlayerScripts` |
| Menu | Indicador verde da aba ficava 1–2 abas acima da selecionada | Posição calculada relativa à `listaAbas`, mas o indicador é filho da `lateral` |
| Menu | Card da missão continuava visível atrás do menu | `ExplorationQuestHUD` não se escondia com menu/loja/árvore |
| Perfil | "Segredos revelados 0/3" | Contava os nós secretos da árvore, não os segredos do mundo (18 na floresta) |
| HUD | Card da missão encostado na pílula de moedas; barra de progresso de 5 px quase invisível | Posição fixa; `AbsolutePosition` desconta a barra do topo |
| Árvore | Pílula "0 PH DISPONÍVEIS" coberta pelo botão "CENTRALIZAR" | Botão em posição fixa (x=126), a pílula cresce com o texto |
| Árvore | Nomes dos nós com ~5 px na tela | Canvas reduzido por `UIScale` (0,36× em telas baixas) e fonte fixa de 15 |
| Árvore | "SEGREDO" cortado ("SECRE"/"SEGRED") | Caixa do rank com 44 px fixos |
| Árvore | Nomes da fileira de baixo sobre "EXPLORAÇÃO"/"RESTAURAÇÃO" | Rótulos de categoria no centro do setor |

## Mudanças (mesmo visual; nada redesenhado)

| Script | Mudança |
|---|---|
| `StarterPlayerScripts.QuestPanel` (cópia completa: `QuestPanel.luau`) | Card abaixo das moedas (+12 px, relativo ao próprio ScreenGui); barra de 10 px (8 px compacto) com trilho escuro e degradê verde; contador pulsa a cada avanço; "pop" ao trocar de missão; barra e contador dourados com ✓ ao concluir; card oculto com `MenuJogadorAberto`, `LojaAberta` ou `SkillTreeOpen`. |
| `PlayerMenu.PlayerMenuController` | `obterControles()` usa `FindFirstChild` (sem espera); indicador posicionado relativo à `lateral`, centrado no botão (2 ocorrências). |
| `PlayerMenu.PlayerProfilePanel` | Estatística "SEGREDOS DA FLORESTA" = `ForestSecrets` / `FlorestaEsquecida:GetAttribute("SecretsCount")`. |
| `PlayerMenu.SkillsPanel` | "CENTRALIZAR" acompanha a largura da pílula de PH; a legenda encolhe junto. |
| `PlayerMenu.SkillsTreeNodeComponent` | `Node:legivel(escala)`: nome com no mínimo ~11 px na tela (fonte 15–30 no canvas, caixa 180 de largura e 2,3 linhas); rank 72 px escalável. |
| `PlayerMenu.SkillsTreeRenderer` | `_aplicar` chama `legivel` em cada nó; rótulos de categoria de baixo vão para as laterais da última fileira. |

Os trechos exatos estão marcados no código com `[Claude 2026-11-10]`.
