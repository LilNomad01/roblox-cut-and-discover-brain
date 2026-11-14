# Pets — "Ajudantes do Jardim" com multiplicador de grama

**Data:** 2026-11-11 · **IA:** Claude · **Place:** `106412085364108`

**Pedido do usuário:** "e sobre os pet com multiplicador", com a instrução anterior de seguir sem pedir autorização. Os valores abaixo foram escolhidos pelo Claude e podem ser ajustados no catálogo.

**Backup:** `ServerStorage.PetsBackup_20261111` (InterfaceHUD, ProfileData, Economia, VendorIdle).

## Como funciona

- **10 ajudantes originais** em 5 raridades. Cada um dá um **bônus de grama**; o jogador equipa até **3**, e os bônus somam.

  | Raridade | Bônus | Ajudantes |
  |---|---:|---|
  | Comum | +10% | Joaninha, Minhoca |
  | Incomum | +20% | Coelho, Ouriço |
  | Raro | +40% | Toupeira, Sapo |
  | Lendário | +75% | Coruja, Raposa |
  | Mitológico | +150% | Cervo de Musgo, Vaga-lume Rei |

- **Fórmula:** grama por tufo = 1 × multiplicador do cortador × (1 + soma dos bônus equipados). Vale no lote e na floresta. O saco continua com valores inteiros: a fração que sobra entra no tufo seguinte.
- **Ninhos** comprados só com **moedas ganhas jogando**. As chances de cada ninho aparecem na tela:

  | Ninho | Preço | Chances |
  |---|---:|---|
  | Ninho do Jardim | 300 | Joaninha 40%, Minhoca 30%, Coelho 18%, Ouriço 10%, Toupeira 2% |
  | Ninho da Floresta | 6.000 | Coelho 30%, Ouriço 25%, Toupeira 22%, Sapo 15%, Coruja 6%, Raposa 2% |
  | Ninho Real | 60.000 | Toupeira 30%, Sapo 30%, Coruja 22%, Raposa 14%, Cervo 3%, Vaga-lume 1% |

- **Inventário:**
  - até 30 ajudantes;
  - clicar num cartão equipa ou tira;
  - o "X" solta o ajudante (pede confirmação com um segundo clique);
  - o botão "Equipar melhores" equipa os 3 de maior bônus.
- **Visual:** os ajudantes equipados seguem o jogador. Os que andam vão pulando atrás; o Vaga-lume e a Coruja voam. Todos os jogadores veem os ajudantes uns dos outros (até 160 studs). São modelos de peças nativas, sem IDs.
- **Salvos no perfil** (`profile.Pets`), com validação.

## Arquivos

| Studio | Cópia aqui | Função |
|---|---|---|
| `ReplicatedStorage.Shared.PetsCatalogo` (novo) | `PetsCatalogo.luau` | Espécies, raridades, bônus, ninhos e chances |
| `CorteEDescubra.PetsData` (novo) | `PetsData.luau` | Regras puras: validação, bônus e sorteio |
| `CorteEDescubra.PetsServidor` (novo) | `PetsServidor.server.luau` | `RemoteFunction PetsAcao`: `chocar`, `equipar`, `soltar`, `melhores`, `sync` |
| `StarterPlayerScripts.PetsCliente` (novo) | `PetsCliente.client.luau` | Painel e ajudantes seguindo |

O servidor publica dois atributos:
- `BonusPets`: soma dos bônus equipados;
- `PetsEquipados`: lista de espécies, para os clientes desenharem.

### Trechos em scripts existentes

`InterfaceHUD`: o botão PETS deixou de mostrar "em breve":

```lua
-- [Claude 2026-11-11] PETS abre o painel dos Ajudantes do Jardim (PetsCliente escuta o atributo local PetsAberto)
botaoMenu("Pets", "🐾", Color3.fromRGB(255, 130, 190), Color3.fromRGB(220, 60, 140), 3, function()
	local pl = Players.LocalPlayer
	pl:SetAttribute("PetsAberto", not pl:GetAttribute("PetsAberto"))
end)
```

`ProfileData`: `local PetsData=require(script.Parent.PetsData)` e, em `validExtensions`:

```lua
        and (profile.Pets==nil or PetsData.valid(profile.Pets))
```

`Economia.EncherSaco`:

```lua
local restoGrama: { [Player]: number } = {}
...
	local bonusPets = tonumber(p:GetAttribute("BonusPets")) or 0
	local mult = (p:GetAttribute("Multiplicador") or 1) * (1 + math.clamp(bonusPets, 0, 10))
	local bruto = qtd * mult + (restoGrama[p] or 0)
	local inteiro = math.floor(bruto)
	restoGrama[p] = bruto - inteiro
	local add = math.min(inteiro, max - saco)
```

`VendorIdle`: `PetsAberto` entrou na lista de janelas que escondem o balão dos NPCs.

## Segurança e regras

- **Tudo é decidido no servidor:** preço, moedas, sorteio, limite de 30, limite de 3 equipados e intervalo mínimo de 0,35 s entre ações. O cliente só pede.
- **Sem itens aleatórios pagos.** Ninhos usam moedas ganhas jogando, e o jogo não vende moedas por Robux. As chances aparecem mesmo assim. **Se um dia o jogo vender moedas ou ninhos por Robux**, os ninhos passam a seguir a política de itens aleatórios pagos: `PolicyService` e alternativa para usuários restritos (ver `brain/19`).
- **Sem troca entre jogadores.**

## Efeito no balanceamento

Os ajudantes **aceleram as moedas**, porque mais grama gera mais venda. Valores típicos:

| Fase | Equipados | Bônus |
|---|---|---:|
| Começo (Ninho do Jardim) | 3 comuns e incomuns | +30% a +50% |
| Meio (Ninho da Floresta) | raros | ~+80% a +120% |
| Fim, com sorte | Mitológicos | até +450% |

Os ninhos também **gastam moedas**, o que compensa parte disso. O modelo de `game/balance/` ainda não inclui pets. Se o jogo ficar rápido demais, os pontos de ajuste ficam no `PetsCatalogo`: os bônus por raridade e os preços dos ninhos.

## Diferença em relação à proposta do brain 19

O brain 19 sugeria ajudantes com **habilidades** (joaninha aumenta o saco, toupeira amplia as pistas...). O usuário pediu **multiplicador**, então a versão 1 é só bônus de grama. As habilidades podem entrar depois como segundo efeito.
