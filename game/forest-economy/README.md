# Comércio da Floresta Esquecida

Implementação incremental sobre o place `106412085364108`, sem substituir a vila, os quatro lotes, o corte ou a Loja principal. O mapeamento entre fontes e instâncias está em `manifest.json`.

## Conteúdo

- Guto vende cinco níveis de mochila. O melhor nível soma capacidade ao cortador atual; reequipar não acumula bônus. A grama excedente continua no saco e impede novas coletas até a venda.
- Lia vende lanterna real, bússola para comerciantes visitados, marcador com mapa de campo e kit consumível para pistas próximas e visíveis. O botão **Explorar** oferece acesso aos equipamentos com a mochila padrão do Roblox oculta.
- Teca compra flores, troca cogumelos por kits e oferece um contrato de três flores. A conclusão libera individualmente a caçamba da cabana.
- O gnomo existente passa a ser Nilo. Cortar o matagal continua necessário para revelá-lo; cada jogador precisa descobri-lo para abrir sua loja. Oferece missão de relíquias, aparência de mochila e pista da caverna.
- Três caçambas usam `Economia.Vender`, a cotação atual e o evento de áudio/efeitos existente, com validação de sessão, distância e desbloqueio.

Mochilas e espaços comerciais usam peças nativas leves e o avatar já existente. O cliente anima dois detalhes do gnomo. Os locais secretos não são incluídos no catálogo público nem nos destinos da bússola.

## Dados e publicação

`ForestEconomy` é uma extensão opcional validada do perfil atual. Perfis anteriores sem esse campo continuam aceitos. `ProfileData.capture` captura a extensão na estrutura existente. Não há inventário paralelo para grama, DataStore novo ou alteração de `schemaVersion`.

**`PersistenceEnabled=false` permanece ativo. Compras e descobertas duram somente a sessão.** Não foi executada migração de banco, ativação de persistência, teste de reconexão com save ou publicação do jogo. Ativar persistência exige trabalho separado com backup e rollback dos dados.

## Testes reproduzíveis

1. Compile todos os `.luau` com o compilador oficial Luau e execute `tests/transactions.luau` com o interpretador Luau. São 50 asserções de transações, limites, isolamento e capacidade.
2. Abra Play em uma cópia do place com persistência desativada. Espere `ProfileReady`.
3. Insira `tests/StudioAcceptance.server.luau` como Script temporário em `ServerScriptService` e `tests/StudioAcceptance.client.luau` como LocalScript temporário em `LocalPlayer.PlayerGui`, nomeado `ForestAcceptanceClient`. O servidor cria `ReplicatedStorage.ForestAcceptanceTransport`; insira o cliente depois dessa criação, em até cinco segundos.
4. Inspecione os atributos `Passed` e `Result` do Script servidor. O teste altera saldo e recursos apenas na sessão de Play, usa os remotes reais e revela o gnomo pela rota de corte existente. Pare Play para descartar os dados e os scripts temporários.

No MCP do Studio, `require` executado diretamente no comando pode usar cache separado dos Scripts do jogo. Execute testes de serviços com estado dentro de Scripts normais; invocar o serviço diretamente no comando não reproduz a sessão real.

Os testes automatizados não comprovam navegação física completa, toque, controle real, multiplayer ou desempenho em aparelhos móveis. Consulte a evidência de validação antes de marcar critérios como concluídos.

## Backup e rollback do código

Os seis scripts anteriores estão em `ServerStorage.ForestCommerceBackup_20261110`; cópias de Scripts executáveis estão desativadas. Para rollback em Edit, restaure o `Source` dessas seis cópias nos caminhos indicados por seus nomes. Remova as cinco novas instâncias de código listadas no manifesto e a pasta de backup somente depois da restauração. A construção comercial existe durante Play e desaparece ao parar a sessão.

As fontes estão versionadas no GitHub. O arquivo do place precisa ser salvo pelo usuário no Studio; o MCP utilizado não oferece uma operação de salvar `.rbxl`.
