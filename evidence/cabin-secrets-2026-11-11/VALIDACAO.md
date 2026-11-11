# Validação — Cabana Esquecida e segredos da floresta

**Data:** 2026-11-11 · **IA:** Claude · Play solo no PC, no Studio (place `106412085364108`).

| Verificação | Resultado |
|---|---|
| Cabana por fora | `antes-cabana-*.jpg` × `depois-cabana-frente.jpg` e `depois-cabana-varanda.jpg`: janelas âmbar, varanda coberta com lanterna pendurada, porta entreaberta mostrando a estante, trepadeiras, flores, cerca e caminho de pedras. 237 peças de decoração. |
| Interior | `depois-cabana-interior.jpg`: piso de tábuas (o terreno ficava 0,2 stud acima da fundação e foi removido do interior), lareira acesa à vista, mesa, cadeira, cama, estante, barris, mapa e empena fechada |
| Registro público | 17 segredos registrados (o gnomo fica de fora); 16 pistas ativas no início (o baú da entrada já começa revelado) |
| Revelação real | O carrinho cortou o mato em volta do diário: revelado no 9º tufo dentro do raio, como manda a regra do servidor. A pista sumiu, o feixe turquesa apareceu e a relíquia ficou visível com luz (`segredo-revelado-feixe.jpg`). |
| Coleta real (prompt E) | Diário: aviso "SEGREDO ENCONTRADO! Segredos da floresta: 1 / 17" e moedas (`segredo-coletado-aviso.jpg`). Baú da entrada: "2 / 17", +14 moedas (valor de antes); tampa girou 70° e subiu 1,13 stud; feixe removido. |
| Relíquias | Menir com runas (`reliquia-pedra-runica.jpg`). Flor de cristal conferida depois da correção de altura. As relíquias estavam ~2 studs abaixo do terreno; agora usam o ponto real do chão. |
| Pistas | Vaga-lumes acima do mato (`pista-vagalumes.jpg`); ficaram maiores e mais brilhantes depois da primeira rodada, porque estavam pouco visíveis de dia |
| Fontes | `CabanaDetalhes` 19383/643972366, `ReliquiasDaFloresta` 7279/952189281, `SegredosDaFloresta` 12543/234139614, iguais no Studio e no repositório |
| Console | sem erros de script ("[Floresta] PRONTA: 25180 tufos, 18 segredos") |

## Observações

- **Saco cheio durante o teste:** o saco encheu (50/50) logo depois da revelação do diário. Com o saco cheio, o corte para e a revelação também. Isso já era assim; só fica o registro.
- **Studio caiu e voltou** uma vez durante os testes. As edições já tinham sido aplicadas e foram conferidas depois.
- **Prévia da relíquia:** o visual de "flor" e "pedra" foi mostrado só no cliente de teste (`Transparency` local), sem revelar no servidor.

## Não testado

- Revelação e coleta de cada um dos 17 segredos (foram testados 2: o diário e o baú da entrada).
- O baú subindo do chão: o diário é relíquia, e o baú da entrada já começa revelado.
- Multiplayer, celular e desempenho com muitos feixes e pistas.
- Cripta subterrânea: feixe curto não verificado visualmente.
