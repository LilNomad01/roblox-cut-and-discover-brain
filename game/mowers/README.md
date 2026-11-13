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
