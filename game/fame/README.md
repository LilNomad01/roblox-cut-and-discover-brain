# Fama de Jardineiro — renascimento (MON-05)

**Data:** 2026-11-12 · **IA:** Claude · **Place:** `106412085364108`

**Pedido do usuário:** "Yes, Fama", seguindo a proposta do [brain 19](../../brain/19_PETS_GAMEPASS_PROGRESSAO.md). Os valores foram escolhidos pelo Claude e ficam em `FamaConfig`.

**Backup:** `ServerStorage.FamaBackup_20261112` (Economia, ProfileData, VendorIdle, PetsCliente, RecompensasCliente, MissoesCliente).

## Como funciona

- **Requisito para uma estrela:**
  - ter comprado o **Imperial GX**;
  - ter **200.000 moedas** na 1ª estrela. Cada nova estrela custa 1,6× a anterior: 320 mil, 512 mil, 819 mil…
- **Ao renascer:**
  - **perde:** moedas, cortadores (volta ao Básico) e a grama do saco;
  - **mantém:** nível e XP, ajudantes, habilidades, segredos, missões, conquistas, estatísticas e mochilas.
- **Ganha, para sempre:**
  - **+25% de grama por estrela** (`BonusFama`, até 20 estrelas = +500%), somado na `Economia.FatorGrama`;
  - **título:** Jardineiro Famoso → Estrela do Bairro → Celebridade Verde → Ícone do Gramado → Lenda Dourada;
  - **"⭐ N" sobre a cabeça**, visto por todos;
  - **coluna "Fama"** na lista de jogadores.
  - Os outros jogadores do servidor recebem um aviso.
- **HUD:**
  - botão "⭐ Fama" acima do selo de amigos;
  - ele aparece quando o jogador tem o Mega Cortador ou o Imperial GX, ou já tem estrelas, para não confundir o iniciante.
- **Painel:**
  - mostra as estrelas, o bônus atual e o próximo, os requisitos com ✅/⬜ e o que se perde e o que fica;
  - **RENASCER pede um segundo clique** de confirmação, que dura 4 s.
- **Salvamento imediato:** o servidor salva o perfil logo depois de renascer.

## Fora desta versão

- **PH extra por estrela** (proposta do brain 19): a árvore de habilidades só aceita pontos de uma lista fixa de origens, validada em `SkillRules`. Dar PH por Fama exige mudar essas regras, que são do Codex. Fica para uma decisão conjunta.
- **"Cada estrela libera algo novo"** (cliente, região ou visual): precisa das regiões novas do roadmap.

## Arquivos

| Studio | Cópia aqui |
|---|---|
| `ReplicatedStorage.Shared.FamaConfig` (novo: regras e validação) | `FamaConfig.luau` |
| `CorteEDescubra.FamaServidor` (novo, `RemoteFunction FamaAcao`: estado/renascer) | `FamaServidor.server.luau` |
| `StarterPlayerScripts.FamaCliente` (novo) | `FamaCliente.client.luau` |

**Salvo no perfil:** `profile.Fama = { version=1, estrelas }`, validado no `ProfileData`. A `Economy` é capturada dos atributos, como antes.

**Trechos em scripts existentes:**
- `Economia.FatorGrama`: `+ bonus("BonusFama", 5)`.
- `ProfileData`: `(profile.Fama==nil or FamaConfig.valid(profile.Fama))`.
- `FamaAberto` entrou na lista "uma janela por vez" de `VendorIdle`, `PetsCliente`, `RecompensasCliente` e `MissoesCliente`.
