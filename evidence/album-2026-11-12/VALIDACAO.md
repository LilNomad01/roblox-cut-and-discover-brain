# Validação — álbum de coleções

**Data:** 2026-11-12 · **IA:** Claude · **Place:** `106412085364108` · **Ambiente:** Play no Studio (PC), store `_Studio`

| Teste | Resultado |
|---|---|
| Ao entrar, o álbum lê o que já existe: segredos 1/17, ajudantes 6/10 (das espécies no inventário), ferramentas 11/15 (Enxada e Foice Mitológicas da sessão anterior), eventos 0/3 | ✅ |
| Registro de segredos: 17 itens em `ReplicatedStorage.SegredosDaFloresta` (ex.: `entrada_bau`, Tipo=chest, Raridade=Comum) | ✅ |
| Eventos Chuva, Dobro e Vento forçados no servidor: página **Climas 3/3 completa**, `AlbumPaginas=1`, `BonusAlbum=0.05`, +1.000 moedas (o saldo mostra +992, ver nota) | ✅ |
| Unha evoluída até Mitológico na Oficina (materiais de teste): página **Ferramentas 15/15 completa**, `AlbumPaginas=2`, `BonusAlbum=0.1` | ✅ |
| Clique real no botão ÁLBUM: painel com 4 abas (🌲 1/17, 🐾 6/10, 🔨 15/15 verde, 🌦️ 3/3 verde), resumo "2 de 4 páginas · grama +10%", grade com ❓ e o "Baú" coletado | ✅ (screenshot) |
| **Persistência:** depois de reiniciar o Play, 2 páginas completas e +10% mantidos; o segredo coletado aparece como "Baú Comum" | ✅ |
| Botão ÁLBUM do mesmo tamanho dos botões da coluna da esquerda (ajustado depois do 1º teste) | ✅ (screenshot) |
| Console sem erros de script | ✅ |

**Nota:** com 1e17 moedas (o saldo de teste pedido pelo usuário), o número não guarda unidades exatas, só passos de 16. Por isso +1.000 aparece como +992. Com saldos normais isso não acontece.

## Não testado

- Página de segredos completa (é preciso achar os 17 na Floresta).
- Página de ajudantes completa e espécie nova registrada ao chocar nesta sessão.
- Celular.
