# 20 — Padrões dos jogos do mesmo estilo no Roblox (pesquisa)

**2026-11-11 · Claude · Estado: PESQUISA / PROPOSTA (nada implementado).** Pedido do usuário: "estude jogos no roblox desse estilo e busque padrões entre eles para ver o que falta e o que pode ser mudado".

**Fontes:** guias, wikis de fãs e análises (lista no fim). Os números de jogos de terceiros são **aproximados** e servem como direção, não como dado oficial.

**Regra do projeto:** estudar **padrões de design**, sem copiar nome, arte, personagens nem mapas de nenhum jogo.

## 1. Jogos estudados (e o que importa de cada um)

| Jogo (gênero) | Ciclo principal | O que é relevante para nós |
|---|---|---|
| Simuladores de cortar grama (Lawn Mowing Simulator, Mowing Masters, Mow Ur Lawn, Grass Incremental, +1 Cut Grass) | cortar → vender → cortador melhor | quase todos têm **renascimento**, **mundos novos liberados por requisito**, melhorias de "atributo" (largura da lâmina, velocidade de crescimento da grama) e **progresso offline** em alguns |
| Bee Swarm Simulator (coleta em campos) | coletar pólen no campo → converter na colmeia → missões → melhorar abelhas e ferramentas → abrir áreas mais altas | **o mais parecido com o nosso** (campos, saco que enche, voltar para "vender"). Força: **NPCs que dão missões variadas** com recompensas permanentes; **campos diferentes** exigidos pelas missões; **capacidade** como ritmo; conquistas de longo prazo |
| Treasure Hunt Simulator (cavar e achar baús) | cavar → mochila enche de areia → vender → pá e mochila melhores; baús escondidos no chão | **o mesmo "cortar e descobrir"**: o tesouro está debaixo do que se cava; locais de escavação cada vez melhores; renascimento que dá multiplicador; **códigos** |
| Grow a Garden (jardim, 2025) | plantar → colher → vender → sementes raras | **clima e eventos do servidor** (chuva acelera, tempestade dá "mutação" que multiplica o valor); **progresso offline** (cresce enquanto você está fora); **loja que reabastece** de tempos em tempos (motivo para voltar); **atualização toda semana** |
| Pet Simulator 99 (pets) | quebrar moedas → ovos → pets mais fortes | **ranks com missões** e recompensas por rank; **índice/coleção** de pets com prêmio; encantamentos; eventos constantes |

## 2. Padrões que aparecem em quase todos

1. **Ciclo curto + meta longa.** Um ciclo de 1–2 min (encher → vender → melhorar), ligado a metas que levam horas ou dias (mundos, renascimento, coleções, ranks).
2. **Capacidade como ritmo.** Saco, mochila ou colmeia enche e força a volta. **Já temos.**
3. **Missões variadas de NPCs**, com recompensas permanentes (não só moedas).
4. **Áreas novas liberadas por requisito** (nível, moedas, missão), cada uma com recurso mais valioso.
5. **Renascimento (rebirth):** zera a moeda em troca de multiplicador permanente, com custo crescente.
6. **Pets/ajudantes** com multiplicador, ovos com chances visíveis e índice de coleção.
7. **Recompensas de retorno:**
   - diária com sequência de dias;
   - por tempo jogado;
   - **progresso offline**.

   O Roblox tem um pacote oficial ("Engagement Rewards") para diária e tempo jogado.
8. **Eventos e clima no servidor:** algo raro acontece para todo mundo ao mesmo tempo (clima, chuva dourada, "hora do dobro"), com itens por tempo limitado.
9. **Variantes raras que empolgam** ("mutação", "shiny", "dourado"): o mesmo recurso, mas valendo muito mais.
10. **Códigos** (redes sociais/Discord) e **recompensa por entrar no grupo**: marketing barato.
11. **Rankings globais** (OrderedDataStore) e **badges** por marcos.
12. **Monetização típica:**
    - passe de ×2 dinheiro (o que mais vende nesses jogos);
    - vender de qualquer lugar;
    - coleta e venda automáticas;
    - mais vagas de pet;
    - VIP;
    - bônus para Roblox Premium.
13. **Ritmo de atualização:** atualização semanal (muitos jogos grandes publicam toda sexta) ou atualizações grandes e espaçadas, sempre com **evento ativo**. Segundo uma análise, simulador sem evento perde boa parte do pico em semanas.
14. **Social:** brincar com amigos (o algoritmo do Roblox passou a favorecer jogo com amigos em 2025), bônus de amigo no servidor e servidores VIP.

## 3. Comparação com o Corte & Descubra

| Padrão | Nós hoje | Situação |
|---|---|---|
| Ciclo curto (encher → vender → melhorar) | jardim de 64 tufos, saco, caçamba dourada, 8 cortadores | **Tem** (balanceado em 2026-11-11) |
| Capacidade | saco + mochilas da floresta | **Tem** |
| Pets com multiplicador e chances visíveis | Ajudantes do Jardim (10 espécies, 3 ninhos) | **Tem** (v1); falta índice com prêmio |
| Descoberta escondida no que se corta | baús no lote, 17 segredos na floresta, pistas de vaga-lume | **Tem**, e é o nosso diferencial |
| Árvore de habilidades | 19 nós (8 prontos) | **Parcial** |
| Salvamento | ligado e validado no Studio | **Tem** (falta servidor publicado) |
| Missões variadas de NPCs | só "corte o jardim" e as missões dos comerciantes | **Falta** (o Zeca estava planejado) |
| Áreas liberadas por requisito | vila + floresta (aberta) | **Falta** (fazenda, lago e ruínas no roadmap) |
| Renascimento | — | **Falta** ("Fama de Jardineiro" proposta no brain 19) |
| Diária, tempo jogado, offline | — | **Falta** |
| Clima e eventos do servidor | — | **Falta** |
| Variante rara do recurso | — | **Falta** (ver ideia "grama dourada") |
| Códigos e recompensa de grupo | — | **Falta** |
| Rankings e badges | só `leaderstats` (moedas, nível) | **Falta** |
| Gamepasses | nenhuma | **Falta** (proposta no brain 19) |
| Ritmo de atualização e evento ativo | — | **Falta** (processo, não código) |
| Brincar com amigos | 4 lotes por servidor, cada um sozinho | **Fraco** |

## 4. O que pode ser mudado no que já existe

1. **O jardim de 64 tufos que "acaba".** Nos jogos do gênero o campo **volta a crescer** sozinho. Hoje o jogador precisa ir ao jardineiro pedir outro serviço a cada 64 tufos, o que interrompe o fluxo. **Proposta:** a grama do lote cresce de volta aos poucos, e o "serviço" vira bônus quando o jardim é fechado inteiro (o que já existe). Mantém o NPC e tira a espera.
2. **A velocidade de corte não muda com o cortador.** Nos concorrentes, a ferramenta melhor corta **mais rápido ou mais largo**. Hoje só a grama por tufo aumenta, e a velocidade fica sempre igual. **Proposta:** dar largura ou cadência extras aos cortadores mais caros, o que dá sensação de poder. O modelo de `game/balance` precisaria ser recalibrado.
3. **Floresta toda aberta desde o início.** Os concorrentes liberam áreas aos poucos. **Não bloquear o iniciante** é regra do brain 06; um caminho é deixar a entrada livre e pôr **regiões mais fundas** (cripta, áreas atrás do riacho) atrás de missão ou nível.
4. **A recompensa por segredo é só moeda.** No Bee Swarm, missão e descoberta dão **bônus permanente**. **Proposta:** completar páginas do álbum (segredos, relíquias, pets) dá +% permanente pequeno.

## 5. O que falta — prioridade sugerida

Ordem pensada por **impacto × esforço**, encaixando com a ordem do brain 19:

| # | Item | Por quê | Esforço |
|---|---|---|---|
| 1 | **Diária com sequência + recompensa por tempo jogado** | Traz o jogador de volta (conta para o Creator Rewards); pacote oficial do Roblox existe | baixo |
| 2 | **Grama dourada (variante rara)** | Empolgação a cada corte: ~1% dos tufos vale ×10, com brilho e som; combina com "cortar e descobrir" | baixo |
| 3 | **Códigos + bônus de grupo** | Marketing barato; atrai jogadores de redes sociais | baixo |
| 4 | **Grama do lote volta a crescer + progresso offline** ("seu jardim cresceu enquanto você estava fora") | Remove o atrito do "novo serviço"; motivo para voltar | médio |
| 5 | **Missões variadas** (quadro do jardineiro: "corte 200 na floresta", "ache 2 segredos", "venda 500 de grama"), com recompensas permanentes | Dá direção e metas de médio prazo; é o maior padrão que falta | médio |
| 6 | **Clima/evento do servidor** (ex.: chuva → grama cresce mais rápido e mais grama dourada; "hora do dobro" de 10 min) | Momentos compartilhados e motivo para ficar online | médio |
| 7 | **Rankings globais + badges** (grama total, segredos, pets mitológicos) | Competição e metas visíveis | baixo–médio |
| 8 | **Gamepasses** (×2 grama, vender de qualquer lugar, +2 vagas de pet, VIP visual) | Receita; já proposto no brain 19 | médio |
| 9 | **Fama (renascimento)** e **regiões novas** | Meta longa | alto |
| 10 | **Jogo com amigos:** bônus quando um amigo está no servidor; ajudar a cortar o jardim do amigo | O algoritmo favorece jogo com amigos | médio |

**Processo, não código:** combinar um **ritmo fixo de atualização** (ex.: algo novo toda sexta, mesmo que pequeno) e manter **sempre um evento ativo**.

## 6. Cuidados

- **Itens aleatórios pagos:** valem as regras do brain 19. Hoje os ninhos usam só moedas ganhas.
- **Progresso offline com teto** (ex.: até 8 h), para quem volta não pular o jogo inteiro.
- **Eventos sem pressão falsa:** prazos reais, sem "só hoje" enganoso (orientação do Roblox).
- **Não copiar jogos:** só os padrões; arte, nomes e mapas continuam originais.

## Fontes

- Simuladores de grama: [Grass Incremental (guia)](https://deltiasgaming.com/?p=358413), [Mow Ur Lawn (guia)](https://www.sportskeeda.com/roblox-news/mow-ur-lawn-a-beginner-s-guide), [Mowing Masters Simulator](https://www.roblox.com/games/5991118999/Mowing-Masters-Simulator), [+1 Cut Grass Adventure](https://bloxodes.com/articles/plus-1-cut-grass-adventure-beginner-guide), [Garden Cleaner Evolution](https://allthings.how/garden-cleaner-evolution-progression-guide-upgrades-and-rebirths/), [Lawn Mowing Simulator (wiki)](https://namu.moe/w/Lawn%20Mowing%20Simulator)
- Bee Swarm Simulator: [Sportskeeda — como jogar](https://sportskeeda.com/roblox-news/roblox-bee-swarm-simulator-how-play-bees-bears), [TechWiser — mecânicas](https://techwiser.com/bee-swarm-simulator-player-mechanics-guide/), [Switchblade — guia](https://www.switchbladegaming.com/roblox/bee-swarm-simulator-guide/)
- Treasure Hunt Simulator: [Wikibooks](https://en.wikibooks.org/wiki/Roblox_Studio_Tutorials/Treasure_Hunt_Simulator), [THS2 — log de atualização](https://devforum.roblox.com/t/2050916), [Destructoid — códigos](https://www.destructoid.com/treasure-hunt-simulator-codes/)
- Grow a Garden: [Sportskeeda — por que é popular](https://www.sportskeeda.com/roblox-news/why-grow-garden-popular), [Gamertweak](https://gamertweak.com/why-is-grow-a-garden-so-popular-on-roblox/), [Deltia's — clima](https://deltiasgaming.com/?p=203882), [Noping — guia](https://noping.com/blog/grow-a-garden-gameplay-guide)
- Pet Simulator 99: [Ranks (wiki)](https://pet-simulator.fandom.com/wiki/Ranks_(Pet_Simulator_99)), [Update 5](https://progameguides.com/roblox/pet-simulator-99-patch-notes-update-5/)
- Retenção e eventos: [GameAnalytics — 2025 Roblox Report](https://www.gameanalytics.com/cn/reports/2025-roblox-report), [RoWatcher — top 100](https://rowatcher.com/news/what-every-top-100-roblox-game-gets-right-a-design-analysis), [RoWatcher — vida útil dos hits](https://rowatcher.com/news/the-lifespan-of-a-hit-why-90-of-roblox-s-top-100-games-fade-within-a-year), [RoWatcher — mecânicas AFK](https://rowatcher.com/news/the-afk-revolution-how-idle-mechanics-conquered-roblox)
- Oficial Roblox: [Engagement Rewards (pacote)](https://create.roblox.com/docs/resources/feature-packages/engagement-rewards)
- Idle e monetização: [creation.dev — renda passiva](https://www.creation.dev/learn/roblox-passive-income-guide), [creation.dev — mecânicas idle](https://www.creation.dev/glossary/idle-mechanics)
