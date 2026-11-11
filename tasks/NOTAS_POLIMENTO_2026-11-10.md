# Anotações de melhorias — Corte & Descubra

**Registrado em:** 2026-11-10  
**Origem:** pedido direto do usuário no chat.  
**Estado:** **ANOTADO / A FAZER — nenhuma alteração implementada por este registro.**

## Melhorias solicitadas

### 1. Melhorar UI do jogo
- Revisar **HUD de missões**: hierarquia, legibilidade, tamanho, posição e feedback do progresso.
- Melhorar **menu principal**: apresentação, organização, transições e consistência dos painéis.
- Reformular **árvore de habilidades**: layout profissional, clareza dos nós, progressão e conexões, sem mudar a economia de PH sem auditoria.
- Garantir menus sem sobreposições e com adaptação mobile.

### 2. Melhorar transição do mapa
- Tornar a transição vila/pradaria → Floresta Esquecida **orgânica e gradual**.
- Integrar terreno, materiais, relevo, vegetação e densidade de árvores.
- Remover cortes bruscos de bioma e preservar rotas dos jogadores/carrinhos.
- Alinhar com [reforma visual V19](../brain/18_REFORMA_VISUAL_V19_BIOMAS_MONTANHAS.md).

### 3. Melhorar animações
- Revisar animação de personagens e ferramentas, caminhada, corrida e transições de estados.
- **Importante:** havia uma **tarefa de corrida/animações do Claude pausada**. Registrar como pendente; **não retomar nem sobrescrever o trabalho sem alinhamento**.
- Garantir que golpes correspondam ao equipamento e que carrinho tenha postura convincente.

### 4. Melhorar NPCs
- Aprimorar apresentação visual, modelos, poses, expressões, conversas e interação.
- Melhorar posicionamento de bancas, sinalização e feedback das lojas.
- **Preservar** os NPCs, comerciantes, trocas e missão do gnomo Nilo que o usuário relatou estarem prontos na V19; não reimplementar lojas.

### 5. Melhorar cabana e segredos da floresta
- Reformular a **cabana**: arquitetura, integração com vegetação, detalhes e composição.
- Tornar a **exploração mais bonita, satisfatória e surpreendente**.
- Melhorar apresentação, pistas e recompensas de segredos existentes sem revelar tudo automaticamente.
- Integrar com a futura caverna subterrânea e trilhas, preservando o sistema atual de corte/recompensas.

## Regras de execução futura
- Não começar desenvolvimento somente por esta anotação.
- Confirmar a build real publicada (V19 **relatada** pelo usuário) antes de editar.
- Não declarar testes de Play/mobile ou persistência sem evidências.
- Não retomar por conta própria a ideia do jardineiro mencionar floresta no nível 5; ela continua em estacionamento.
- Ao iniciar cada item, criar tarefa técnica/PR e registrar arquivos, testes e handoff.

## Referências
- [Backlog](BACKLOG.md)
- [UI](../brain/08_UI_UX.md)
- [Habilidades](../brain/07_ARVORE_E_HABILIDADES.md)
- [Animações](../brain/04_EQUIPAMENTOS_E_ANIMACOES.md)
- [Floresta](../brain/06_MUNDO_FLORESTA_ESQUECIDA.md)
- [Reforma de mundo V19](../brain/18_REFORMA_VISUAL_V19_BIOMAS_MONTANHAS.md)
