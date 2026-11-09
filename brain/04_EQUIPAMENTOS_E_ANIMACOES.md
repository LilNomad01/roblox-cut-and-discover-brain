# Equipamentos, montagem, animações e game feel

## Filosofia

**Quem corta a grama é a lâmina da ferramenta.** O corpo, o `HumanoidRootPart`, os pés ou a posição do jogador não devem, por si só, limpar vegetação. Ferramentas manuais usam golpe/janela de contato; máquinas cortam continuamente ao avançar.

## Slots e kit na V9

1. **UNHA** — cortador de unha comum, curto alcance, ato absurdo/divertido.
2. **ENXADA** — golpe frontal descendente com duas mãos.
3. **FOICE** — varredura lateral ampla com mãos na haste.
4. **CARRINHO** — modelo real na frente, empurrado com as mãos no guidão; máquina acompanha compras.

`F`/clique para manuais, números 1–4 para troca, toque para mobile; checar conflito com atalhos de outras ferramentas e habilidades. Não duplicar equipamento ao atacar.

## Configuração observada em `FerramentasConfig`

| Ferramenta | Duração | Janela de contato | Cooldown | Alcance | Largura | MaxTiles por ataque |
|---|---:|---:|---:|---:|---:|---:|
| Cortador de unha | 0,80 s | 0,34–0,45 | 0,85 s | 4,5 studs | 0,9 | 1 |
| Enxada | 0,82 s | 0,32–0,43 | 0,86 s | 7,5 studs | 2,2 | 2 |
| Foice | 0,72 s | 0,22–0,48 | 0,76 s | 8,5 studs | 1,6 | 4 |

Atributos são da **cópia V9** e não foram balanceados em Play. Confirmar se os servidores realmente usam essas configurações e não rotas antigas.

## Animações-alvo por timeline (60 FPS conceitual)

### UNHA — 0,80 s

- `0,00–0,20`: inclinação/agachamento (Ease In Out; influência ~35–40%).
- `0,20–0,34`: preparar mão junto à grama (Cubic In).
- `0,34–0,45`: pequeno clique/corte e VFX no contato.
- `0,45–0,80`: recuperar postura (Cubic Out; influência ~70%).
- Idle: postura relaxada/engraçada; não segurar objeto do tamanho de enxada.

### ENXADA — 0,82 s

- `0,00–0,20`: erguer haste, girar ombro e inclinar tronco (Ease InOut ~40%).
- `0,20–0,39`: golpe descendente acelerado (Cubic In).
- `0,32–0,43`: lâmina encontra vegetação, validar área varrida.
- `0,43–0,82`: follow-through curto e retorno (Cubic Out ~70%).
- A segunda mão deve permanecer na haste, sem IK em conflito com AnimationTracks.

### FOICE — 0,72 s

- `0,00–0,14`: antecipação; peso na perna contrária, ombros giram (Ease InOut ~40%).
- `0,14–0,30`: início da varredura lateral, acelerando (Cubic In).
- `0,30–0,46`: arco principal com rastro curtíssimo da lâmina; desaceleração orgânica.
- `0,46–0,72`: follow-through, leve recoil e retorno (Cubic Out 65–75%).
- Não usar um círculo 360º para golpe frontal comum; somente `CUT_SPIN` habilita giro próprio.

### CARRINHO — contínuo

- Pose de entrada `0,25 s`, Ease In Out; mãos no `Guidao`/`Grip`, braços estendidos.
- Idle parado: mãos apoiadas, respiração discreta, rodas paradas.
- Walk empurrando: passos sincronizados à velocidade, rodas girando, corpo 5–10° inclinado, microbalanço da máquina.
- Saída `0,20 s`, Cubic Out. Não usar animação de arma manual com carrinho equipado.
- Validar `PrimaryPart`, `Pivot`, `Motor6D`/`WeldConstraint`, collision groups, peças `Anchored`, replicação e respawn.

## Visual/audio feedback

- Curto `whoosh` de foice, impacto ao contato real, um pouco de aparas verdes, animação da grama `TALL→SHORT` em ~0,10–0,22 s e `SHORT→STUBBLE` ~0,08–0,16 s.
- Evitar um som a cada folha; agregar por golpe/faixa.
- Sem `SoundId`/`AnimationId` inventados. Solicitar importação/publicação quando preciso.

## Problemas conhecidos

- Foice apareceu segurada de modo rígido/horizontal em screenshot.
- Carrinho sumiu na V8; seleção de slot mostrava saco `0/1`; V9 reporta correção de inicialização, fallback e IK, **sem Play validado**.
- Protótipo antigo `FoicePlaceholder` duplicava ferramenta ao pressionar `F`; deve permanecer desativado/removido após auditar o código atual.
- Se o avatar for R6, animações R15 procedurais precisam fallback apropriado.
- Todos os slots e animações precisam persistir coerentemente durante troca, respawn, lag e mobile.

## Critérios de aceite

- A enxada segura em duas mãos e realmente desce ao contato.
- Foice percorre arco frente/lateral, sem cortar atrás ou ao caminhar sem comando.
- Carrinho aparece sempre que equipado, avança à frente do jogador, mãos no guidão, corta pela lâmina.
- Só um modelo visual equipado; sem ataque fantasma ou resets bruscos.
- PC, celular e outro jogador veem a pose correta.
