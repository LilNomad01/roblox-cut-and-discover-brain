# Expansão da Floresta Esquecida — auditoria inicial

Data: 2026-11-10.

## Build encontrada

- Studio: `corte e descubra (colaboração para programar)`.
- PlaceId: `106412085364108`.
- UniverseId: `10775723165`.
- Salva na nuvem; aguardando identificação como build oficial.
- O Studio passou de Edit para Play durante as leituras. Nenhuma alteração foi aplicada ao jogo.
- Entrega anterior localizada: `/Users/viniciusgullo/Voyager/aprimorar-jogo-no-roblox/entrega/CorteEDescubra_Floresta_Gruta_Gnomo_v11.rbxl`.
- O BRAIN do jogo no GitHub não foi localizado. A conta ativa do `gh` lista repositórios sem identificação deste jogo; a busca por `corte descubra` não retornou repositórios.

## Evidências no Studio

### Capacidade e economia

- `ServerScriptService.Economia.Iniciar` define `SacoMax` como `ConfigJogo.ItemPorId(...).Saco` e inicia `Saco` em zero.
- `Economia.Comprar` equipa o cortador e redefine `SacoMax` para `item.Saco`. Este é um ponto obrigatório de integração do bônus de mochila.
- `Economia.EncherSaco` limita a coleta a `SacoMax - Saco`; retorna zero quando a capacidade já foi excedida, preservando a grama existente.
- `Economia.Vender` calcula `floor(Saco * ConfigJogo.PrecoGrama)`, zera o saco e concede moedas, sem conceder XP. Não há yield entre essas operações no código lido.
- A implementação deve centralizar o recálculo de capacidade no servidor e reutilizar `Economia.Vender`.

### Pontos de venda

- `CorteEDescubra.CacambaVenda` conecta prompts às caçambas dos lotes e oferece venda automática por zona.
- Verifica o proprietário do lote e aplica intervalo de 1,2 segundo por jogador.
- O callback do prompt não possui validação explícita de distância; a venda automática mede a posição na zona.
- Dispara `ReplicatedStorage.EfeitoVenda` após vender. Reutilizar esse feedback.
- Pontos públicos da floresta precisarão de validação de distância, sessão ativa e desbloqueio individual, sem alterar a propriedade dos lotes.

### Dados

- `ReplicatedStorage.Shared.GameConfig.PersistenceEnabled = false`.
- `CorteEDescubra.Profiles` já oferece carregamento, captura, salvamento e lease de sessão.
- `ProfileData.capture` copia a tabela do perfil e captura os atributos de economia quando `ProfileReady` está ativo.
- `ProfileData` migra schema 1 para 2; extensões validadas atuais são `Economy` e `SkillData`.
- Novos campos devem usar essa estrutura e validação, sem DataStore paralelo.
- Nenhuma migração ou ativação de persistência foi executada.

### Conteúdo anterior

- `GameServer` já contém floresta, corte de matagal, baús e gnomo.
- O gnomo usa `ForestGnomeTrade` e uma troca já existente; integrar em vez de criar um segundo gnomo.
- O código da floresta informa que segredos são por sessão enquanto a persistência está desativada.
- `ForestScenery`, `ForestTreeKit` e `VendorAvatar` já existem para reaproveitamento visual.

## Próxima etapa

1. Obter o endereço do BRAIN compartilhado e confirmar a build oficial.
2. Ler as regras do BRAIN e concluir o inventário dos segredos, missões, UI e assets existentes.
3. Preparar backup e plano de rollback antes de qualquer mudança na estrutura persistida.
4. Implementar a expansão sem substituir o conteúdo anterior, preservar os quatro lotes e a loja principal.
5. Executar os testes de aceitação no Studio; registrar separadamente o que não puder ser executado.

## Validação realizada

Somente inspeção de arquivos e leitura do DataModel. Nenhum teste de aceitação executado. Nenhum arquivo Roblox atualizado produzido.
