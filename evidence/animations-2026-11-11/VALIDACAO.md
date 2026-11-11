# Validação — foice e enxada no ombro, toggle de equipar

**Data:** 2026-11-11 · **IA:** Claude · Play solo no PC, no Studio (place `106412085364108`).

## Rodada 2: postura de ombro (versão atual)

O usuário reprovou a postura diagonal da rodada 1 e pediu:

- ferramenta apoiada no ombro, como na foto;
- nada atravessando o corpo;
- apertar o número de novo para tirar o item da mão.

### Método

As colisões foram calculadas por cinemática direta sobre as juntas reais do avatar em Play:

- 31 pontos por quadro (cabo inteiro e lâmina), a cada 0,01 s do clipe;
- comparados contra as caixas do tronco, da cabeça, das coxas, das canelas e do braço esquerdo;
- pontos a menos de 0,7 stud da mão direita foram ignorados (é onde a mão segura).

A comparação "antes" usou o módulo do backup `ServerStorage.SwingClipBackup_20261111`.

### Resultados

| Verificação | Resultado |
|---|---|
| Postura parada (`ombro-foice-segurar.jpg`, `ombro-enxada-segurar.jpg`) | As duas ferramentas ficam no ombro: cabo na diagonal pela frente do peito, lâmina ou cabeça atrás e acima do ombro. Postura aplicada pelo `Animador` real, com diferença de 0,0° em relação à pose do módulo. |
| Enxada: cabo entrando no corpo (> 0,1 stud) | antes: **8 quadros** (t 0,37–0,44, tronco e quadril); agora: **0** |
| Foice: golpe (0,08–0,52 s) | 0 quadros a menos de 0,12 stud do corpo; a folga mínima subiu de 0,37 para 0,72 stud |
| Foice: canelas | 0 quadros (folga mínima de 1,33 stud) |
| Contato na postura parada | o cabo encosta no peito no máximo 0,06 stud (apoio no ombro) |
| Desvio da lâmina na janela de contato | enxada 0,87 stud; foice 0,88 stud em média |
| Corte em Play, grama nova | foice **+4 por golpe** (repetido 2 vezes); enxada **+2** no 1º golpe. Golpes repetidos sem andar caem em grama já cortada. |
| Toggle | sequência 2,2,4,1,1,3,3 → `Enxada, Nenhuma, Cortador, CortadorUnha, Nenhuma, Foice, Nenhuma`. Também testado 4,4 → `Cortador, Nenhuma`. Com a mão vazia: sem ferramenta ou carrinho no personagem e braço em pose normal. |
| Respawn | **Bug anterior encontrado:** depois de renascer, o `Animador` parava de animar (ombro girava no máximo ~7° no golpe). Corrigido na cache de juntas. Depois da correção: postura com 0,0° de diferença e golpe girando o ombro 118°. |
| Console | sem erros de script (aparece só o aviso de asset `R15Anim`, que já existia) |
| Fonte | `AnimFerramentas` 8440/903209127, igual no Studio e no repositório |

### Observações

- **Erro meu no meio da rodada, já corrigido:** a primeira edição do `Animador` deixou um `local` solto e o script não compilou (sumiu a barra 1–4). Corrigido e revalidado no Play seguinte.
- Durante os testes, o saco pulou de 4 para 40 numa leitura isolada, logo depois de um teleporte pelo servidor. **Não se repetiu** em 3 medições com registro de cada mudança (sempre +4 com a foice). Fica anotado e não investigado.
- Durante os testes, uma vez a tecla 4 equipou a foice. **Não se repetiu** em duas sequências completas. Pode ter sido a entrada simulada da ferramenta de teste.
- O `Saco` foi zerado pelo servidor durante o teste, só em Play (nada salvo; a persistência continua desligada).

### Não testado

- vídeo do golpe completo;
- celular e controle;
- multiplayer (outros jogadores vendo a postura);
- outros tipos de corpo de avatar;
- a foto da mão vazia.

## Rodada 1: postura diagonal (substituída)

A ferramenta ficava na diagonal com a lâmina rente ao chão (`depois-*.jpg`; antes: `antes-*.jpg`). A janela de contato ficou idêntica: diferença 0 em 6.029 amostras. O usuário reprovou essa postura.
