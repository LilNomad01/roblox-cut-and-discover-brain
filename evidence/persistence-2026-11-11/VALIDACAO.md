# Validação — persistência (P0-07)

**Data:** 2026-11-11 · **IA:** Claude · Play solo no PC, no Studio, DataStore `CorteEDescubra_v1_Studio`.

| Verificação | Resultado |
|---|---|
| Studio **sem** acesso às APIs | O jogador entra com perfil temporário; aviso no console; ninguém é expulso |
| Primeira entrada (com acesso) | Perfil real criado do zero (`PerfilTemporario` ausente) |
| Valores colocados | 1.248 moedas, XP 40, saco 17 e o segredo `entrada_bau` coletado pela tecla E (+14 moedas, valor de sempre) |
| Salvamento automático (45 s) | Leitura direta do DataStore: Moedas 1248, XP 40, Saco 17, `claimed=[entrada_bau]`, sessão travada para este servidor |
| Primeira parada (**antes** da correção) | Ao entrar de novo voltou com 1.248, o valor do salvamento automático: o salvamento final se perdeu (**bug do `BindToClose`**) |
| Entrar de novo | Moedas 1248, XP 40, saco 17/50, `ForestClaimedSecrets=entrada_bau`, `ForestSecrets=1`; o feixe desse baú **não** reapareceu |
| Parada **depois** da correção | Coloquei 1.348 moedas e saco 23 e parei; a sessão seguinte carregou **1.348**: o salvamento final no fechamento funcionou |
| Saída do jogador com o servidor de pé (expulsão) | Gravado 1.425 moedas e saco 29, sessão **liberada** |
| Console | sem erros |
| Fonte | `Profiles` 5536/793837062, igual no Studio e no repositório |

## Observações

- **Leitura antiga do DataStore:** o `GetAsync` guarda uma cópia por alguns segundos. Uma leitura feita logo depois de parar mostrou o valor velho e a sessão "travada", mas a sessão seguinte provou que a gravação tinha acontecido.
- **Atalho de teste:** moedas e saco foram alterados direto nos atributos do jogador, que são a mesma fonte que o salvamento lê. O segredo foi coletado pelo caminho real.

## Não testado

- **Servidor publicado** (store `CorteEDescubra_v1`) e troca real entre dois servidores. A espera pela trava foi verificada só pela leitura do código.
- Mochila, equipamentos, habilidades e itens da floresta depois de reentrar (o código é o do Codex; neste teste só a mochila nível 0).
- Queda de servidor sem `BindToClose` (o perfil fica travado até 180 s).
- Celular e vários jogadores.
