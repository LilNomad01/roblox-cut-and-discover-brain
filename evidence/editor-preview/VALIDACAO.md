# Validação — floresta no editor

Data: 2026-11-10. Base: `8a6f71c`, place `106412085364108`, universo `10775723165`.

## Executado no Studio

- Instalação em Edit, sem executar GameServer ou serviços de perfil/economia no editor.
- Primeira montagem interrompida por referência fixa na exploração a `Workspace.GameWorld.FlorestaEsquecida`. A restauração de terreno/pivôs foi executada antes da segunda montagem.
- Referência corrigida para `root.ArvoresModulares`; módulo de cenário carregado por cópia fresca para evitar cache da primeira tentativa.
- Segunda montagem: `BuildOK=true`, `PreviewState=Ready`, 12.065 descendentes, 6.075 meshes de cobertura de matagal.
- Inspeção visual pela captura `floresta_editor_previa`: floresta, rio, árvores, cabana e cobertura de grama visíveis fora de Play.
- Repetição de `build()`: mesma instância e mesma contagem, sem duplicação.
- Zero ProximityPrompts habilitados e zero BaseParts não ancoradas na prévia pronta.
- `OriginalTerrain` confirmado como TerrainRegion. Backup marcado pronto antes de preparar terreno.
- Play iniciado: `previewAbsent=true`, `runtimeForests=1`, `GrassCount=25197`, `SecretsCount=16`, `ForestGrassStream` único.
- Console desse Play:

```text
Hello world!
[CorteProto] zona CutPrototype: 256 clusters, 3600 células lógicas (4 patches de 12 studs, res 0.40), montado em 4 ms
[Floresta] PRONTA: 25197 tufos cortaveis GrassPack, 16 segredos, area 600x648 studs
```

- Stop: prévia voltou em Ready com os mesmos 12.065 descendentes. Câmera do editor posicionada para visão geral da floresta.
- Fontes instaladas comparadas com arquivos das integrações, ignorando whitespace final, por comprimento/checksum polinomial módulo 1000000007: GameServer `70364 / 85466444`; ForestScenery `30264 / 758169886`.
- Save do Studio retornou `Saved`, destino TeamCreate, versão 19. Nenhuma publicação executada.

## Verificação local

Compilação Luau 0.746 do instalador, módulo derivado dos mesmos trechos e integrações. Validador documental do BRAIN e `git diff --check` executados antes do commit.

## Limites

Não foi executado fechamento/reabertura do Studio, comparação voxel por voxel após restore, benchmark em outra máquina ou novo teste da economia completa. A cobertura de grama é simplificada para visualização no editor. Mudanças nas peças da prévia não se propagam ao gerador de Play.
