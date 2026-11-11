# Validação — Ajudantes do Jardim (pets com multiplicador)

**Data:** 2026-11-11 · **IA:** Claude · Play solo no PC, no Studio (DataStore `_Studio`).

| Verificação | Resultado |
|---|---|
| Perfil antigo (sem pets) | Carregou com a validação nova; o servidor iniciou `BonusPets=0` |
| Chocar (remote real `PetsAcao`) | Jardim → joaninha; Jardim → coelho; Floresta → coelho; Real → Vaga-lume Rei. Moedas 80.000 → 13.400 (300+300+6.000+60.000) |
| Equipar automático | Os 3 primeiros entraram equipados (+50%) |
| "Equipar melhores" | Vaga-lume + Coelho + Coelho = **+190%**; `PetsEquipados=vagalume,coelho,coelho` |
| Multiplicador | `EncherSaco` 10 vezes: **28** de grama com +190% contra **10** sem ajudantes (a fração passa para o próximo tufo) |
| Painel | `painel-ajudantes.jpg`: ninhos com chances, inventário, selo EQUIPADO e bônus no topo; ícones 🪙/🪱/✕ trocados por 💰/🐛/X porque não apareciam na fonte do Roblox |
| Ajudantes seguindo | `ajudantes-seguindo.jpg`: os dois coelhos pulando atrás do jogador (o Vaga-lume voa mais alto e ficou fora do quadro) |
| Salvamento | Parei o Play e entrei de novo: os 4 ajudantes voltaram, os mesmos 3 equipados, +190% |
| Validações do servidor | 4º equipado recusado; soltar funciona (4 → 3); ninho sem moedas: "Faltam 46.500 moedas"; ninho inexistente: recusado; ações a menos de 0,35 s: recusadas |
| Fontes | `PetsCatalogo` 2843/812624524, `PetsData` 1719/541686918, `PetsServidor` 4609/273610643, `PetsCliente` 23410/187338854, iguais no Studio e no repositório |
| Console | sem erros |

## Observações

- **Corte real no lote:** 16 primeiros cortes deram 69 de grama, mais que 16 × 2,9. O excesso vem do **fechamento do corte** (`closeCut`), que já dava grama antes desta mudança. O multiplicador foi conferido isoladamente (linha acima).
- **Painel desatualizado em teste:** como as ações de teste foram pelo remote, o painel aberto não se redesenhou na hora. Pelos botões do próprio painel, ele se redesenha.

## Não testado

- Clique real nos botões do painel com o mouse (as ações foram pelo mesmo remote que os botões usam).
- Animação de revelação ao chocar.
- Celular (escala do painel).
- Outro jogador vendo os ajudantes.
- Jogo publicado.
