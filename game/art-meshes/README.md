# Arte em malha: cortadores e objetos da Fazenda/lotes trocados por malhas geradas

**Data:** 2026-11-14 · **IA:** Claude · **Place:** `106412085364108`

**Pedido do usuário:** "os assets geométricos estão feios, tem como melhorar? pegar alguns prontos ou deixar mais bonito e não 100% geométrico".

## Escolha: malhas geradas, e não modelos prontos da loja

- **Modelos prontos:** os cortadores da Creator Store, buscados em 2026-11-14, eram quase todos de criadores **não verificados**. Vários copiavam marcas ou jogos (Craftsman, Plants vs. Zombies, Hello Neighbor) e podiam trazer scripts escondidos.
- **Malhas geradas:** usei o **gerador de malhas com IA do Studio** (`generate_mesh`), em estilo cartoon. Os assets são **originais**, ficam na conta do dono e **não têm script**.

## IDs publicados (devolvidos pela ferramenta; não inventados)

| Asset | ID |
|---|---|
| Cortador Elétrico | 90405154701803 |
| Mini Trator | 80982995595939 |
| Off-Road | 82707236427065 |
| Colheitadeira | 121855741944118 |
| Imperial GX | 83117498556691 |
| Turbo | gerado na chamada síncrona (a resposta expirou); o modelo entrou normalmente |
| Caçamba | 119861177992084 |
| Celeiro | 79498991913314 |
| Poço | 100000870006588 |
| Fardo de feno | 138999732542055 |
| Abóbora | 85443347305232 |
| Pé de milho | 136157939697220 |

Os modelos-base ficam em `ServerStorage.GameAssets.Gerados` para reaproveitar.

## Como foi encaixado (o jogo continua funcionando igual)

### Cortadores de empurrar (Elétrico e Turbo)

A malha virou o modelo. As peças receberam os nomes que o jogo e a animação usam:
- `Carcaca` (vibra);
- `Motor` (fumaça);
- `SacoColetor` (aparas);
- `Manopla`;
- `RodaFrenteEsq/Dir` e `RodaTrasEsq/Dir` (giram).

Também entraram peças invisíveis:
- a `Lamina` embaixo do deck;
- o `Guidao`, uma caixa igual à manopla, que posiciona as mãos.

A ponta do guidão ficou no mesmo lugar do modelo antigo (z 2,6). No Elétrico, a IA trocou os nomes das rodas, então elas foram identificadas pela posição.

### Cortadores dirigidos (Trator, Off-Road, Colheitadeira e Imperial)

- **O que continua do modelo antigo:** só o funcional, invisível — `Carroceria` (chassi que colide), as 4 `Roda*` de colisão, a `Lamina` e o `AssentoMotorista`.
- **O visual:** a malha nova entra por cima, com peças `Visual_*`.
- **O banco:** foi movido para cima do assento da malha.
- **Orientação:** conferida pela regra "o volante fica à frente do banco".
- **Peças:** de 65 a 87 para **15** por veículo.

### Caçambas (4 lotes e Fazenda)

O `Corpo` (prompt de venda e colisão), a `ZonaVenda` e a placa ficaram. As peças visuais antigas ficaram **invisíveis** (as que colidiam continuam colidindo), e a pasta `Forma` foi apagada. A malha nova tem grama dentro.

### Celeiro

As paredes antigas ficaram invisíveis, mantendo a colisão. A malha nova foi girada para a parede do oitão ficar em x=95,8, e **as portas antigas** (com o X branco e a porta do palheiro) **continuam visíveis na frente**, porque a malha gerada não tem portas.

### Poço e feno

As peças antigas ficaram invisíveis e a malha entrou no lugar. A pilha de 3 fardos foi rearrumada: dois lado a lado e um em cima.

### Plantação

Os pés de milho feitos de peças viraram **60 malhas** de milho, e as abóboras viraram **32 malhas**. As leiras e as ramas ficaram. A plantação caiu de 480 para 208 peças.

## Rodada 2: Oficina e quadros (mesmo dia)

Gerados **em partes**, e cada parte foi **esticada para o tamanho da peça antiga** correspondente. A frente da malha é o +Z local, por isso o giro de 180° em relação às peças antigas.

- **Oficina** (`Gerado_Oficina`, malha 4 partes):
  - a bancada ocupa o lugar do tampo + pernas;
  - o painel de pregos ocupa o `Painel`;
  - o telhado tem 2,2 de altura sobre o antigo;
  - a bigorna.
  - Ficaram: as 3 ferramentas penduradas (`Vitrine_*`), a placa OFICINA e a peça `Interacao` com o prompt "Evoluir ferramentas".
- **Quadro de Missões e Ranking** (`Gerado_Quadro`, ID 105905633786912):
  - o telhado ocupa o telhado de 2 águas;
  - os 2 postes;
  - a moldura de madeira com cortiça, atrás dos papéis no de Missões e atrás do painel do placar no Ranking.
  - Ficaram: papéis, alfinetes, placas, painel do ranking, `PlacaMundo` e o prompt "Ver missões".

As peças antigas ficaram invisíveis (backup em `PropsBackup_20261114`). **Play:** os prompts continuam ativos, sem erros.

## Rodada 3: lobby do Codex (pedido do usuário: "faça a parte do codex também")

**Importante para o Codex:**
- a arte do lobby é gerada pelo `LobbyGardenArt` e pelo `LobbyVillageLife`;
- se `GameWorld.LobbyGardenReform` existe, nada é reconstruído no Play. Confirmado em Play: as malhas continuaram;
- **se o Codex reconstruir o lobby pelo instalador, as malhas somem.** Nesse caso, é preciso repetir esta troca ou levar a lógica para dentro dos builders;
- backup do lobby antes da troca: `ServerStorage.LobbyMalhaBackup_20261114` (as duas raízes completas).

| O quê | Quantos | Como |
|---|---|---|
| Flores (Haste + 4 Pétalas + Miolo) | **1.008** | a flor-malha mantém a **cor original** de cada flor (pétalas sem textura), a escala da haste e um giro aleatório. São 3 peças por flor, contra 6 antes |
| Samambaias | 15 | malha no lugar, escalada pela altura |
| Caixotes | 12 | caixote de madeira com legumes |
| Bancos do jardim (`BancoDoJardim`) | 6 | banco de madeira e metal. Os bancos originais da praça, que o Codex reaproveitou, **não** foram trocados |
| Regadores | 9 | regador de metal |
| Rochas estratificadas | 15 | rocha em camadas |
| Fardos de feno do recanto | 3 | fardo redondo |
| Moinho da Horta | 1 | torre e telhado no lugar da casca. **As pás novas ficam dentro do `Rotor`** e continuam girando com o `LobbyGardenAmbience` (Play: 10,3° por segundo) |
| Casa do Jardim, Abrigo de Sementes, Recanto de Descanso (pérgola), Regador das Descobertas, Carroça da Colheita, Estufa da Vila | 6 | uma malha por estrutura no lugar da casca. Vasos, flores, placas e canteiros ficaram. A estufa ficou com 35% de transparência para mostrar os canteiros |

**Regra de encaixe:** as peças que colidem ficaram invisíveis, mantendo a colisão; as decorativas sem colisão foram apagadas. Prompts e textos não foram tocados.

**Peças do lobby:** LobbyGardenReform de 6.764 para 3.743; LobbyVillageLife de 1.881 para 1.547.

**IDs publicados:**

| Malha | ID |
|---|---|
| Flor | 106655645558661 |
| Samambaia | 124927054589952 |
| Caixote | 91574125452081 |
| Banco | 72285883843959 |
| Regador | 80111273834084 |
| Rocha | 115851263378848 |
| Moinho | 139534118232918 |
| Casa do Jardim | 122021148342860 |
| Abrigo | 92030900903171 |
| Pérgola | 83004966659188 |
| Carroça | 122788099612743 |
| Regador-monumento | 138585332104586 |
| Estufa | 129587209216511 |

**Ainda em peças:** os bancos e postes originais da praça, as hortas, cercas, sebes, os canteiros (bordas de madeira e terra), as árvores (do Codex) e a floresta.

## Backups

- Cortadores: `ServerStorage.CortadoresBackup_20261114`, com os modelos v2 completos.
- Objetos: `ServerStorage.PropsBackup_20261114`, com as caçambas, celeiro, poço, fenos e plantação de antes.

## Não mexido

- O **lobby** e a **floresta**, que são do Codex.
- Os cortadores **Básico** e **Mega**, que já usam malha do Blender.
