# NPCs — visual próprio, animação, conversa e placa de nome

**Data:** 2026-11-11 · **IA:** Claude · **Place:** `106412085364108` · **Backup no Studio:** `ServerStorage.NpcBackup_20261111` (`VendorAvatar`, `ForestCommerceWorld`, `GameServer` e `VendorIdle` antes da mudança).

**Pedido do usuário:** "melhorar NPCs". Depois da auditoria, ele escolheu as quatro frentes: visual próprio, animação, conversa e placa de nome.

## Auditoria (antes)

| Achado | Detalhe |
|---|---|
| **Bug:** comerciantes de costas | Guto, Lia e Teca olhavam para −Z, mas o balcão e o prompt ficam em +Z: o jogador via as costas deles. |
| Todos iguais | Os 4 humanos (jardineiro do lote e os 3 comerciantes) usam o mesmo modelo, o mesmo chapéu de palha e o mesmo cabelo loiro. Só a cor da camisa mudava. |
| Quase parados | `VendorIdle` só fazia uma respiração mínima, um leve giro de cabeça e um aceno. |
| Uma frase cada | Os comerciantes tinham uma linha no catálogo. O jardineiro mostrava só um aviso na tela. |
| Itens ancorados | A mochila do Guto e o avental da Teca eram peças ancoradas e não acompanhavam o corpo. |

O gnomo Nilo **não foi alterado**. Ele é um modelo de peças, fica escondido de propósito, e uma placa de nome poderia revelá-lo antes da hora.

## O que mudou

| Arquivo (Studio) | Cópia aqui | Mudança |
|---|---|---|
| `ServerScriptService.CorteEDescubra.VendorAvatar` | `VendorAvatar.luau` (completo) | `Avatar.create(tipo)` com visual por tipo (detalhes abaixo). Cada tipo mantém sua própria cópia de modelo. |
| `StarterPlayerScripts.VendorIdle` | `VendorIdle.client.luau` (completo) | Animação por tipo, virar e acenar, placa de nome e balão de fala (detalhes abaixo). |
| `ReplicatedStorage.Shared.NpcFalas` (novo) | `NpcFalas.luau` | Falas por NPC: primeira visita, cumprimentos, fala do momento (`contexto`) e dicas. |
| `ForestCommerceWorld` | trecho abaixo | Cria cada comerciante com o seu tipo, gira 180° para ficar de frente para o balcão e solda mochila/avental ao tronco. |
| `GameServer` | trecho abaixo | Expõe `JardimCortes` e `JardimPronto` como atributos do jogador, para as falas do jardineiro. |

### Visual por tipo (`VendorAvatar`)

Só foram usados os IDs que o projeto já tinha. Cada tipo muda:

- pele, cabelo e roupa;
- altura e largura;
- acessórios feitos de peças nativas.

| NPC | Acessórios |
|---|---|
| Jardineiro | macacão e rastelo |
| Guto | boné verde e amarelo, alças da mochila e cantil |
| Lia | chapéu de exploradora, rabo de cavalo, lenço e binóculo |
| Teca | chapéu de palha com flores, coque e regador |

A textura do cabelo foi removida para que a cor de cada NPC apareça; a malha do cabelo continua a mesma.

### Comportamento no cliente (`VendorIdle`)

**Animação parada de cada NPC:**

| NPC | O que faz |
|---|---|
| Jardineiro | balança o peso do corpo e enxuga a testa a cada 11 s |
| Guto | fica com os polegares nas alças e dá um pulinho a cada 7 s |
| Lia | fica debruçada no mapa e olha o horizonte a cada 9 s |
| Teca | rega as plantas a cada 6 s |

**Reação ao jogador:**

- A até 16 studs, o NPC vira o corpo e a cabeça para o jogador.
- A até 12 studs, ele acena.
- A mais de 120 studs, ele não é animado, para economizar processamento.

**Placa de nome:** mostra o nome e a função, com a cor de cada NPC. Some a mais de 45 studs e não atravessa paredes. A placa e o balão foram puxados 3 studs na direção da câmera para não ficarem atrás do toldo das barracas.

**Balão de fala**, com efeito de digitação. Ao chegar perto, o NPC mais próximo diz em sequência:

1. a fala de primeira visita da sessão, ou um cumprimento;
2. a fala do momento, quando houver;
3. uma dica.

Depois ele fica quieto até o jogador se afastar mais de 18 studs. O balão some quando:

- uma loja ou menu está aberto (`ForestShopOpen`, `LojaAberta`, `MenuJogadorAberto`, `SkillTreeOpen`);
- o jogador usa o prompt E daquele NPC.

**Jardineiro:**

- Só conversa com o **dono do lote** (`OwnerUserId`).
- De perto, a placa e o balão substituem o selo do servidor ("NOVO SERVIÇO" ou "TERMINE O JARDIM"). De longe, o selo continua aparecendo.

## Regras respeitadas

- **Falas verdadeiras:** cada dica descreve uma mecânica que existe hoje. Exemplos:
  - mochila substitui a anterior;
  - lanterna de 18 studs;
  - kit com duração de 12 s;
  - flor trocada por 40 moedas;
  - 3 cogumelos por 1 kit;
  - contrato que restaura a caçamba.
- **O jardineiro do lote não é o Zeca e não fala da Floresta Esquecida.** Essa ideia continua estacionada em `ideas/IDEIAS_FUTURAS_NAO_IMPLEMENTAR.md`.
- **Nenhuma loja, preço ou transação foi alterada.** Também não há ID de catálogo, AnimationId nem SoundId novos.
- **A "primeira visita" vale só para a sessão;** nada é salvo.

## Trechos alterados

`ForestCommerceWorld`:

```lua
local ok,rig=pcall(avatar.create,id) -- [Claude 2026-11-11] visual próprio de cada comerciante
...
local ok,rig=pcall(merchantAvatar,id)
...
-- [Claude 2026-11-11] de frente para o balcão e para o jogador (o balcão fica em +Z; antes o NPC ficava de costas)
rig:PivotTo(CFrame.new(pos+Vector3.new(0,size.Y*.5,0))*CFrame.Angles(0,math.pi,0))
...
-- [Claude 2026-11-11] avental/mochila soldados ao tronco (antes ficavam ancorados e não acompanhavam a animação)
local torso=rig:FindFirstChild("UpperTorso") or rig.PrimaryPart
local extra
if id=="Teca" then
    extra=part(rig,"Avental",Vector3.new(1.25,1.5,.12),rig.PrimaryPart.CFrame*CFrame.new(0,.1,-.62),accent,Enum.Material.Fabric)
else
    extra=part(rig,"MochilaNPC",Vector3.new(1.4,1.8,.8),rig.PrimaryPart.CFrame*CFrame.new(0,.2,.95),accent,Enum.Material.Fabric)
end
extra.Anchored=false extra.Massless=true
local weld=Instance.new("WeldConstraint") weld.Part0,weld.Part1,weld.Parent=torso,extra,extra
```

`GameServer`, dentro de `sync`, depois de `serviceNpcRefresh(s)`:

```lua
-- [Claude 2026-11-11] progresso do jardim para as falas do jardineiro (só leitura no cliente)
player:SetAttribute("JardimCortes",s.job.cutCount or 0)
player:SetAttribute("JardimPronto",s.job.finished==true)
```

## Limitações

- **Rosto:** todos ainda têm o mesmo, porque a cabeça é a mesma (`10725826963`). Mudar exigiria um ID de rosto ou cabeça, que não foi inventado. Fica para o usuário escolher.
- **Prévia do editor:** `Workspace.ForestEditorPreview`, do Codex, ainda mostra os comerciantes antigos. A mudança aparece no Play.
