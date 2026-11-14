# 21 — Referências: HUD e arte (pesquisa de 2026-11-12)

Pesquisa web feita por um agente do Claude, a pedido do usuário: "faça pesquisas de como as coisas são na vida real e como jogos normalmente costumam retratar".

**[rec.]** marca recomendação ou cálculo, sem fonte. Os links estão no fim de cada seção.

## Escala

- **1 stud = 0,28 m** (página oficial de unidades da Roblox). O personagem padrão tem ~5 studs (≈1,4 m, altura de criança).
- **[rec.]** Objetos de mão (ferramentas, cerca, poço) em escala real ×1,0–1,2. Veículos e prédios em ×0,6–0,8, para caber no lote e ficar cartunesco.

Fontes:
- https://create.roblox.com/docs/physics/units
- https://devforum.roblox.com/t/understanding-roblox-physics-and-their-conversions-to-real-units/1847678

## HUD

- **Barra do topo:** 58 px desde as novas experience controls. Leia `GuiService.TopbarInset` em vez de fixar o valor. `GetGuiInset()` pode devolver 0 nos primeiros frames.
- **Mobile:** o thumbstick fica no canto inferior esquerdo e o pulo no inferior direito. Não ponha botões nessas zonas.
- **Toque:** alvo mínimo de 44–48 px. Grade de 8 (componentes) e de 4 (texto e ícones).
- **Contraste:** 4,5:1 para texto normal e 3:1 para texto grande, ícones e bordas.
- **Feedback:** apertar = escala ~0,92 em 80–120 ms; hover ~+10% com easing Back. Escale só o visual, não a área de toque.
- **"Premium":** um único conjunto de ícones, um raio de canto, uma receita de profundidade (contorno + degradê + sombra), uma cor por função, números abreviados e selo de notificação no canto superior direito.
- **Roblox:** UIScale para escalar o HUD inteiro; um contêiner por lado com AnchorPoint; UIListLayout ou UIGridLayout; 9-slice nos fundos repetidos (é mais barato que UICorner).
- **Não achado:** breakdown oficial do HUD de Pet Simulator 99, Bee Swarm ou Grow a Garden.

Fontes:
- https://devforum.roblox.com/t/studio-beta-for-experience-controls-available-now/2567355
- https://create.roblox.com/docs/ui/cross-platform-design
- https://m1.material.io/layout/metrics-keylines.html
- https://webaim.org/articles/contrast/
- https://create.roblox.com/docs/ui/size-modifiers
- https://create.roblox.com/docs/ui/9-slice

## Objetos (medidas reais → studs)

| Objeto | Real | Studs | Notas |
|---|---|---|---|
| Cortador de empurrar 21" (Toro 21311) | 143 × 57 × 103 cm | 5,1 × 2,0 × 3,7 | roda traseira maior (11–12") que a dianteira (7–8"); guidão ~45° [rec.] |
| Trator cortador (deck 42") | ~1,8 × 1,2 × 1,2 m | 6,3–6,8 × 4,4–4,6 × 4,0–4,6 | |
| Trator compacto (JD 3025E) | ROPS 2,42 m | 8,6 de altura | pneu traseiro ~1,6× o dianteiro (tração atrás, direção na frente) |
| Colheitadeira pequena (Yanmar AW70GW) | 5,03 × 2,29 × 2,9 m | 18 × 8 × 10 | estilizada [rec.]: plataforma (molinete) na frente, cabine alta, tanque no topo, tubo de descarga lateral |
| Enxada | cabo 137 cm, lâmina 16 × 13 cm | cabo 4,9 | [rec.] cabo 4 e lâmina 1 (lâmina ampliada para leitura) |
| Gadanha (foice de cabo longo) | cabo 140–165 cm, lâmina 50–80 cm | 5–5,9 / 1,8–2,9 | lâmina quase em ângulo reto com o cabo |
| Cortador de unha | 6–7 × 1,5 cm | — | a piada pede uma versão gigante (~2–2,5 studs) |
| Celeiro vermelho | — | [rec.] 24 × 30 × 22 | telhado **gambrel** (duas águas quebradas), vermelho óxido, **acabamento branco**, **"X" nas portas**, porta do palheiro no frontão |
| Fardo pequeno (retangular) | 36 × 46 × 61–91 cm | 1,3 × 1,6 × 2,2–3,3 | |
| Fardo redondo 4×5 | 1,2 m de largura × 1,5 m de diâmetro | 4,4 × 5,4 | |
| Poço de pedra | mureta de 0,9 m, total 1,7–2,7 m | 3,3 / 6–9,7 | telhado de duas águas, sarilho com corrente |
| Cerca rural de 3 trilhos | postes a cada 2,4 m, altura 1,2 m | 8,7 / 4,4 | 3 trilhos a ~1 stud um do outro; postes de 0,45–0,7 |
| Caçamba (8 jardas) | topo 3,4 m, fundo 2,24 m, L 1,66 m, A 1,3 m | 12 / 8 / 5,9 / 4,6 | **laterais inclinadas** |
| Cabana de toras | toras de 20–25 cm | 0,7–0,9 | [rec.] toras de 1–1,2 com pontas saindo 0,6 nos cantos |
| Baú de tesouro | — | [rec.] 2,5 × 1,6 × 1,6 | tampa arqueada, cintas de metal |

**Estilizado em geral:** proporções "chunky", silhueta forte, detalhe seletivo, poucas texturas e consistência entre os objetos (não misturar estilos).

Fontes:
- https://www.toro.com/en/product/21311
- https://www.tractordata.com/farm-tractors/009/1/0/9102-john-deere-3025e-dimensions.html
- https://www.yanmar.com/in/agri/products/combine_harvester/aw70gw/spec.html
- https://sensenwerk.de/en/scythe-knowledge/the-scythe-snath/
- https://almanac.com/extra/evolution-american-barn
- https://ohioline.osu.edu/factsheet/anr-0223
- https://machinefinderaws.deere.com/ww/en-CA/faq/hay-bale-dimensions
- https://www.dimensions.com/element/farm-fence-3-rail
- https://www.mickgeorge.co.uk/8-yard-skip-dimensions
- https://www.tuin.co.uk/blog/measurements-of-log-cabins/
