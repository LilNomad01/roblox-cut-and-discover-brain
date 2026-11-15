# Comerciantes, caçambas, mochilas e gnomo secreto — Floresta Esquecida

> **Atualização 2026-11-10:** o Codex implementou este escopo na place de trabalho `106412085364108`. As mecânicas passaram em 48 verificações de Play e 50 asserções de regras. Ver `evidence/forest-economy/VALIDACAO.md` e o código em `game/forest-economy/`. Pendentes: toque/controle real, multiplayer, desempenho móvel e persistência (desligada). O texto abaixo é a especificação original.

**Estado original: PLANEJADO em 2026-11-10.** Solicitação de game design aprovada como direção. **Não é feature implementada nem testada.** Relacionado à [Issue #6](https://github.com/LilNomad01/roblox-cut-and-discover-brain/issues/6). Confirmar baseline real, sem usar cópias experimentais automaticamente.

## Objetivo de game design

A floresta deixa de ser uma área só para cortar mato e passa a ter **expedições sustentáveis**: vender grama sem voltar à vila, comprar capacidade e ferramentas de exploração, trocar materiais, encontrar NPCs e revelar comércio secreto. O comércio não pode substituir a descoberta; localizações dos segredos devem ser ocultadas gradualmente.

### Quatro NPCs distintos

| NPC | Local | Função | Primeiro recurso implementável |
|---|---|---|---|
| **Guto, o Mochileiro** | Entrada, acesso fácil | Mochilas e capacidade | Upgrade funcional de saco |
| **Lia, a Exploradora** | Acampamento intermediário | Lanterna, bússola, marcadores de trilha | Lanterna ou item de navegação realmente funcional |
| **Teca, a Botânica** | Clareira da cabana | Compra/troca de materiais encontrados | Contrato de flor rara com recompensa única |
| **Nilo, o Gnomo Colecionador** | Oculto pela mata alta | Loja secreta com relíquias, pistas, cosméticos | Pista da caverna e troca de colecionáveis |

**Arte:** estilo low-poly cartoon orgânico; modelar no Blender, se não houver asset existente, com glb individual, escala/pivô coerentes e importação Roblox. Cada NPC precisa de uma silhueta e uma banca simples; Nilo pequeno com chapéu exagerado, barba e mochila. **Não criar NPCs com diálogos, produtos ou ações fingidas.**

### Caçambas de venda

**Três locais:** entrada/Guto; acampamento/Lia; perto da cabana/Teca (terceira danificada, reparável por missão). Reaproveitar serviço/transação do **ponto de venda já existente no lobby**, não duplicar economia. Validar no servidor o jogador, distância, grama real, preço, idempotência e bloqueio de venda simultânea. Não recompensar duas vezes pelo mesmo lote de grama nem gerar XP de corte na venda. Feedback UI 0,35–0,5 s Cubic Ease Out, som autorizado, nunca inventar SoundId.

### Mochilas e aumento de capacidade

**Cuidado:** equipamento/cortador já possui capacidade de saco (ex.: básico 50). Auditar `Saco`, `SacoMax`, equip e persistência antes de adicionar.

| Nível de mochila | Bônus adicional | Preço sugerido |
|---|---:|---:|
| Pano | +25 | 250 |
| Reforçada | +75 | 900 |
| Couro | +180 | 3.200 |
| Explorador | +450 | 11.000 |
| Encantada | +1.000 | 38.000 |

**Preços não calibrados.** Regra desejada: `SacoMax = capacidade_base_equipamento + bonus_maior_mochila_comprada`, **nunca** somar bônus históricos, multiplicar a cada equip ou permitir manipulação via cliente. Ao equipar item de menor capacidade, manter grama atual, bloquear acréscimo até vender abaixo da nova capacidade; decidir UI para indicar excedente. Upgrade persistente somente com DataStore auditado; `PersistenceEnabled=false` foi observado em uma configuração da V9. Modelos visíveis nas costas em 5 estágios, mas sem colisão ou clipping grave; pode ocultar visual ao conduzir máquina se necessário, sem retirar o bônus.

### Itens úteis de Lia e Teca

Lia: lanterna portátil, bússola de pontos **já conhecidos**, marcador de trilha e kit consumível de pistas com duração/cooldown. Teca: vender flores/ervas raras, contratos de coleta, sementes para restauração futura. Cada item comprável precisa de lógica real; não competir de maneira injusta com Detector de Tesouros e Cartógrafo. Não colocar botões de venda em outros lugares da UI fingindo serem novos serviços.

### Loja secreta do gnomo e caverna

Nilo fica **atrás de matagal alto cortável** e só pode ser interagido quando descoberto. Loja exclusiva de trocas com relíquias, cogumelos, fragmentos de mapa e cosméticos. Primeiro encontro dá pista curta sobre a caverna; não revelar automaticamente posição nem recompensa. Dar um pequeno contrato exclusivo e progressão sem grind abusivo. Progresso e recompensas únicas validados no servidor e registrados por player.

### UI e fluxo de descoberta

Usar design system original (botões coloridos, contornos escuros, cantos arredondados, ícones claros). Cada NPC tem loja única por identidade cromática: Guto verde/amarelo, Lia azul/laranja, Teca verde/lilás, Nilo roxo/dourado. Uma janela por vez, fechar por X/Esc/mobile, com preço, saldo, capacidade atual/seguinte, estado COMPRADO/EQUIPADO e confirmação de compra. Não criar uma segunda loja geral duplicando o botão amarelo da vila.

**Jornada:** vila → Guto (capacidade) → caçamba da entrada → matagal e trilha → acampamento de Lia + caçamba → cabana/Teca + depósito reparável → caminho lateral → descoberta de Nilo → pista de caverna + novas trocas.

### Requisitos técnicos e critérios de aceite

1. Confirmar baseline oficial, configurar catálogo e tipos de produto por módulo (sem valores hardcoded em múltiplos scripts).
2. Integrar economia de compra/venda existente e dados do inventário; validar servidor e prevenir double-spend.
3. Capacidade aplicada uma vez; teste de compra, troca de equipamento, respawn e reconexão (se save ativado).
4. Vendas em 3 caçambas; comparar cotação com vila e quantidade debitada.
5. Ao menos **1 produto funcional de Lia e 1 contrato funcional de Teca**; lojas futuras inativas devem explicar pré-requisitos, não consumir moedas.
6. Nilo aparece visualmente somente após corte suficiente e não permite compras antes da descoberta.
7. Testar proximidade/interação por teclado, mobile e gamepad; performance mobile.
8. Enviar screenshots/vídeos e log de Play; atualização do BRAIN deve distinguir IMPLEMENTADO_NAO_PLAYTESTADO de VALIDADO_EM_PLAY.

**Dependências:** [Mundo](06_MUNDO_FLORESTA_ESQUECIDA.md), [Economia](03_PROGRESSAO_E_ECONOMIA.md), [Baús](09_BAUS_ITENS_E_DESCOBERTAS.md), [Arquitetura](10_ARQUITETURA_E_DADOS.md), [Issue #6](https://github.com/LilNomad01/roblox-cut-and-discover-brain/issues/6).
