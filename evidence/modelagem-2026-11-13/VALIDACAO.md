# Validação: modelagem, rodada MOD-02 (2026-11-13)

**IA:** Claude · **Place:** `106412085364108` · **Ambiente:** Edit e Play no Studio (PC)

| Item | O que foi feito | Prova |
|---|---|---|
| Ferramentas por raridade | Antes, conferi numa vitrine as 15 ferramentas: as raridades já diferem por textura e tamanho. Acrescentei uma aura de brilho e luz ao **Lendário** (dourado) e ao **Mitológico** (roxo) | Play: Foice Mitológica com `AuraRaridade` (Rate 10) e luz roxa visível (captura) |
| Fazenda: plantação | `Fazenda.Plantacao` atrás da cerca norte (z 297–305), numa área antes vazia e plana (chão 2,8). **Milharal** (3 leiras, pés de 3,4 a 4,6 com folhas caídas, espiga e pendão) e **abóboras** (3 leiras com ramas, abóboras de tamanhos variados com talo). 480 peças, só decoração: sem colisão, sem consulta, sem toque | capturas no Edit; em Play o modelo continua lá (480 peças) e a Fazenda sobe normal (330 quadrados) |
| Quadros de Missões e Ranking | telhado de **duas águas** vermelho, beirais, cumeeira e sapatas nos postes. No Ranking, a placa "MELHORES JARDINEIROS", antes escondida pelo telhado, foi trazida para a frente | capturas. Play: 2 águas em cada quadro, prompt de Missões ativo, um só QuadroRanking (sem duplicar) |
| Console | sem erros novos | Play |

**Receitas:**
- `game/farm/Plantacao.build.luau`
- `game/lobby-boards/TelhadoQuadros.build.luau`
- `game/tool-rarity/AuraRaridade_patch_2026-11-13.md`

**Backups:** `ServerStorage.CortadoresBackup_20261113` (FerramentasServer, `<Quadro>_Telhado`).

**Observação para o Codex:** no Edit aparece um aviso de tela "JARDIM 0/64 / Ande sobre a grama para cortar" em todas as capturas. Não é deste trabalho. Parece uma `StarterGui` de prévia.

**Não testado:** a aura Lendária em Play (o código é o mesmo da Mitológica, só muda a cor); celular.

**Ficou de fora:** a variação de tufos (alturas e tons). Os tufos dos lotes e da floresta são gerados pelos sistemas de corte e pela floresta do Codex, então mexer neles muda a jogabilidade e a área dele. Precisa combinar antes.
