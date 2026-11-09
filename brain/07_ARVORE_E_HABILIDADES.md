# Árvore de habilidades — 19 nós, PH e implementação real

## Visual

O usuário enviou referência de árvore de habilidades **hexagonal**, vários ramos com cores próprias e painel lateral. Nosso design precisa casar com o jogo, não ser um overlay preto/genericão. Nó central **Jardineiro Iniciante**, pan/zoom PC e touch, categoria com cor, cadeados, requisitos, custo, rank, efeito real e interação com mapa.

Ramos: **CORTE verde**, **EXPLORAÇÃO azul**, **TECNOLOGIA laranja**, **RESTAURAÇÃO roxo**, **MISTÉRIOS dourado/segredos ocultos**.

## Fatos da V9 — `SkillDefinitions`

**19 nós**. O arquivo classifica oito como `Ready` e outros onze como `Planned`, mas *Ready em código ≠ testado em Roblox Studio*. Existem `SkillService` e `SkillMechanics`; validar gatilhos reais e conexões UI antes de permitir compra no jogo publicado.

### Nós `Ready` no arquivo, com comportamento descrito nos módulos

| ID | Nome | Status arquivo | Ação/evidência textual |
|---|---|---|---|
| `CUT_CLOSE` | Corte Rente | Ready | após jardim completo, passar novamente para acabamento (`STUBBLE`) |
| `CUT_SPIN` | Corte Giratório | Ready | corte em raio/até 10 tiles no lote, cooldown ~20 s |
| `CUT_TURBO` | Modo Turbo | Ready | aumenta faixa de máquina por ~8 s, cooldown ~45 s |
| `EXP_VISION` | Visão do Explorador | Ready | torna grama do lote translúcida por ~5 s, mostra pista do baú |
| `EXP_DETECTOR` | Detector de Tesouros | Ready | `G` detecta baú já revelado no lote por ~8 s |
| `TECH_CLIPPINGS` | Coletor de Aparas | Ready | recurso/passivo a cada cortes legítimos, respeita capacidade |
| `TECH_QUICKSWAP` | Troca Rápida | Ready | alternar entre últimos dois cortadores adquiridos (`V`) |
| `TECH_DRONE` | Drone Jardineiro | Ready | `H`, drone temporário no próprio lote com cap de cortes, cooldown ~60 s |

Observação de escopo: algumas ações citadas como “para floresta” em prompts antigos funcionam *somente no lote* na configuração atual. Extensões para floresta são **PLANEJADAS**, não existentes só por nome.

### Nós `Planned` / NÃO compráveis até mecânica real

- `CUT_PRECISION` — Corte de Precisão; linhas, padrões e bordas.
- `EXP_MAP` — Cartógrafo; mapa detalhado com descobertas reais, não revelar segredos desconhecidos.
- `EXP_BOTANIST` — Botânico Especialista; interação com plantas especiais.
- `TECH_OFFROAD` — Rodas Off-Road; lama/rampas em Fazenda.
- `REST_BRIDGE` — Construtor de Pontes; reparar ponte e liberar trajeto.
- `REST_GARDEN` — Jardineiro Criativo; decoração limitada ao lote próprio.
- `REST_WORKSHOP` — Oficina Restaurada; recuperação de instalação e novas funções.
- `REST_COOP` — Mutirão de Limpeza; contratos cooperativos.
- `SECRET_ROOTS` — Segredo das Raízes; descoberta por pista do mundo.
- `SECRET_LEGENDARY_CUT` — Corte Lendário; domínio de ferramentas/realizações.
- `SECRET_GREEN_ARCH` — Arqueologia Verde; padrões/ruínas/puzzles.

## Integração com mapa de exploração

Mapa no menu **Exploração** deve mostrar somente regiões descobertas, marcador do jogador, NPCs conhecidos, ponte e cabana descobertas, pistas de tesouro autorizadas. Habilidades `EXP_MAP`, `EXP_DETECTOR`, `EXP_VISION`, `REST_BRIDGE` devem produzir **mudanças visíveis** no mapa quando implementadas.

## Pontos de habilidade

- Marcos propostos no arquivo: `[2,4,6,8,10,12,15,18,22,26]`.
- Servidor verifica saldo, nível, propriedade da ferramenta, requisito, rank e `status=Ready` com mecânica real.
- UI precisa mostrar motivo de bloqueio e nunca gastar PH para função inexistente.
- Salvar progressão, ranks e fontes de PH sem duplicar; hoje persistência não comprovada.

## Bugs já vistos

- Duas árvores/interfaces sobrepostas em versões anteriores.
- Componentes de **Perfil/Equipamentos/Habilidades** visíveis simultaneamente em screenshot de UI.
- `0 PH` com vários nós bloqueados; se houver teste, não interpretar isso como sistema quebrado por si só.
- Painel lateral lotado e textos cortados em alguns formatos de tela; precisa safe areas, hierarquia e scroll próprios.

## Critérios de qualidade

Nenhuma árvore fake. Visual, dado e servidor sincronizados. Pan/zoom suaves; código não renderiza conexões a cada frame sem necessidade; botões de unlock mostram feedback; segredo oculto não vaza descrição. Validar multi-jogador, mobile e reconexão antes de `VALIDADO_EM_PLAY`.
