# Balanceamento da progressão (nível e cortadores)

**Data:** 2026-11-11 · **IA:** Claude · **Place:** `106412085364108`

**Pedido do usuário:** "Balancear progressão". Depois, ele pediu para seguir sem pedir autorização, então **as metas abaixo foram escolhidas pelo Claude** e podem ser ajustadas.

**Backup:** `ServerStorage.BalanceamentoBackup_20261111.ConfigJogo`.

## Diagnóstico

Fontes de recompensa (lidas no código):

| Fonte | Moedas | XP |
|---|---|---|
| Cada tufo | 1 grama × multiplicador do cortador; venda a 2 por grama | **5, fixo** |
| Jardim completo (64 tufos) | +40 | +40 |
| Fechamento do jardim | +20 | +20 |
| Subir para o nível n | +25·n | — |
| Baú do lote | 10–15 | 15 |
| Segredos da floresta | 14–200 | 10–25 |

**A velocidade de corte não depende do cortador comprado.** Ela vem de `GameConfig.Levels` e das habilidades. O cortador só multiplica a grama e aumenta o saco. Então:
- **o XP por minuto é praticamente fixo**;
- **as moedas por minuto crescem com o multiplicador**.

Medido em Play: com o carrinho básico, cerca de 1,5–2 tufos por segundo cortando.

**Modelo:** jogador eficiente, só jardins no lote, sem floresta (`modelo_progressao.py`; as premissas estão no topo do arquivo).

| Momento | **Antes** | **Depois** |
|---|---:|---:|
| Nível 5 | 4 min | 6 min |
| Nível 10 | 18 min | 32 min |
| Nível 15 | 46 min | 1h20 |
| Nível 20 | 1h28 | 2h38 |
| Nível 25 | ~2h30 | 4h28 |
| Elétrico | 2 min | 5 min (nível 4) |
| Turbo | 9 min | 15 min (nível 7) |
| Mini Trator | 37 min | 46 min (nível 11) |
| Off-Road | 1h00 | 1h20 (nível 15) |
| Colheitadeira | 1h34 | 2h00 (nível 17) |
| Mega | 2h16 | 2h58 (nível 21) |
| Imperial GX | 3h19 | 4h30 (nível 25) |

Antes, o nível subia rápido demais (registrado no brain 03) e chegava ao fim muito antes do equipamento. Agora os dois andam juntos, e o último marco de PH (nível 26) fica perto do Imperial GX, onde a proposta "Fama de Jardineiro" (brain 19) entraria.

## O que mudou (`ReplicatedStorage.ConfigJogo`)

| Item | Antes | Depois |
|---|---:|---:|
| `XPParaNivel(n)` | `60·n^1,4` | `110·n^1,4` |
| Cortador Elétrico | 400 | 800 |
| Cortador Turbo | 2.500 | 3.200 |
| Mini Trator | 15.000 | 16.000 |
| Trator Off-Road | 32.000 | 47.000 |
| Colheitadeira | 65.000 | 75.000 |
| Mega Cortador | 100.000 | 140.000 |
| Imperial GX | 250.000 | 360.000 |

Não mudaram:
- multiplicadores e sacos;
- XP e moedas por tufo;
- prêmios de jardim, baú, segredo e nível;
- mochilas e lojas da floresta.

**Compatibilidade:** a curva nova nunca pede menos XP que a antiga, então nenhum perfil salvo fica inválido (a validação exige XP < XP do nível). Quem já tinha nível alto continua com ele.

## Validação (Play no Studio)

- O perfil salvo carregou com a curva nova: nível 2, XP 140/290 (antes, 140/158).
- A loja mostra os preços novos ("800" no Elétrico, "360K" no Imperial).
- Nenhum preço está escrito à mão fora do `ConfigJogo`.
- Console sem erros.

## Limitações e próximos ajustes

- **O modelo ignora a floresta**, onde cada tufo também dá grama e XP, além de segredos, mochilas e habilidades. Um jogador que explora sobe um pouco mais rápido; isso é desejável.
- As metas são do Claude, a partir das metas antigas do brain 03 (que não tinham sido medidas). Vale uma sessão real de 30–60 min com cronômetro para confirmar.
- Celular e jogadores menos eficientes vão mais devagar.
