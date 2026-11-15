# Validação — transição Vila → Floresta

**Data:** 2026-11-10 · **IA:** Claude · Play solo PC no Studio. O personagem foi colocado antes do arco pelo servidor (só na sessão de teste), e a travessia foi feita andando (W/S).

| Verificação | Resultado |
|---|---|
| Portal construído | `PlacaPortal` presente, 2 `LanternaPortal`, 210 pedras/flores nas bordas da trilha |
| Placa legível | "FLORESTA ESQUECIDA" (lado da vila) e "VILA" (lado da mata) com `TextBounds` 429×46 e 167×84 (`depois-portal.jpg`) |
| Cartão de região, entrando | "FLORESTA ESQUECIDA" aparece ao cruzar o arco; o card de missão troca para "Floresta Esquecida" (`depois-cartao-regiao.jpg`) |
| Cartão de região, saindo | "VILA" visível ao voltar (`RegiaoAtual=Vila`) |
| Música | trilha Natureza (`rbxassetid://140195397978848`) tocando com volume 1 depois de entrar |
| Aviso antigo do servidor | removido |
| Console | sem erros; o aviso `Infinite yield … FlorestaEsquecida` do `WorldAmbience` não aparece mais |
| Fontes | `RegionTitleCard` `3802/646654913` igual ao repositório; diffs de `GameServer` (−2/+31) e `ForestScenery` (+25) iguais por hash nos dois lados |

## Problemas encontrados durante o teste e corrigidos

1. A placa saiu em duas linhas pequenas → `TextWrapped=false`.
2. Ainda assim, o texto ficava com 8 px: o `SurfaceGui` usava o canvas fixo padrão (800×600). Mudado para `SizingMode=PixelsPerStud`, mas o texto continuou minúsculo com `UIPadding`/`UIStroke`.
3. Adotado o mesmo padrão das placas do `SignKit` (texto em escala, `TextStroke`), e o texto ficou legível.

## Não testado

Celular, ping real, 2 jogadores (o cartão e a música são locais, por jogador).

Capturas de antes: `antes-saida-vila.jpg`, `antes-trilha.jpg`, `antes-portal.jpg`.
