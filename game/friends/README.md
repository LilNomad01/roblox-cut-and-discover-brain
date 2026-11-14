# Jogar com amigos (PAD-08)

**Data:** 2026-11-12 · **IA:** Claude · **Place:** `106412085364108`

**Pedido do usuário:** "continue essa e as próximas sem autorização". Este é o item 8 do [brain 20](../../brain/20_PADROES_JOGOS_SIMILARES.md).

## O que o jogador vê

- **Bônus de amigo:** cada amigo do Roblox no **mesmo servidor** dá **+10% de grama**, até 3 amigos (+30%).
  - Entra na `Economia.FatorGrama` como `BonusAmigos`, então vale também para o tufo dourado.
  - Quando um amigo entra, os dois recebem um aviso.
- **Selo no HUD**, acima de "Missões" e "Prêmios":
  - sem amigos: "👥 Convidar amigos (+10% cada)", em roxo;
  - com amigos: "👥 2 amigos aqui · +20% grama", em verde.
  - Clicar abre o convite do Roblox (`SocialService:PromptGameInvite`).
- **Não há prêmio por convidar:** só existe o bônus enquanto jogam juntos. Recompensar o convite em si é arriscado nas regras do Roblox.

## Fica para depois

"Ajudar a cortar o jardim do amigo" (a outra metade do PAD-08) **não foi feito**.

Hoje o `GameServer` liga cada lote a uma sessão de dono, e todo o caminho de corte (validação, previsão do cliente, rebrota, baú) assume que quem corta é o dono. Abrir isso para visitantes mexe no núcleo do jogo e precisa de teste com 2 jogadores reais (Team Test), então ficou como próximo passo.

## Arquivos

| Studio | Cópia aqui |
|---|---|
| `CorteEDescubra.AmigosServidor` (novo) | `AmigosServidor.server.luau` |
| `StarterPlayerScripts.AmigosCliente` (novo) | `AmigosCliente.client.luau` |

**Atributos:** `AmigosNoServidor`, `AmigosNomes` e `BonusAmigos`.

A amizade é consultada com `Player:IsFriendsWith`, com cache por par de jogadores. A conta é refeita quando alguém entra ou sai.

**Teste no Studio com um jogador só:** no servidor, `Player:SetAttribute("AmigoTeste", 2)` finge 2 amigos.
- Só funciona com `RunService:IsStudio()`.
- Um cliente não consegue mudar esse atributo no servidor.
