# Assets, Blender e pipeline de importação

## Arquivos locais conhecidos (2026-11-09)

- `Entrega4_Itens.zip`: 5 baús FBX + 5 cortadores FBX + 15 ferramentas FBX + `.blend` fonte, script Python, renders/README.
- `CorteDescubra_GrassPack.zip`: `.blend`, `generate_grass.py` ou scripts correlatos, GLBs de 3 estados/LODs, renders, manifesto e README.
- `FlorestaEsquecida.blend`: diorama/asset scene de floresta.
- `FlorestaEsquecida_Refinada_v2.blend`: refinamento incremental; script anterior criou coleção `CD_REFINO_V2`, podendo gerar erro em reexecução.
- Múltiplas cópias `.rbxl` v1–v9, com V9 última local, **não automaticamente baseline oficial**.

**Esses arquivos NÃO estão automaticamente incluídos neste repositório BRAIN.** Se forem subir ao GitHub, considerar Git LFS e licença/permissão; usar manifesto com nome/hash. Nunca inventar asset IDs.

## Inventário de modelos

| Kit | Quantidade conhecida | Principal pendência |
|---|---:|---|
| Máquinas | 5 FBX | Pivô, guidão, lâmina, cada motor/veículo funcional |
| Ferramentas manuais | 15 FBX | Montagem 2 mãos, animações, raridade real |
| Baús | 5 FBX | orientação, base/tampa, prompt, abrir/loot |
| Grama | GLB de TALL/SHORT/STUBBLE + LODs | importação real e instanciamento no lobby/floresta |
| Floresta | Blender com árvore/cabana/ponte/props | converter diorama em **kit modular**, não exportar ilha gigante |

## Regra do kit modular

Cada item precisa de:

- Prefixo estável: `TREE_*`, `Grass_*`, `Cabana_Abandonada`, `Cabana_Restaurada`, `Bridge_Broken`, `Bridge_Restored`, etc.
- Pivô na base, orientação frontal documentada e escala consistente.
- `Collision` simplificada; vegetação geralmente `CanCollide=false`.
- LOD ou variações leves e poucos materiais; estética stylized low-poly.
- Originais `.blend` e `.py`, exports `.glb`/`.fbx`, preview, manifesto.
- Checagem no Studio com modelo humano comparando escala.

## Árvores — novo kit necessário

Anteriormente as árvores ficaram como troncos retos e bolas/cones; a última floresta mostra pinheiros triangulares repetidos. Novo kit recomendado: `TREE_SMALL_01/02`, `TREE_MED_01/02`, `TREE_TALL_01/02`, `TREE_CROOKED_01`, `TREE_DEAD_01`, mais 2–4 variações grandes orgânicas, tocos e troncos caídos. Distribuir por grupos e alternar cor, tamanho e orientação sem parecer clone.

## Cabana e ponte

A cabana Blender possui conceito de **abandonada/restaurada**; houve tentativas de exportação, não comprovação de integração final. Deve substituir uma cabana provisória somente quando importada e testada. Ponte quebrada/restaurada com colliders adequados, sem tábuas flutuantes.

## Fluxo recomendado

`Blender (fonte + pivôs) → export FBX/GLB → Studio Import 3D → checar hierarquia MeshParts → ajustar PrimaryPart/attachments → prefab sob ServerStorage → montar região modular → teste de escala/performance → conectar lógica/recompensas`.

**Não modelar uma floresta gigante como malha única.** Montagem ambiental, iluminação, pathing e células de corte são do Roblox Studio.
