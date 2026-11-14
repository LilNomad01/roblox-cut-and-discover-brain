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

## Backups

- Cortadores: `ServerStorage.CortadoresBackup_20261114`, com os modelos v2 completos.
- Objetos: `ServerStorage.PropsBackup_20261114`, com as caçambas, celeiro, poço, fenos e plantação de antes.

## Não mexido

- O **lobby** e a **floresta**, que são do Codex.
- Os cortadores **Básico** e **Mega**, que já usam malha do Blender.
