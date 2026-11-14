# Validação — prêmios, códigos e grama dourada

**Data:** 2026-11-11 · **IA:** Claude · Play solo no PC, no Studio (DataStore `_Studio`).

| Verificação | Resultado |
|---|---|
| Carregar perfil com a extensão nova | OK (perfil real, sem modo temporário) |
| Sorteio do lote | 2 tufos dourados (`Grass_01_01`, `Grass_02_07`), com brilho no cliente |
| Diária | +150 (dia 1, Básico); segundo clique: "Você já pegou o prêmio de hoje" |
| Tempo jogado | o prêmio de 5 min ficou bloqueado antes do tempo ("Jogue 5 min para liberar") |
| Códigos | `bemvindo` (minúsculo) → +500; repetido → "já usou"; código falso → "inválido ou expirado" |
| Moedas | 13.800 → 14.450 (150 + 500) |
| Corte real do tufo dourado (carrinho) | o tufo perdeu o atributo e foi cortado; **+52 moedas** = 9 × (1 + 1,9 dos ajudantes) × 2; +20 XP |
| Regras da sequência (função pura) | nunca pegou → dia 1; ontem (seq 3) → dia 4; ontem (seq 7) → seq 8 (dia 1 do ciclo); pulou um dia → 1; hoje → bloqueado; validação recusa valores inválidos |
| Salvamento | depois de parar e voltar: a diária continua pega (`pode=false`, seq 1) e `BEMVINDO` continua usado |
| Painel | `painel-premios.jpg`: 7 dias com o dia atual destacado, 4 prêmios de tempo, campo de código e botão no canto |
| Fontes | iguais no Studio e no repositório (hashes no LOG) |
| Console | sem erros |

## Não testado

- **Grama dourada na floresta** (1% por corte; o código usa o mesmo pagamento do lote, mas não saiu nenhum nos testes).
- **Coleta real do prêmio de tempo** (precisa de 5 min de sessão).
- **Bônus de grupo** (está desligado sem o id do grupo).
- **Virada do dia real** (testada só pela regra pura).
- Clique com o mouse nos botões do painel, celular, multiplayer e jogo publicado.
- O texto flutuante dourado não aparece na captura, porque a renderização 3D ficou preta nesse momento.
