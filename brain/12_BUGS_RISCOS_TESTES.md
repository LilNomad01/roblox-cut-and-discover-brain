# Bugs, riscos, diagnóstico e aceitação

**Regra:** cada bug deve ter `ID`, `build`, `passos para reproduzir`, `resultado observado`, `esperado`, `Output`, `evidência`, `status` e `responsável`. Não marcar resolvido sem Play validado.

## Quadro de regressões

| ID | Severidade | Evidência / problema | Status inicial |
|---|---|---|---|
| `BUG-001` | P0 | Carrinho sumia ao selecionar slot 4; screenshot saco `0/1` | V9 tem correção escrita, **Play pendente** |
| `BUG-002` | P0 | Script V8 do NPC tinha texto Lua quebrado por newline e escopo inadequado; inicialização afetada | V9 relata correção estrutural; **regressão precisa Play** |
| `BUG-003` | P1 | Foice com pegada rígida; animação pouco convincente e ataque anterior duplicava objeto | V9 procedural melhorada, **aprovação visual pendente** |
| `BUG-004` | P1 | Baú visível, não coletável; prompts possivelmente custom invisíveis | Correção escrita; testar E/toque/distância/loot |
| `BUG-005` | P1 | Baú spawnando deitado, pivô mal orientado | Ajustes prévios experimentais; testar todos os 5 modelos |
| `BUG-006` | P1 | Árvore de habilidade, Perfil e Equipamentos sobrepostos | Correções de visibilidade nas cópias, **mobile/Play pendente** |
| `BUG-007` | P1 | Loja e hotbar sobrepostas; menus duplicados abrindo UI errada | Corrigido visualmente segundo o usuário em uma versão, manter em regressão |
| `BUG-008` | P1 | HUD Jardim 0/64 permanecia na floresta | Código contextual inserido em build experimental; validar |
| `BUG-009` | P1 | Floresta parece plantação de pinheiros, vazia e sem atmosfera; usuário não aprovou | **ABERTO — prioridade artística** |
| `BUG-010` | P1 | Persistência `false` no arquivo de referência; progressão perde estado entre sessões | **ABERTO / não ativar sem auditoria** |
| `BUG-011` | P2 | Botão Novo Serviço como overlay simples e invasivo; pedido NPC próximo ao jardim | NPC experimental na V8/V9, validar local e fluxo |
| `BUG-012` | P2 | Barra de ferramentas ocupa tela demais | V9 reduziu ~25%, validar mobile |
| `BUG-013` | P2 | Evolução de ferramentas por raridade modelada, mas sem sistema de compras/save totalmente testado | **PARCIAL/PLANEJADO** |
| `BUG-014` | P2 | Grama em quadrados/muito baixa em alguns protótipos | Cortes orgânicos e visual de Área de Teste ainda precisam unificação |

## Testes de corte e animação

- `1` unha: agachar/cortar somente dentro da janela; XP atribuído no servidor.
- `2` enxada: ferramenta real segue duas mãos e golpe frontal; sem foice fantasma.
- `3` foice: arco lateral real, sem atingir atrás, som/partículas no momento correto.
- `4` carrinho: visível, rodas apoiadas, mãos no guidão, grama cortada pela lâmina ao movimentar.
- Trocar `3→4→2→4`, respawn, lag, caminhar sem atacar, apertar F repetidamente.
- Trator e Mega: verificar se comportamento não é um carrinho soldado ao corpo sem direção própria.

## Testes de UI

- Menu, Config, Habilidades, Equipamentos, Exploração, Missões, Loja, Pets em PC e emulador smartphone.
- No máximo **um** modal principal visível; hotbar oculta durante modal; `Close/Esc` limpa overlay e devolve controle.
- Selecionar habilidade e voltar ao Perfil; nenhum elemento anterior visível por trás.
- Loja amarela compra; aba Equipamentos apenas consulta/equipa, sem cobrança duplicada.
- Texto e botões dentro de safe areas; botão NPC Novo Serviço não tapa personagem.

## Testes de baú/segredos

- Baú fica em pé sobre chão irregular e não flutua.
- Prompt aparece em PC e mobile; `E`/toque abre uma vez.
- Baú previamente revelado não cria recompensa duplicada após reconexão/respawn/corte repetido.
- 5 raridades com prefabs corretos; chance de baú ≠ chance de raridade.

## Testes da floresta

- Entrada contínua sem teleporte abrupto; não interrompe a vila.
- Mato alto usado da Área de Teste; densidades variadas; caminho revela pistas e cabana.
- Segredos funcionam e não são todos visíveis de uma só vez.
- Riacho, ponte e cabana estão conectados ao chão, sem peças soltas.
- FPS estável em dispositivo móvel e 2–4 jogadores.
- Iluminação da floresta não escurece lobby para outros jogadores.

## Critério de fechamento

`VALIDADO_EM_PLAY` somente após verificação no Roblox Studio com pelo menos **vídeo/screenshot/log** e build identificada. `INTEGRADO_NO_RBXL` não significa que está pronto. Registrar data do teste e IDs de commit/asset.
