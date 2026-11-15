# 19 — Pets, gamepasses e gameplay evolutiva (pesquisa e proposta)

**2026-11-11 · Claude · Estado: PLANEJADO (nada implementado).** Pedido do usuário: "pesquise sobre pets, gamepass e gameplay evolutiva e veja o que podemos fazer".

Este documento junta três coisas:
1. o que o jogo já tem (auditoria no Studio, place `106412085364108`);
2. as regras do Roblox que valem para o tema (fontes no fim);
3. uma proposta em ordem de execução.

**Nenhum valor, preço ou chance aqui está aprovado.** Todos são pontos de partida para o usuário decidir.

## 1. O que existe hoje

| Área | Estado real |
|---|---|
| Monetização | **Nenhuma.** Não há `MarketplaceService`, gamepass nem developer product em script nenhum. |
| Pets | O botão **PETS** do HUD abre "em breve" (`InterfaceHUD`). Não existe sistema de pets. |
| Persistência | `PersistenceEnabled=false`. Moedas, cortadores, mochilas e segredos **não salvam** entre sessões. |
| Progressão | Nível/XP (sobe rápido demais, segundo o brain 03); 8 cortadores (Básico → Imperial GX); ferramentas manuais com 5 raridades (sem compra/evolução); árvore com 19 nós (8 prontos); mochilas do Guto; 17 segredos da floresta; PH. |
| Multiplicador | Já existe o atributo `Multiplicador` (`Economia`, `ConfigJogo`, menus). Pode receber bônus de pets e passes sem criar outro sistema. |
| Raridades | Escada aprovada para baús: Comum 60 / Incomum 25 / Raro 10 / Lendário 4 / Mitológico 1 (condicional, brain 09). Serve de base para os pets. |

**Bloqueio principal:** sem salvar dados, não dá para vender nada nem dar pets.
- Um pet perdido ao sair do jogo é uma frustração grave.
- Uma compra perdida gera reclamação e reembolso.
- `ProcessReceipt` exige gravar a entrega antes de confirmar.

Por isso o **P0-07 (persistência)** vem antes de qualquer item deste documento.

## 2. Regras do Roblox que mudam o desenho

1. **Itens aleatórios pagos (ovos, baús, roletas).** Valem quando o item é comprado com Robux ou **com moeda do jogo que pode ser comprada com Robux**. Nesse caso é obrigatório:
   - mostrar **todos os resultados e as chances numéricas** antes da compra (porcentagens que somam 100%; o detalhe pode ficar num botão escrito "Detalhes" ou "Info", não só num ícone);
   - explicar numericamente qualquer bônus de sorte e atualizá-lo enquanto estiver ativo;
   - checar `PolicyService:GetPolicyInfoForPlayerAsync()` → `ArePaidRandomItemsRestricted`, e dar outra via aos usuários bloqueados (caminho grátis, compra direta pelo valor esperado, ou esconder o item).

   Jogos que declaram ter esses itens e não usam a API ficam indisponíveis para menores de 18 anos no Reino Unido. Recompensas aleatórias ganhas **só jogando**, sem Robux nem moeda comprável, **não** exigem divulgar chances.
2. **Troca de itens.** O resultado de item pago não pode ser trocado por usuários sem permissão (`IsPaidItemTradingAllowed`). Para simplificar, a versão 1 fica **sem troca**.
3. **Developer products (compras avulsas).**
   - `ProcessReceipt` fica num único script de servidor.
   - O handler valida o recibo, entrega o item, **grava** a entrega e só então devolve `PurchaseGranted`.
   - Se não conseguir gravar, devolve `NotProcessedYet`, e o Roblox tenta de novo.
   - O Roblox não guarda o histórico de compras por jogador; isso é responsabilidade nossa (DataStore).
4. **Gamepasses.** São compras únicas e permanentes, verificadas com `MarketplaceService:UserOwnsGamePassAsync`. Não precisam de recibo nem de salvamento próprio.
5. **Sem pressão falsa.** O Roblox orienta a não dizer que um item está acabando ou é por tempo limitado quando não é.
6. **Preços.**
   - "Managed Pricing" junta preço regional e otimização de preço (otimização só a partir de 60 mil transações/mês).
   - Para funcionar, o preço **não pode estar fixo no código**: a UI deve ler o preço com `GetProductInfo`.
   - O desenvolvedor define só o preço base.
7. **Receita por engajamento (Creator Rewards, desde jul/2025).** O Roblox paga pelo tempo que jogadores que gastam Robux ("Active Spenders") passam no jogo e por trazer jogadores novos ou de volta. Os pagamentos ficam 60 dias retidos. Ou seja, **trazer jogadores de volta também gera receita**: missões diárias e conteúdo novo contam.

## 3. Proposta — Pets ("Ajudantes do Jardim")

**Ideia:** bichinhos originais do tema jardim e floresta, que seguem o jogador e **ajudam nos verbos do jogo** (cortar, achar, vender), em vez de serem só um multiplicador.

| Ajudante (exemplo) | Efeito proposto (valores a calibrar) | Liga com |
|---|---|---|
| Joaninha | +capacidade do saco | mochilas |
| Coelho | +% de grama por corte | economia |
| Ouriço | apanha flores do orvalho e cogumelos perto do jogador | coleta da floresta / Teca |
| Toupeira | aumenta o raio das pistas de vaga-lume, sem mostrar o ponto exato | segredos |
| Vaga-lume | luz em volta do jogador (como a lanterna da Lia) | exploração |
| Minhoca dourada (rara) | pequena chance de baú extra ao terminar um jardim, limitada pelo servidor | baús |

**Como conseguir.** A versão 1 fica **100% por jogo**, sem Robux:
- "ninhos" comprados com moedas ganhas cortando;
- pets raros achados em segredos da floresta;
- 1 pet garantido ao completar o primeiro jardim.

Mesmo sem obrigação, a UI do ninho **mostra as chances**: é transparente e já deixa pronto o caminho para ovos pagos no futuro.

**Sistema:**
- inventário salvo;
- 3 vagas equipadas no início, mais com gamepass;
- fusão de 3 iguais na próxima raridade, usando a mesma escada dos baús;
- índice ("álbum") com recompensa por completar;
- **sem troca na versão 1**;
- efeitos sempre calculados no servidor, com teto (o pet nunca corta grama sozinho sem limite).

**Ovos pagos ficam para depois**, e só se o usuário quiser. Exigem tela de chances, `PolicyService`, alternativa de compra direta e revisão de risco (público jovem). Se um dia o jogo vender moedas por Robux, os ninhos comprados com moedas passam a contar como item aleatório pago e caem nessas regras.

**Arte:** modelos originais low-poly cartoon (Blender ou peças nativas), sem copiar pets de outros jogos.

## 4. Proposta — Gamepasses e compras avulsas

**Princípios:**
- vender **conveniência, espaço e visual**, não poder que deixe quem não paga para trás;
- nada de escassez falsa;
- preço lido com `GetProductInfo`.

**Gamepasses (únicos):**

| Passe (exemplo) | O que faz | Observação |
|---|---|---|
| Saco Gigante | ×2 na capacidade do saco | clássico de simulador; somar com mochila sem quebrar o balanço |
| +2 vagas de ajudante | 5 pets equipados | só depois dos pets |
| Caçamba de Bolso | vender em qualquer lugar (talvez com taxa) | não pode tornar inúteis as caçambas da floresta |
| Jardineiro VIP | visual: trilha de folhas/flores no corte, cor dourada no carrinho, plaquinha VIP | só cosmético |
| Corrida Leve | +velocidade a pé (o Sprint já existe) | ajustar com cuidado |

**Developer products (repetíveis):**
- boost ×2 de moedas por 15 min;
- boost ×2 de XP por 15 min;
- "fertilizante": tufos voltam a crescer mais rápido no próprio jardim.

**Pacotes de moedas ficam para depois**, porque transformariam os ninhos em item aleatório pago. Um boost de "sorte de baú" é modificador de probabilidade: precisa de explicação numérica e de chances atualizadas, então também fica para depois.

## 5. Proposta — Gameplay evolutiva

1. **Serviços com dificuldade crescente.** O jardineiro oferece clientes em níveis, por exemplo:
   - Casinha → Sítio → Mansão → Praça;
   - grama mais resistente, ervas daninhas, canteiros de flores que **não podem** ser cortados (penalidade ou bônus por precisão);
   - pagamento maior a cada nível.

   Usa o NPC "Novo Serviço" que já existe.
2. **Raridade das ferramentas (já prevista).** Evolução Comum → Mitológico com materiais achados na floresta. Dá sentido aos 15 modelos que já existem.
3. **Regiões novas (roadmap).** Fazenda Abandonada, Parque do Lago e Ruínas, abertas por nível ou missão, **sem bloquear o iniciante** (regra do brain 06). Cada região traz grama nova, segredos e um ajudante exclusivo.
4. **"Fama de Jardineiro" (renascimento).** Ao chegar no Imperial GX, o jogador pode **zerar moedas e cortadores** em troca de:
   - estrela de Fama;
   - bônus permanente que cresce em degraus;
   - PH extra;
   - visual.

   Pets, segredos e habilidades ficam. O custo sobe a cada estrela, e cada estrela libera algo novo (cliente, região, visual) para a volta não ser igual à primeira.
5. **Coleções e álbum.** Segredos (17), relíquias, flores, cogumelos e pets, com recompensa por completar cada página. O gnomo Nilo já faz algo parecido.
6. **Missões diárias e semanais e sequência de dias.** Exemplos: "corte 200 tufos", "venda na floresta", "ache 1 segredo". Recompensa pequena e constante. Ajuda a trazer o jogador de volta, o que também conta para o Creator Rewards. Depende da persistência.
7. **Eventos sazonais.** Flores raras na primavera, folhas no outono: conteúdo novo com pouco código.

**Balanceamento antes de tudo.** O brain 03 já registra que o nível sobe rápido demais. Medir em sessão de 30–60 min: XP/min, moedas/min, tempo por cortador. Só depois definir preços de passe e bônus de pet.

## 6. Ordem sugerida

| Passo | O quê | Por quê |
|---|---|---|
| 1 | **Persistência (P0-07)**: DataStore com trava de sessão, migração e teste de reconexão | sem isso, pets e compras são perdidos |
| 2 | Balancear a progressão atual (métricas) | base para preços e bônus |
| 3 | Missões diárias e álbum | retenção barata, reaproveita segredos e coletas |
| 4 | Pets versão 1 (só por jogo, sem troca, chances visíveis) | preenche o botão PETS "em breve" |
| 5 | Gamepasses de conveniência/visual + boosts | primeira receita, sem item aleatório pago |
| 6 | Serviços em níveis + raridade de ferramentas | profundidade |
| 7 | Fama (renascimento) e regiões novas | longo prazo |
| 8 | (Opcional) ovos pagos | só com chances, PolicyService e compra direta |

## 7. Decisões que são do usuário

- Quais ajudantes e efeitos, e se pet dá **bônus numérico** ou só **habilidade**.
- Se haverá ovos pagos em algum momento, ou nunca.
- Lista e preço base dos gamepasses.
- Se terá renascimento (Fama) e o que se perde nele.
- Ordem: começar pela persistência (recomendado) ou por outra frente.

## Fontes

- Roblox Creator Hub — [Paid random items](https://create.roblox.com/docs/production/monetization/paid-random-items)
- Roblox Creator Hub — [Developer products](https://create.roblox.com/docs/production/monetization/developer-products)
- Roblox Creator Hub — [Monetization](https://create.roblox.com/docs/en-us/production/monetization)
- Roblox Creator Hub — [Engagement-based payouts (descontinuado em jul/2025)](https://create.roblox.com/docs/production/monetization/engagement-based-payouts.md)
- DevForum — [Introducing Creator Rewards](https://devforum.roblox.com/t/introducing-creator-rewards-earn-more-by-growing-the-community/3777628)
- DevForum — [Update on paid random items restriction for UK users under 18](https://devforum.roblox.com/t/update-on-paid-random-items-restriction-for-uk-users-under-18/3072183)
- Roblox Newsroom — [Regional pricing for in-experience items](https://about.roblox.com/newsroom/2025/04/roblox-launches-regional-pricing-for-in-experience-items)
- Roblox Creator Hub — [Price optimization](https://create.roblox.com/docs/production/monetization/price-optimization.md) e [Managed pricing](https://create.roblox.com/docs/en-us/production/monetization/managed-pricing.md)
- DevForum — [Pet System (open source + how to)](https://devforum.roblox.com/t/pet-system-open-source-how-to-make-your-own/3118849) e [What is the perfect grind? (retenção)](https://devforum.roblox.com/t/what-is-the-perfect-grind-a-post-about-retention/409330)
- creation.dev — [Rebirth](https://www.creation.dev/glossary/rebirth) (glossário; opinião de prática, não dado oficial)
