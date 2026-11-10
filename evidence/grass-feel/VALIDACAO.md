# Densidade e feedback de corte — 2026-11-10

Base: `441fa2a`, branch `ai/forest-economy`, place `106412085364108`. Escopo: somente `StarterPlayer.StarterPlayerScripts.ForestGrassClient`. Nenhuma alteração de economia, velocidade, lâmina ou autoridade de corte do servidor.

## Alterações

Tufos próximos com largura/profundidade multiplicadas por 1,28: aproximadamente 64% mais área de sobreposição visual por malha, não 64% mais instâncias. Altura mínima de 0,95 nas manchas normais; fatores abaixo de 0,65 permanecem para preservar vegetação baixa de caminhos e clareiras. Cobertura distante passa de 1,65 para 1,95 na largura. Cores mais verdes, folhas cortadas maiores, transição Cubic Out de 0,23 s e som Corte existente, limitado a uma chamada a cada 0,12 s. Efeitos continuam limitados a 30 folhas simultâneas, com remoção automática.

O visual continua reagindo somente aos estados recebidos do servidor. O primeiro corte e o acabamento mantêm suas regras anteriores; som e partículas não concedem recompensas. Não foram adicionados assets externos nem IDs novos.

## Validação executada

- Fonte compilada pelo Luau oficial 0.746.
- Play iniciou sem erro de execução do jogo no console consultado.
- Visual inspecionado em Play: `matagal-denso.png`.
- Teste pela rota existente `GameServerGanchos.CortarPorLamina`, dentro de Script normal: `Cuts=1`, `SackGain=1`, `NoExtraReward=true` na segunda passada.
- Verificadas 1.501 peças locais sem colisão, toque ou consulta física na posição observada. Nenhuma folha temporária permaneceu nessa leitura após a limpeza.
- Inicialização: 25.197 tufos lógicos, mesma quantidade da versão anterior. Nenhum tufo lógico novo.

A primeira captura foi feita enquanto a floresta ainda carregava e não foi usada como resultado. A captura entregue foi feita após o log PRONTA.

## Limitações e rollback

Desempenho em celular real e avaliação auditiva pelo usuário continuam pendentes. Não foi gravado vídeo para avaliar movimento contínuo. O escopo desta mudança é a floresta; a área de teste da referência permanece intacta.

Original em `ServerStorage.GrassFeelBackup_20261110`, desativado. Para rollback em Edit, restaure seu Source em `StarterPlayer.StarterPlayerScripts.ForestGrassClient`. Os dados do teste foram descartados ao parar Play. O place precisa ser salvo pelo usuário no Studio; nenhuma publicação foi feita.
