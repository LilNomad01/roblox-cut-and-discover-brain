# Visão, diferenciação e princípios de design

## Conceito

**Corte & Descubra** é um jogo Roblox que parte da linguagem simples dos simuladores de cortar grama, mas transforma o ato de cortar em ferramenta de **exploração e descoberta**. Um terreno tomado pelo mato pode esconder uma estrada, uma cabana, símbolos, uma passagem, um baú ou uma missão de restauração. O mundo reage visualmente à limpeza.

Pilares:

1. **Satisfação imediata:** animações, som, partículas, trilha aberta e progresso visível a cada sessão.
2. **Progressão sentida:** ferramentas alteram o gesto, a largura, o alcance e o estilo do corte, não só multiplicadores.
3. **Curiosidade:** cada massa de matagal é uma promessa de algo a revelar; sinais discretos para curiosos.
4. **Mundo que melhora:** lugares abandonados podem tornar-se jardins, pontes e oficinas restauradas.
5. **Cooperação respeitosa:** mundo público compartilhado, recompensas e descobertas individuais confiáveis.
6. **Acessibilidade mobile:** legibilidade, FPS, botões tocáveis, controles simples e curtas sessões.

## Loop detalhado

- **Entrada (0–3 min desejados):** jogador aprende a cortar, usa ferramenta inicial divertida, recebe moedas e vê a vantagem da próxima ferramenta.
- **Lote privado:** cortar grama/serviço, saco limitado, vender na caçamba, adquirir equipamento.
- **Exploração:** mata alta dificulta a visão; ferramenta abre trilhas; descobrir marcos dá história/recompensa.
- **Habilidades:** PH ganho em marcos de nível; unlock de mecânicas (Corte Rente, Detector, Drone etc.).
- **Transformação:** reconstruir cabana/ponte com materiais e missões; mostrar antes/depois.
- **Retorno:** diferentes subáreas, objetivos curtos, materiais, segredos e futuras regiões.

## Direção estética

- **Lobby/vila:** verde alegre, ensolarado, simples, legível, cartoon.
- **Floresta:** verde profundo + azuis frios, toques âmbar de lanternas, mistério leve, denso sem virar terror.
- **UI:** cor viva por ação, contorno escuro, UICorner, tipografia arredondada, feedback claro e consistente.
- **Mundo:** low-poly *bem dirigido*, não simplesmente caixas, esferas e pinheiros duplicados em grid.

## Restrições

- Preservar vila e 4 lotes; trabalhar incrementalmente.
- A ferramenta faz o corte, não os pés do personagem.
- O corte deve acompanhar arco/faixa da lâmina, não limpar quadrados grandes visíveis.
- Não esconder recompensas totalmente aleatórias: haver pistas/segredos intencionais.
- Nunca limitar o mistério a porcentagens na loja; incluir ações e descobertas.
- Nunca vender como concluído algo não validado em Play.

## Ideias abandonadas ou apenas discutidas

- Conceito antigo **“Puxe as Ilhas”** foi abandonado — NÃO retomar como gameplay principal.
- Discussões sobre portar outros jogos de PC/Steam para Roblox foram exploratórias e não definem o projeto atual.
- Nas primeiras iterações, o escopo alternou entre Claude/Codex e ChatGPT editar arquivos. Hoje a decisão *prática* é que qualquer IA pode propor/editar sob a mesma governança, **mas o usuário escolhe a baseline e aprova mudanças**.

## Métricas de experiência — metas, NÃO dados medidos

- Primeiro upgrade (enxada): idealmente entre 1 e 3 min.
- Foice: ~8–12 min; carrinho manual ~20–30; motorizado ~45–70; trator ~90–150 min (propostas antigas, ajustar com telemetria).
- Primeira trilha/segredo: objetivo dentro de poucos minutos na floresta.
- Balancear a expectativa de progresso sem grind frustrante e sem subir nível a cada poucos segundos.
