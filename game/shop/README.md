# Loja Premium (Robux) + Analytics + Configs ao vivo

**Data:** 2026-11-14 · **IA:** Claude · **Place:** `106412085364108`

**Pedido do usuário:** "implemente todas as APIS, o jogo será para mais velhos então pode colocar venda de ovo com pets mais fortes por robux, venda de ferramentas mais fortes, tudo que ver em outros jogos que possa facilitar a jogabilidade por um valor externo".

## ⚠️ O que o dono precisa fazer para começar a vender

1. No **Creator Dashboard** → Monetization:
   - criar os **7 Passes** e os **6 Developer Products** abaixo (os preços sugeridos estão em `precoBase`);
   - colar cada número no campo `id` de `ReplicatedStorage.Shared.LojaConfig`.
   - Sem `id`, o item aparece como **"Em breve"** e nada é cobrado. **Não inventei nenhum ID.**
2. **Opcional:** em Dashboard → Configs, criar as chaves `preco_grama_mult` (número, padrão 1) e `loja_boost_minutos` (número, padrão 30). Elas mudam o jogo ao vivo, sem publicar.
3. Preencher o questionário de **Maturity & Compliance** declarando que o jogo tem **itens aleatórios pagos** (o Ovo Celestial).

## Itens

| Tipo | Chave | Efeito | Sugestão de preço |
|---|---|---|---|
| Passe | DobroMoedas | venda de grama ×2 | 399 |
| Passe | SacoGigante | capacidade do saco ×2 | 249 |
| Passe | MaisAjudantes | 5 ajudantes equipados (em vez de 3) | 299 |
| Passe | VenderEmQualquerLugar | botão "📦 VENDER AQUI" em qualquer lugar | 199 |
| Passe | FerramentasCelestiais | +2 quadrados por golpe nas ferramentas de mão, +50% de grama, aura celestial | 499 |
| Passe | CorridaRapida | +30% de velocidade | 149 |
| Passe | VIP | placa 👑 VIP, [VIP] no chat, +10% de grama | 299 |
| Produto | BoostMoedas / BoostGrama / BoostXP | ×2 por 30 min (o tempo soma, teto de 10 h) | 49 / 49 / 29 |
| Produto | **OvoCelestial** | ajudante aleatório **Lendário ou melhor** (chances abaixo) | 99 |
| Produto | FenixGarantida | Fênix do Jardim (Celestial, +250%), **sem sorte** | 399 |
| Produto | PacoteMateriais | 100 fibras, 10 cristais, 10 pós (Oficina) | 79 |

**Ajudantes novos, só por Robux** (ficam **fora do Álbum**, para o Álbum nunca exigir Robux):

| Ajudante | Raridade | Bônus de grama |
|---|---|---|
| 🔥 Fênix do Jardim | Celestial | +250% |
| 🐉 Dragão de Folhas | Celestial | +250% |
| 🌠 Guardião Estelar | Divino | +400% |

**Chances do Ovo Celestial** (aparecem no painel antes da compra, somam 100%):

| Ajudante | Chance |
|---|---|
| Raposa | 34% |
| Coruja | 26% |
| Cervo de Musgo | 20% |
| Vaga-lume Rei | 10% |
| **Fênix** | 7% |
| **Dragão** | 2,5% |
| **Guardião** | 0,5% |

## Regras do Roblox e da lei atendidas

- **Itens aleatórios pagos:**
  - as chances aparecem antes da compra;
  - o servidor consulta `PolicyService.ArePaidRandomItemsRestricted`. Se o jogador for restrito ou a consulta falhar, o ovo **some** do painel e fica a **compra direta** (Fênix garantida);
  - se um jogador restrito comprar o ovo mesmo assim (por exploit), ele recebe um resultado fixo (Coruja, Lendário), sem sorte.
  - Isso cobre a regra do Roblox e o ECA Digital (Lei 15.211/2025). **Público:** o usuário diz que o jogo é para jogadores mais velhos. A checagem continua obrigatória por jogador.
- **ProcessReceipt:**
  - entrega, grava o recibo em `profile.Loja.recibos` e salva o perfil **antes** de responder `PurchaseGranted`;
  - uma compra repetida pelo Roblox não é entregue duas vezes;
  - se não der para entregar (por exemplo, inventário de ajudantes cheio), responde `NotProcessedYet` e avisa o jogador.
- **Sem escassez falsa:** os itens não têm prazo artificial. Os boosts mostram o tempo real que falta.
- **Preço:** lido do Roblox com `GetProductInfo`, compatível com preço regional e Managed Pricing.

## Arquivos

| Studio | Repositório |
|---|---|
| `ReplicatedStorage.Shared.LojaConfig` | `LojaConfig.luau` |
| `ServerScriptService.CorteEDescubra.LojaData` | `LojaData.luau` |
| `ServerScriptService.CorteEDescubra.LojaServidor` | `LojaServidor.server.luau` |
| `ServerScriptService.CorteEDescubra.Analytics` | `Analytics.luau` |
| `ServerScriptService.CorteEDescubra.LiveConfig` | `LiveConfig.luau` |
| `StarterPlayerScripts.LojaCliente` | `LojaCliente.client.luau` |

**Patches** (backup em `ServerStorage.LojaBackup_20261114`):

- `PetsCatalogo`:
  - raridades Celestial e Divino;
  - 3 ajudantes `exclusivo = true`;
  - `OvosRobux`;
  - `MaxEquipadosTotal = 5` e `MaxInventarioTotal = 40`.
- `PetsData.valid`: aceita até 5 equipados e 40 ajudantes.
- `PetsServidor`:
  - `limite(p)` = 3 + 2 com o passe;
  - BindableFunction `DarPet`, usada pela loja.
- `PetsCliente`: desenha até 5 seguidores e mostra o limite certo.
- `AlbumServidor`: ignora as espécies `exclusivo`.
- `ProfileData`: novo bloco `profile.Loja` validado (`LojaData.valid`).
- `Economia`:
  - capacidade × `MultSacoLoja`;
  - XP × `MultXPLoja`;
  - `FatorGrama` + `BonusLoja` × `BoostGrama`;
  - venda × `MultMoedasLoja` × `preco_grama_mult` (ao vivo);
  - Analytics (economia, funil e nível).
- `FerramentasServer`: + `TilesLoja` quadrados por golpe e aura celestial com o passe.

## Teste no Studio sem IDs (só funciona no Studio)

- **Passes:** atributo do jogador `LojaTestePasses = "DobroMoedas,SacoGigante,..."`.
- **Produtos:** `ServerScriptService.CorteEDescubra.LojaServidor.TesteProduto:Invoke(player, "BoostMoedas")`. Segue o mesmo caminho do ProcessReceipt, com um recibo falso.
