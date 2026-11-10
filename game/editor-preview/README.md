# Prévia da Floresta Esquecida no editor

O jogo mantém sua geração autoritativa durante Play. A prévia em `Workspace.ForestEditorPreview` permite inspecionar cenário, cabana, caminhos, rio, comerciantes e cobertura de matagal sem iniciar o teste.

A grama da prévia usa o mesmo asset e cobertura distante do cliente, com menos peças que os registros lógicos completos. Não executa cortes, compras, descobertas ou recompensas. As interações ficam desativadas.

## Instalação reproduzível

1. Usar a build atual do place `106412085364108`; parar Play.
2. Aplicar as integrações de `GameServer` e `ForestScenery` deste commit.
3. Executar o conteúdo de `install.luau` no contexto privilegiado do Studio (Command Bar/MCP). O instalador cria `ServerScriptService.CorteEDescubra.ForestEditorPreview` a partir dos helpers do GameServer instalado. Não executar GameServer no editor.
4. Executar:

```lua
require(game.ServerScriptService.CorteEDescubra.ForestEditorPreview).build()
```

5. Salvar o place. A instalação desta sessão já está salva no Roblox, versão 19.

O instalador recusa substituir módulo existente. `build()` retorna a mesma prévia pronta quando chamado novamente; uma montagem incompleta exige restauração antes de repetir. Os módulos de cenário existentes fornecem árvores, props e comerciantes. Nenhum asset externo foi adicionado.

## Limite de edição

A prévia é uma visualização estática. Mover suas peças não modifica o layout do Play. Mudanças permanentes devem ser feitas em `GameServer`, `ForestScenery` ou `ForestCommerceWorld`, seguidas de reconstrução da prévia.

Ao iniciar Play, as primeiras linhas de GameServer removem somente o modelo com nome e atributo de prévia esperados. O gerador original monta a floresta funcional. Ao parar Play, o Studio recupera a prévia salva do editor.

## Backup e restauração

Antes de preparar o terreno, `ServerStorage.ForestEditorPreviewBackup_20261110` guarda `OriginalTerrain` e referências com pivôs das árvores originais. A região é limitada à floresta e seu acesso. O backup não é enviado aos clientes.

Para remover a prévia e restaurar terreno/pivôs, fora de Play:

```lua
require(game.ServerScriptService.CorteEDescubra.ForestEditorPreview).restore()
```

O backup permanece disponível. Para reconstruir após restaurar, executar `build()` novamente. Para retirar toda a implementação, também remover o módulo de prévia e as cinco linhas iniciais identificadas em GameServer. A alteração de ForestScenery pode permanecer: ela remove uma dependência de caminho fixo sem mudar a árvore usada no Play.

Backups adicionais do código anterior estão em `ServerStorage.GameServerBeforeEditorPreview` e `ServerStorage.ForestSceneryBeforeEditorPreview`. Não habilitar esses backups.
