# Cortadores remodelados em peças

**Data:** 2026-11-12 · **IA:** Claude · **Place:** `106412085364108`

**Pedido do usuário:** "Remodel in Studio". A auditoria (`evidence/modelagem-2026-11-12/AUDITORIA.md`) achou dois problemas:
- as malhas do Elétrico, do Turbo e do Trator não carregam ("Failed to load mesh asset");
- Off-Road, Colheitadeira e Imperial não tinham modelo, e o jogo usava o MowerLv antigo.

**Backup:** `ServerStorage.CortadoresBackup_20261112`, com os 3 modelos antigos e o GameServer.

## Modelos (referências do brain 21)

| Modelo | Tipo | Como ficou |
|---|---|---|
| `Cortador_Basico` | empurrar | **mantido** (a malha original carrega) |
| `Cortador_Eletrico` | empurrar | azul/ciano, bateria com raio neon e LED no lugar do motor, sem escapamento |
| `Cortador_Turbo` | empurrar | laranja, motor escuro grande, **dois escapamentos cromados**, faixa branca, aerofólio |
| `Cortador_Trator` | **dirigido** | mini trator verde: capô com grade e faróis na frente, banco, encosto e volante, **roda traseira ~1,6× a dianteira**, aros amarelos, plataforma de corte embaixo |
| `Cortador_OffRoad` | **dirigido** | cáqui (×1,15): pneus largos com **cravos**, **santo-antônio** com faróis no teto |
| `Cortador_Colheitadeira` | **dirigido** | amarela (×1,25): **plataforma com molinete** e pontas divisoras na frente, **cabine alta envidraçada**, **tanque** atrás, **tubo de descarga** dobrado ao lado |
| `Cortador_Mega` | empurrar | **mantido** (a malha original carrega) |
| `Cortador_Imperial` | **dirigido** | azul real (×1,2) com **frisos dourados**, **coroa** no capô, **diamante** na grade, aros dourados e capa vermelha no banco |

**Os nomes que o jogo procura foram mantidos:**
- **empurrar:** `Guidao` (uma caixa invisível com a mesma medida da original, que define onde as mãos seguram) e `Lamina`;
- **dirigido:** `Carroceria` (chassi que colide), `Roda*` (colidem), `VehicleSeat` "AssentoMotorista" e `Lamina` sob o deck;
- **convenção:** frente = −Z do pivô e chão 0,8 abaixo dele.

## Mudança no GameServer

```lua
if player:GetAttribute("Cortador") == "Trator" or model:GetAttribute("Veiculo") then -- [Claude 2026-11-12]
```

Off-Road, Colheitadeira e Imperial passaram a ser **dirigidos** como o Trator (`MowerMount.vehicle`). Antes eram empurrados, usando o modelo do cortador básico ampliado. O cliente já dirigia qualquer ferramenta marcada `Dirigivel`.

## Arquivos

- `Cortadores.build.luau`: a receita, rodada uma vez no Edit.
- `Cortadores_v2.build.luau`: a versão 2, com mais detalhe (ver abaixo).
- `AnimCortador_patch_2026-11-13.md`: o ajuste no cliente que anima o cortador.

## Versão 2: mais detalhe (2026-11-13)

**Pedido do usuário:** "em relação a modelação dos objetos, conseguimos melhorar?". Comecei pelos cortadores.

**Backup:** os modelos da v1 e o AnimCortador original estão em `ServerStorage.CortadoresBackup_20261113`. O backup de 2026-11-12, com as malhas originais, não foi tocado.

| Onde | O que entrou |
|---|---|
| Todas as rodas | aro rebaixado, **cubo cromado** e **5 porcas** na face de fora |
| Empurrar (Elétrico e Turbo) | **frente redonda** na carcaça, na saia e na tampa (como um deck de verdade), alavancas de altura do corte com ponta vermelha, juntas das hastes, cabo de comando, alça do saco. A manopla agora fica deitada de ponta a ponta |
| Turbo | **aletas de refrigeração**, filtro de ar redondo, tampa de combustível amarela, **puxador de partida na haste com corda** |
| Elétrico | motor redondo, **alça na bateria**, grade de ventilação na tampa |
| Dirigidos (todos) | capô com **quinas chanfradas** (cunhas), para-choque, **escapamento vertical cromado** com chapéu, respiros no capô, estribos de chapa xadrez, **lanternas traseiras**, calha de descarga no deck, faróis redondos de verdade (na v1 eram discos finos demais) |
| Trator | faixa amarela no capô |
| Off-Road | protetor de grade (bull bar) |
| Colheitadeira | colunas na cabine, giroflex laranja, borda do tanque. **Sem** para-choque e sem estribos, porque bateriam na plataforma e nas rodas |
| Imperial | friso dourado no topo do capô, para-choque dourado. A coroa e o diamante foram ajustados ao capô novo |

Número de peças: Elétrico 67, Turbo 74, Trator 65, Off-Road 87, Colheitadeira 80, Imperial 72. Só um cortador por jogador fica montado de cada vez.

**Cubo e porcas não giram:** as peças novas da roda se chamam `Cubo`/`Porca`, e não começam com `Roda`. Assim elas não colidem no veículo (o `MowerMount` faz colidir tudo que começa com "Roda") e não giram em volta do próprio centro no empurrar (o `AnimCortador` gira cada peça "Roda*" no próprio eixo).
