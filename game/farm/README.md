# Região nova: Fazenda Abandonada

**Data:** 2026-11-12 · **IA:** Claude · **Place:** `106412085364108`

**Pedido do usuário:** "3. Vamos fazer isso agora" (frentes novas). Este é o item 3 do brain 19 ("regiões novas abertas por nível ou missão, sem bloquear o iniciante"). Os valores ficam em `FazendaConfig`.

## Onde fica

No vale plano ao norte do lobby, entre os morros (campo em x −58..58, z 248..288, chão a 2,8). Uma **estrada de terra** foi pintada no Terrain, acompanhando o relevo, saindo do lobby (x 18, z 86), desviando do protótipo de grama (CutPrototypeZone) e indo até o portão (z 242).

## O que tem

- **Campo de grama alta:** 330 quadrados (30 × 11) clonados do quadrado do lote, com a versão "Cortada", num tom mais seco. A grama é **compartilhada**: todos veem o mesmo campo.
- **Cenário:**
  - cerca de madeira (alguns postes tortos e ripas faltando, sem colisão);
  - portão com a placa "🌾 FAZENDA ABANDONADA" e o requisito;
  - celeiro vermelho com porta entreaberta;
  - fardos de feno, trator enferrujado, espantalho e poço;
  - **caçamba da fazenda** (E = vender).
- **Regras:**
  - **só o carrinho corta aqui**: a cada 0,1 s, os quadrados perto do trajeto da frente do cortador, até 6 por tique;
  - cada quadrado dá a grama normal (`Economia.CortarGrama`: XP, missões, conquistas e todos os bônus) **mais 100%**, ou seja, a **grama vale 2×**;
  - tufo dourado com a mesma chance da floresta (1%, × evento);
  - o quadrado **volta a crescer em 45 s** (12 s na Chuva de Primavera).
- **Acesso:** **nível 10 ou ⭐ Fama 1**. Quem entra sem acesso volta para fora do portão e recebe um aviso. Ao entrar, aparece o título "🌾 FAZENDA ABANDONADA" com a regra principal.

## Arquivos

| Studio | Cópia aqui |
|---|---|
| `ReplicatedStorage.Shared.FazendaConfig` (novo) | `FazendaConfig.luau` |
| `CorteEDescubra.FazendaServidor` (novo) | `FazendaServidor.server.luau` |
| `StarterPlayerScripts.FazendaCliente` (novo; título ao entrar) | `FazendaCliente.client.luau` |
| `Workspace.GameWorld.Fazenda` (864 peças) e a estrada no Terrain | receita em `Fazenda.build.luau` |

**Nenhum script existente foi alterado.** A região usa `Economia`, `TufoDourado` e `Profiles` como estão.

**Teste no Studio:** no servidor, `Player:SetAttribute("FazendaTesteBloqueio", true)` finge um jogador sem acesso. Só funciona com `RunService:IsStudio()`.

## Fica para depois

- Ferramentas manuais na fazenda: hoje só o carrinho corta lá.
- Segredos e ajudante exclusivo da região, citados no brain 19.
- O tom "seco" da grama quase não aparece, porque a textura do quadrado do lote domina a cor.
