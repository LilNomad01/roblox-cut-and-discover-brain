# V19 — Reforma de biomas, montanhas, riacho, placas e cavernas

**2026-11-10 — PLANEJADO, NÃO IMPLEMENTADO por este registro.** [Issue #8](https://github.com/LilNomad01/roblox-cut-and-discover-brain/issues/8).

## Estado relatado pelo usuário — preservar
Usuário afirma que o jogo Roblox foi publicado na **versão 19**, com testes em Studio e commits GitHub, incluindo: comerciantes e lojas/trocas/quest de Nilo; mochilas de capacidade; caçambas de venda; matagal mais denso/verde; grama cortada com som/folhas/transição; prévia da floresta no editor sem duplicar no Play. **Relato do usuário não equivale a verificação independente desta IA.**

**Não refazer** esses recursos. **Corrida/animação do Claude continua pausada.** Mobile e persistência entre sessões seguem pendentes. Não implementar ideia reservada do jardineiro no nível 5.

## Diagnóstico visual
1. Transição entre a vila ensolarada e a floresta escura está abrupta — parece fronteira rígida.
2. Montanhas parecem morros verdes com pedras cinzentas em domos/esferas pousadas no topo, repetitivos.
3. Riacho é faixa azul reta com junções transversais, parecendo passarela.
4. Placas verdes simples, texto branco e plantas sobrepostas; placa de Teca encobre NPC.
5. Caverna atual parece pedras arredondadas empilhadas com grade.
6. Pedida uma nova caverna **realmente subterrânea escondida sob grama alta cortável**.

## 1 — Transição de biomas, orgânica e contínua
- Fazer zona de transição de largura proporcional ao mapa, com bordas curvas, **sem linhas retas**.
- Sequência natural: gramado baixo da vila → campos com grama de alturas mistas → arbustos e árvores espaçadas → samambaias/moitas/folhagem → floresta profunda com matagal alto.
- Trabalhar materiais Terrain por manchas e meandros: grama clara, terra, folhas, musgo, cascalho, raízes e pedra.
- Usar pequenas elevações, trilha sinuosa e grupos de árvores progressivamente mais densos.
- Iluminação e sons **locais**, não alterar luz global para todos os jogadores.
- Preservar caminhos e acesso do carrinho; ocultação de segredos não pode bloquear câmera/controles.

## 2 — Montanhas e limites
- Remover formas repetitivas de hemisfério de rocha sobre morros lisos.
- Criar cumes assimétricos, escarpas, estratos, faces rochosas integradas ao terreno e cristas de alturas diferentes.
- Intercalar afloramentos, ledges com gramado, pequenas árvores, rochas secundárias, musgo e rachaduras discretas.
- Misturar Roblox Terrain esculpido e meshes modulares quando necessário, sem emendas nem impacto alto em mobile.
- Criar composição do vale que enquadre **os quatro lotes** e direcione o olhar às trilhas, sem esconder lobby, lojas ou spawns.
- Adicionar profundidade atmosférica moderada, sem céu plano e nem montanha repetida por cópia.
- Não alterar área central ou caves sem backup e sem verificar colisão/acessos.

## 3 — Riacho
- Substituir Parts retangulares azuis por leito de água sinuoso com margens orgânicas, largura e profundidade variáveis.
- Priorizar Terrain Water ou meshes de água conectadas, sem costuras; pedras molhadas, fundo legível, vegetação ribeirinha, pequena ponte se apropriado.
- Correnteza visual Linear e ondulações Sine Ease In Out suaves, sem faixas de repetição evidentes.
- Testar passagem a pé/carrinho, colisões, FPS e iluminação.

## 4 — Placas / comerciantes
- Kit modular de madeira, com peças irregulares estilizadas, ícones, sinalização direcional e banca separada.
- Corrigir placa de **Teca, a Botânica**, que encobre personagem; reposicionar placa, banca e vegetação.
- Melhorar placa de **DEPÓSITO DANIFICADO**, sem fingir interação que não exista.
- Texto legível PC/celular, contraste, orientação e posicionamento sem clipping.

## 5 — Caverna atual
- Substituir pilha de pedras redondas por abertura assimétrica integrada à encosta, com tetos/rochas irregulares, musgo, raízes, sombras e fundo realmente navegável.
- Grade ou portão só quando houver mecânica real; evitar textura preta simulando caverna.

## 6 — Nova caverna subterrânea descoberta cortando grama
- Local fora da trilha, **entrada debaixo de tufos de matagal**, não apenas atrás de plantas.
- Criar pistas ambientais discretas (pedra, cogumelo, vento, sons).
- Associar 10–15 tufos cortáveis relevantes, quantidade calibrável; contabilizar corte **local** autorizado pelo servidor, sem contador geral.
- Revelar rampa/abertura e passagem **real abaixo do terreno**; animação curta de folhas/poeira, sem bloquear jogador.
- Interior com 3 espaços: descida com raízes, túnel com pequena escolha, câmara secreta com baú/colecionável funcionais.
- Evitar quedas no vazio, jogador preso, duplicação de recompensa; distinguir desbloqueio compartilhado e recompensa única por jogador.
- Construir/posicionar cavernas só após estabilizar relevo e limites.

## Ordem recomendada
1. Confirmar baseline Roblox **V19** no Studio (atualmente relato do usuário) e criar backup.
2. Reformular relevo e montanhas + transição de biomas.
3. Refazer riacho.
4. Renovar placas sem mexer nas funcionalidades das lojas/NPCs.
5. Refazer caverna visível.
6. Construir caverna subterrânea e associar com matagal existente.
7. QA: screenshot antes/depois dos mesmos ângulos; Play em multiplayer; não quebrar grama, vendas, mochilas, quests, preview editor; documentar celular e save ainda pendentes.
8. Atualizar BRAIN com o que foi implementado e o que foi realmente testado.

**Critério de aceite:** mundo estilizado com limites naturais, montanhas integradas, água sem faixas azuis, sinalização legível e uma descoberta subterrânea verdadeira, sem regressões de sistemas já feitos.
