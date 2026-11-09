# Histórico de decisões e experiências

Este registro resume a conversa em vez de afirmar que cada passo foi publicado.

## 2026-11-03 a 2026-11-04 — Assets e sistemas iniciais

- Desenvolvimento de `Entrega4_Itens.zip`: modelos FBX de 5 baús, 5 cortadores e 15 ferramentas manuais.
- Desenvolvimento do `CorteDescubra_GrassPack.zip`: grama TALL/SHORT/STUBBLE, LODs e Blender.
- Ideias de progressão por raridade e sistema de baús foram definidas.

## 2026-11-08 / 09 — Interface e progressão

- Evolução visual de menu do jogador, Perfil, Habilidades, Equipamentos, Exploração, Missões e Config.
- Referência de árvore hexagonal; 19 nós com cinco ramos. Alguns nós ganharam comportamento em código; outros continuam Planned.
- Usuário identificou sobreposição de UI, Loja duplicada, bugs de Config e selecionou a **Loja amarela externa** como única loja principal.
- Propostas de prompts para Claude/Codex, ajustes diretos em `.rbxl` de teste.

## Experimentos `.rbxl`

- V1: primeira montagem de floresta separada; muito provisória.
- V2: corte pela lâmina/carrinho e export cabana; Play não executado aqui.
- V3: correção de formas erradas de Parts que apareciam como esferas; matagal precisava refinamento.
- V4: ferramentas manuais/novas árvores.
- V5: HUD e tentativa de correção de animação duplicada.
- **Usuário pediu para desconsiderar V1–V5 e voltar à origem com Claude.** Esta decisão continua importante: não reutilizar esses scripts como base sem autorização.
- Depois, usuário enviou `backup - cópia 2.rbxl`; a partir dela vieram correções UI e builds V6–V9, todas experimentais.
- V6: loja, baús, árvore.
- V7: floresta gerada no Play, baús/segredos, integração no corte.
- V8: NPC do serviço, novos cortadores e prompts; bug de inicialização/sintaxe detectado depois.
- V9: correções de sintaxe do NPC, carrinho, IK, foice procedural e hotbar ~25% menor. **Apenas integridade/arquivo; Play não comprovado**.

## Feedback artístico mais recente

- Usuário mostrou floresta com **pinheiros geométricos idênticos em espaçamento regular e cabana distante**.
- Avaliação acordada: cenário ainda sem direção artística; precisa layout por setores, árvores de silhuetas diferentes, sub-bosque e caminhos curvos.
- Novo prompt de reformulação visual enviado ao Claude, mas o arquivo/resultado posterior ainda não foi analisado como código.

## Decisões que NÃO devemos perder

1. Nome/conceito principal é **Corte & Descubra**, não “Puxe as Ilhas”.
2. O diferencial é exploração e restauração escondida sob o mato, não grama por grama apenas para moedas.
3. **Aparência do matagal da Área de Teste** agrada ao usuário; usar como guia visual da floresta.
4. **Blender para assets modulares; Roblox Studio para montagem e gameplay**.
5. Loja amarela externa prevalece; Equipamentos é inventário.
6. Nunca deixar ferramentas cortar só pelos pés/corpo.
7. Foice deve ter animação real de ceifar, carrinho empurrado pelo guidão.
8. Árvore tem de liberar mecânicas funcionais, com PH reais, e se conectar ao mapa de descoberta.
9. Versões descartadas não devem ser reintroduzidas sem comparação e autorização.
10. Não alegar save ou testes concluídos sem prova.
