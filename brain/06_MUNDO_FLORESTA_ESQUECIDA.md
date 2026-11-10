# Mundo e reformulação da Floresta Esquecida

## Mundo compartilhado — visão planejada

**Centro:** vila ensolarada com **quatro terrenos particulares**, estradas, caçamba de venda, loja, testes e menus.  
**Região inicial:** **Floresta Esquecida**, acessível caminhando da vila, centro do primeiro ciclo de descoberta/restauração.  
**Futuro:** Fazenda Abandonada (off-road e materiais), Parque do Lago (exploração livre), Ruínas Antigas (puzzles e segredos); ainda não presumir construídos.

## Avaliação artística da última screenshot — 2026-11-09

**O usuário desaprovou** o cenário atual. Visual visto: pinheiros triangulares/planos em fileiras uniformes, troncos semelhantes, chão aberto, grama alta em manchas mas pouco sub-bosque, cabana distante, céu enorme, contraste de piso escuro artificial. Lembra plantação de árvores/procedural genérico. Precisa refazer o **level art e o fluxo de exploração**, não apenas aumentar quantidade de objetos.

### Nova direção de arte aceita como proposta prioritária

- **Floresta encantada abandonada, levemente misteriosa, NÃO terror.** Visual cartoon/low-poly bem modelado com luz azul-petróleo, verdes profundos, dourado nas lanternas e pontos focais.
- Árvores orgânicas de silhuetas variadas: troncos curvados, bifurcações, raízes suaves, copas irregulares em 2–6 volumes, algumas coníferas boas, árvores secas quebradas e jovens.
- Sub-bosque: samambaias, moitas, arbustos, rochas com musgo, troncos caídos, tocos, fungos, raízes, flores pontuais e folhas no solo.
- **Ocultação intencional:** limitar linhas de visão com curva de trilha, árvores densas, elevação suave, muros de vegetação; sugerir pontos de interesse sem revelar tudo.
- **Contraste espacial:** túnel de árvores → clareira iluminada → matagal escuro → cabana com luz âmbar → riacho → segredo.
- Densidade não significa colidir com tudo ou sobrecarregar mobile. Massas decorativas e manchas cortáveis devem ser separadas.

## Organização de mapa proposta (não coordenadas verificadas)

### 0. Passagem desde a vila — 30–60 studs de transição

Saída física do lobby, sem teleporte seco. Relva comum vai ficando alta, árvores aproximam, cerca/placa antiga, luz muda sutilmente. O jogador enxerga uma pista de cabana e escuta novos sons. Sem bloquear acesso básico a iniciantes.

### 1. Mata Baixa — primeira descoberta (tutorial)

Mato alto da Área de Teste em manchas; trilha antiga parcialmente visível; primeiro baú/objeto simples. Câmera mobile deve manter o personagem legível. Introduzir pista que aponta para a cabana.

### 2. Corredor dos Galhos — primeiro corte de caminho

Trilha sinuosa com curva, samambaias, árvores altas. Matagal impede ver o próximo ponto, mas a direção é dada por sinais ambientais (placa caída, trilho de terra, flores únicas). Nada de corredor perfeitamente reto com árvores equidistantes.

### 3. Cabana Esquecida — primeiro grande ponto de interesse

Cabana abandonada do kit Blender, parcialmente escondida entre árvores. Varanda, telhado assimétrico, musgo, trepadeiras, cercas velhas, ferramentas, lanterna quente. Ao revelar: VFX de descoberta e missão de restauração. Versão restaurada em modelos separados, controle por jogador/servidor definido antes.

### 4. Riacho + Ponte Quebrada — objetivo de médio prazo

Água natural em leito curvo, pedras nas margens, ponte quebrada com madeiras corretas, sem formas flutuantes. A ponte mostra claramente uma área além do riacho. A habilidade `REST_BRIDGE` é planejada; não bloquear progressão por feature ainda indisponível sem rota alternativa.

### 5. Clareira Secreta — recompensa do curioso

Pequena área distinta com pedestal/artefato ou um baú raro, acessível por uma pista no entorno e corte do matagal. Não anunciar no mapa antes de descoberta.

### 6. Núcleo da Floresta Antiga — progressão futura

Mais denso/escuro, árvores antigas, sons profundos, segredos ligados a habilidades; manter acessível a quem chega. Trilhas secundárias e atalhos após limpeza.

## Escala

O usuário quer área significativamente maior do que a pequena ilha de Blender. Nas iterações foram propostos ~330×330 e ~470×478 studs, mas são **dimensões de experimentos**, não “tamanho final aprovado”. Nova escala deve ser baseada no tempo de percurso, densidade, FPS e conteúdo. Sugerir **400–600 studs** como espaço de planejamento, com possibilidade de expandir por setores, mas *não* gerar campo plano vazio só para crescer números.

## Layout navegável

- Caminho principal entendível mesmo sob matagal, 3–5 pontos de interesse espaçados.
- 2–4 subrotas opcionais; cada rota com **pista visual + resultado**.
- 6–10 segredos iniciais criados com intenção; não confundir com roll de baú aleatório.
- Distância/ocultação de vistas controlada; mostrar fragmentos da cabana, ponte e ruína para criar curiosidade.
- Testar tempo de caminhada do spawn ao primeiro segredo sem equipamento caro.

## NPC e missões — projeto

**Zeca, o Jardineiro** na entrada/ligado à cabana. Missão inicial **“A Trilha Esquecida”**: conversar, limpar caminho, encontrar **3 itens antigos**, descobrir cabana, retornar. Missão seguinte **“Um Novo Começo”**: reunir materiais, limpar entorno e restaurar cabana. Recompensas em moedas/XP/PH precisam balanceamento e idempotência. **NÃO confundir Zeca com o NPC “Novo Serviço” do lote privado**.

## Blender ↔ Roblox Studio

- Não exportar uma floresta inteira como um MeshPart gigante. Usar **kit modular**: árvores, vegetação, pedras, raízes, cabana/variações, ponte/variações, placas/cercas, esconderijos.
- Roblox monta setores, lógica, colisões, cut cells, checkpoints, reveal e iluminação local.
- Asset não deve aparecer “flutuando”: pivô na base, orientação consistente, teste de escala (1 stud) e Snap-to-Ground por raycast.

## Iluminação e áudio

- Evitar editar `Lighting` global de forma irreversível ao entrar (afeta todos jogadores em server). Usar efeitos locais com Tween no cliente, zona de Atmosphere/ColorCorrection quando tecnicamente compatível, sons 3D regionais e sombras de geometria.
- Transição desejada: ~1,8 s com `Sine InOut`/`Cubic InOut`, leve redução de saturação/brilho, sem deixar legibilidade ruim.
- Ambient: vento, aves distantes, folhas/insetos. Usar IDs licenciados/autorizados, não placeholders de áudio fictícios.

## Critérios de aprovação visual

1. 8–12 silhuetas reais de árvore e distribuição **não regular**.
2. Sub-bosque em camadas e artefatos que contam história.
3. Trilhas sinuosas com revelação gradual e clareiras.
4. Cabana marcante e ligada à mecânica de cortar/descobrir.
5. Mato da Área de Teste denso, com corte e recompensas válidos.
6. 2–3 segredos funcionais no primeiro setor antes de expandir.
7. Sem asset flutuante, sem chão artificial vazio, sem queda significativa de FPS mobile.

## Expansão planejada — economia e NPCs da floresta (2026-11-10)

O usuário pediu comerciantes especializados, caçambas para vender grama sem sair da floresta, upgrades de mochilas, e um gnomo secreto com loja própria. A especificação de produto e critérios de aceite estão em [17 — Comerciantes e mochilas](17_COMERCIANTES_CACAMBAS_MOCHILAS.md) e [Issue #6](https://github.com/LilNomad01/roblox-cut-and-discover-brain/issues/6). **Nenhuma dessas mecânicas foi implementada por esta atualização documental.**

## Ideia reservada, sem implementação — jardineiro no nível 5

O usuário propôs que o jardineiro do lobby mencione a Floresta Esquecida quando o jogador alcançar o nível 5. **NÃO IMPLEMENTAR AINDA.** Não adicionar bloqueio, diálogo, quest ou trigger sem autorização. Ver [estacionamento de ideias](../ideas/IDEIAS_FUTURAS_NAO_IMPLEMENTAR.md).

## Nova direção visual em 2026-11-10 — V19 relatada

Reforma de **transição de biomas, relevo/montanhas, riacho, placas, caverna existente e nova caverna subterrânea sob o matagal**: ver [capítulo 18](18_REFORMA_VISUAL_V19_BIOMAS_MONTANHAS.md) e [Issue #8](https://github.com/LilNomad01/roblox-cut-and-discover-brain/issues/8). **PLANEJADO; não reconstruir os comerciantes/mochilas/caçambas que o usuário relatou já ter implementado.**
