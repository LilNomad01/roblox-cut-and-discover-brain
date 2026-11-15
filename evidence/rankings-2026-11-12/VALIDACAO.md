# Validação — rankings globais e conquistas (PAD-07)

**Data:** 2026-11-12 · **IA:** Claude · **Place:** `106412085364108` · **Ambiente:** Play no Studio (PC), stores `_Studio`

| Teste | Resultado |
|---|---|
| Ao entrar com 4 selos: a conquista "Ajudante Oficial" (3 selos) é dada na hora, `ConquistasFeitas=1` | ✅ |
| Corte real com o carrinho e venda na caçamba: `cortes=12`, `dourados=2`, `vendas=2` | ✅ |
| 1º tufo dourado cortado: "Brilhou!" é dada (`ConquistasFeitas=2`) | ✅ |
| Botão "🏆 Conquistas" (clique real) troca a vista: resumo, 15 cartões com cadeado, barra e prêmio; a feita fica dourada com "✓ Feita" | ✅ (screenshots) |
| Placar do lobby, 1ª leitura (15 s após abrir): "📋 Mais selos de missão: 🥇 Barbosaa — 4"; demais colunas "Ninguém ainda. Seja o primeiro!" | ✅ OrderedDataStore gravou e leu |
| **Persistência:** parar e iniciar o Play de novo mantém `cortes=12`, `dourados=2`, `vendas=2` e 2 conquistas | ✅ |
| Gravação ao sair: na sessão seguinte o placar mostra "✂️ Mais tufos cortados: 🥇 Barbosaa — 12" | ✅ |
| Console sem erros de script | ✅ |

## Corrigido no teste

- O botão "Conquistas" encostava no X. Ele foi afastado.
- A borda de um cartão de missão aparecia atrás da lista. A vista de conquistas ficou mais larga.

## Não testado

- Conquistas de jardim, de baú/segredo e as metas altas. Usam o mesmo caminho das testadas.
- Badges: nenhum id existe.
- Visual 3D do placar: a captura do Studio sai preta, então só os textos foram conferidos.
- Vários jogadores no placar, servidor publicado (store sem `_Studio`), celular.
