> **Atualização:** a interrupção descrita abaixo foi superada. A cópia atual foi reaberta, alterada e salva na versão 112. A seção final contém os testes mais recentes e as pendências atuais. O relato inicial permanece como histórico.

# Lobby — checkpoint de implementação, 2026-11-12

**Entrega parcial.** Base `ca0ec73`, branch `ai/forest-economy`, place `106412085364108`. Alterações aplicadas diretamente à cópia atual em Edit. O Studio fechou/desconectou durante Play; não foi possível concluir revisão, voltar a Edit ou confirmar novo save. Não foi publicada atualização.

## Evidências visuais

- `antes-aerea.png` e `antes-caminho.png`: imagens reais fornecidas pelo usuário.
- `aerea.png`, `praca.png`, `horta-2.png`, `estufa-2.png`, `floresta-2.png`: capturas reais intermediárias no Studio; não representam todas as correções posteriores.
- `praca-checkpoint.png`: praça após adicionar vasos e estações externas. Posteriormente, pétalas foram ampliadas e placas configuradas com distância ilimitada.
- A base da estufa foi fechada, recebeu degraus e o telhado recebeu caixilhos após `estufa-2.png`; visto diretamente no Studio, mas a captura final não foi exportada antes da desconexão.

Não usar imagens intermediárias como prova de acabamento final. A primeira revisão visual marcou 6/10; foram feitos ajustes posteriores, ainda sem nova avaliação final.

## Verificações executadas

1. Builder em Edit retornou `Ready=true`; última construção inspecionada tinha 2.053 descendentes, incluindo modelos e GUIs.
2. Prévia da floresta regenerada, retornando `PreviewState=Ready`.
3. Uma sessão normal de Play foi iniciada na janela atual, sem teste multiplayer.
4. Servidor confirmou uma única `LobbyGardenReform`, pronta; prévia exclusiva do editor ausente; floresta de runtime presente.
5. Servidor confirmou as bases em `(±48, 0.3, ±48)` e os quatro spawns em `(±48, 4, -27)` / `(±48, 4, 69)`, preservados.
6. Console informou fazenda com 330 quadrados, protótipo com 256 clusters e floresta com 19.674 tufos.

## Limites e próximo teste

- O console emitiu `Infinite yield possible on 'Workspace.GameWorld.FlorestaEsquecida:WaitForChild("CriptaDasRaizes")'` em `WorldAmbience`, linha 9, durante a construção da floresta. Não houve confirmação de que a espera terminou antes da desconexão.
- A consulta ao cliente falhou com `Client datamodel is not available in Edit mode`; depois, a lista de instâncias conectadas ficou vazia. Não afirmar que a animação do moinho passou.
- Não houve novo teste completo de corte, venda, compras, missões, baús ou respawn nesta reforma do lobby. Validações anteriores pertencem aos seus checkpoints.
- Desempenho mobile, persistência e multiplayer continuam pendentes. O usuário fará multiplayer; não abrir múltiplos clientes.
- Novo save e versão final não confirmados. Reabrir a cópia atual, conferir o que permaneceu no Team Create, terminar a revisão e salvar pela ferramenta disponível.

## Preservação

Sem mudanças em preços, saldo, dados, mochilas, inventário, corrida ou animações do personagem. Nenhum comerciante, remote ou interação fictícia foi adicionado. Posições e dimensões das bases dos quatro lotes foram preservadas; mudanças físicas se limitam a decoração, acabamentos e circulação ambiental.

## Retomada — versão 112 salva no Team Create

A experiência reaberta apresentou `PlaceVersion=108`, Terrain revision 21, módulo e cenário de lobby iguais ao checkpoint em disco. A ferramenta de save confirmou sucessivamente versões 110, 111 e **112**; nenhuma publicação foi executada.

### Alterações posteriores

- Passeio externo conecta os quatro jardins, horta, moinho, abrigo de sementes e estufa; pergolados laterais e pomares organizam a periferia.
- Regador-monumento florido, canteiro central maior, quatro paletas de jardins e letreiro central menor.
- Sebes nas duas faces externas de cada lote, flores nas bordas e agrupamentos botânicos maiores.
- Reutilização dos quatro bancos e luminárias originais da praça; os pares decorativos duplicados foram removidos.
- Painéis de missões e ranking preservados e reposicionados nos lados da avenida norte, abrindo a silhueta do monumento.
- Estufa com jardim externo, sebes e bancada; acesso com degraus e base fechada.
- Placas de lote legíveis pelos dois lados, com texto espelhado a partir do original em runtime.
- Antigas bolas decorativas de flores próximas ao lobby ocultadas, com transparência original guardada em atributo; substituição por flores com haste e pétalas. Sem adicionar flora às áreas funcionais dos lotes.
- Decoração de bolas/pedras em cordão na trilha removida de maneira exclusivamente visual por `WorldArt.transition`.

### Verificações reais da retomada

| Verificação | Resultado |
|---|---|
| Lobby e floresta de runtime | Uma instância de cada; `Ready=true` |
| Prévia durante Play | Ausente |
| Quatro bases e spawns | Coordenadas originais conferidas em Play |
| Faces dos letreiros dos quatro lotes | Texto igual em Play |
| Circulação da revisão final | Dez caixas de 3×5×3 studs, centradas a Y=3.5, sem peças colidíveis do novo cenário ou painéis |
| Pontos de circulação | `(0,16)`, `(0,-30)`, `(0,-40)`, `(0,-50)`, `(-30,0)`, `(30,0)`, `(-91,0)`, `(91,0)`, `(-13,-8)`, `(13,-8)` em X/Z |
| Moinho no cliente | Pivô mudou após 0,5 segundo |
| Iluminação regional local | `ForestBiomeLocal` presente no cliente |
| Personagem e LocalScript de ambiente | Presentes no cliente |
| Construção da caverna | `CriptaDasRaizes` presente em runtime |
| Console da primeira sessão completa da retomada | Apenas mensagens normais da fazenda, protótipo e floresta; sem o aviso anterior de espera |
| Stop | Prévia voltou com `PreviewState=Ready`, lobby permaneceu pronto |
| Instâncias do cenário final no editor | 6.926 descendentes; inclui modelos, peças, GUIs e decoração |

O teste de circulação verifica volumes livres; não equivale a uma caminhada manual completa com todas as ferramentas. As transações de comércio não foram repetidas nesta etapa visual. Nenhum teste multiplayer foi iniciado nesta retomada.

### Capturas e limite atual

Imagens `*-v3-focus.png` mostram a composição anterior ao monumento. `*-v4.png` mostram o monumento, entrada sem cordão de bolas, base da estufa e quatro lotes. A avaliação dessas imagens passou de 6 para 6,7 e 6,8/10. A última alteração, com sebes, paisagismo da estufa e painéis reorganizados, ainda não foi capturada nem avaliada.

A captura do Studio passou a expirar após 60 segundos. A integração informa que a janela pode estar oculta, minimizada ou ocupada; não foi possível distinguir a causa. A tentativa de listar/controlar a janela retornou `Could not list computer-use targets.` Não atribuir o problema a permissões específicas sem evidência.

Uma tentativa de medir 120 quadros por `RenderStepped` não avançou e foi encerrada ao parar Play; o benchmark é **inconclusivo**, não é evidência de FPS ruim ou bom. Mobile, persistência e multiplayer continuam pendentes. O usuário foi consultado sobre qual aba está visível para liberar a revisão visual final.
