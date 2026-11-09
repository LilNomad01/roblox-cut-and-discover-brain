# Baús, raridades, segredos, itens e coleta

## Assets existentes

ZIP `Entrega4_Itens.zip` inclui:

- **5 baús**: Comum, Incomum, Raro, Lendário, Mitológico (`.fbx` e cenas renderizadas).
- **5 máquinas**: Básico, Elétrico, Turbo, Trator, Mega (`.fbx`).
- **15 ferramentas manuais** (unha/enxada/foice × 5 raridades).

A V9 contém os cinco nomes de baú em modelos dentro do `.rbxl`; isso confirma presença, não funcionamento do prompt/loot.

## Raridade do baú — proposta aprovada

- **Comum: 60%**
- **Incomum: 25%**
- **Raro: 10%**
- **Lendário: 4%**
- **Mitológico: 1%**

**Essa é a distribuição CONDICIONAL ao sortear a raridade de um baú já gerado.** **Não** significa 60% de chance de baú comum em cada tufo cortado. Probabilidade de spawn e seleção de raridade são processos independentes. Combinar descobertas posicionadas à mão com drops ocasionais bem limitados.

## Fluxo alvo de baú

1. Mundo/servidor cria baú em local válido ou objeto secreto pré-posicionado está oculto.
2. O jogador corta os tufos que realmente o encobrem, ou acha pista.
3. Servidor registra descoberta individual (sem vazar outros secrets).
4. Baú emerge/revela com VFX curto, **em pé, apoiado no chão**.
5. ProximityPrompt deve ser perceptível no PC e touch/mobile; colocar âncora acima do baú, com linha de visão apropriada.
6. Servidor valida distância, jogador, direito, estado, loot e frequência; marca coletado de modo idempotente.
7. Animação de tampa, luz de raridade, som, feedback do item/moedas.
8. Atualizar inventário/PH/XP conforme tabela autorizada; persistir quando save ativo.

**Falha relatada:** baú visível que jogador não conseguia pegar. V8/V9 tentaram mover prompts, aumentar raio e corrigir `Style=Custom` sem UI custom; **testar in-game**. Modelos importados já tiveram problema de spawn deitado; verificar pivô e orientation `CFrame`.

## Segredos intencionais, não só sorte

- Caminho camuflado que revela uma placa, depois uma clareira.
- Tronco oco com moeda/item raro.
- Riacho que conduz a ponte quebrada.
- Pedra com símbolo vista após limpar matagal.
- Baú semioculto nas raízes de árvore antiga.
- Objetos antigos da missão de Zeca (3 itens), com ids únicos por jogador.
- Pedestal/artefato na clareira secreta.

Mínimo MVP útil: 3 segredos diferentes, um baú interativo por raridade básica, uma trilha revelável e uma cena de descoberta da cabana. Não espalhar tesouros flutuantes ao acaso.

## Regras de loot a definir

- Chance de spawn de baú por corte (baixa, calibrada por tempo de sessão).
- Tabelas de recompensas por raridade, com limites de recursos.
- Respawn por jogador/servidor e persistência.
- Se recompensas de grupo serão por participação ou individualmente.
- Como valores raros influenciam economia e PH (evitar power creep).

Até definição, usar defaults conservadores em ambiente de teste, não fabricar chance/probabilidade como regra aprovada.
