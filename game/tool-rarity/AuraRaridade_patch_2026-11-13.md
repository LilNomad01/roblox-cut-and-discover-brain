# Patch em `ServerScriptService.CorteEDescubra.FerramentasServer` (2026-11-13, Claude, MOD-02)

**O que já existia:** cada raridade das ferramentas manuais (Unha, Enxada, Foice) já tinha textura e tamanho próprios. Os cabos mudam de cor: madeira no Comum, verde no Incomum, azul no Raro, vermelho e amarelo no Lendário, roxo e rosa no Mitológico.

**O que faltava:** reconhecer de longe as duas raridades mais altas.

**Patch:** em `equiparManual`, antes do weld na mão, entra uma "aura" na lâmina. É um `Attachment` "Aura" posicionado entre `LaminaBase` e `LaminaPonta`, com:
- um `ParticleEmitter` "AuraRaridade" (brilhinhos);
- uma `PointLight` "AuraLuz" com alcance 6 e sem sombras.

| Raridade | Cor | Partículas por segundo | Brilho da luz |
|---|---|---|---|
| Lendário | dourado (255,200,70) | 6 | 0,8 |
| Mitológico | roxo (205,110,255) | 10 | 1,2 |

**Backup do script original:** `ServerStorage.CortadoresBackup_20261113.FerramentasServer`.
**Tamanho depois do patch:** 13728 bytes.

**Prova em Play:** com a Foice Mitológica equipada (tecla 3), a ferramenta `Foice_Mitologico` tinha `AuraRaridade` com Rate 10, e a luz roxa aparece no personagem (captura).
