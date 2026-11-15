# Validação: APIs extras (fase 2)

**Data:** 2026-11-14 · **IA:** Claude · **Place:** `106412085364108` · **Ambiente:** Edit e Play no Studio (PC)

**Fontes:** tamanhos no Studio iguais aos do repositório. ApisExtrasServidor 6512, ApisExtrasCliente 5681, LojaConfig 4528, LojaServidor 12549, LojaCliente 13969 e AmigosCliente 1949 bytes.

| Teste | Resultado |
|---|---|
| GlobalWind | brisa (3; 0; 1,2) → evento "vento" (22; 0; 9) → de volta à brisa ao parar ✅ |
| Assinatura simulada (`LojaTestePasses=ClubeJardineiro`) | `ClubeJardineiro=true`, `BonusLoja=0,25` ✅ |
| MessagingService / anúncio | `Anunciar:Fire(...)`: o cliente recebeu pelo NotificarHUD "🥚 Teste 2: alguém chocou 🔥 Fênix do Jardim (Celestial)!" ✅ |
| MemoryStoreService | `workspace.TufosMundoHoje=37` depois de 30 s; a placa no Quadro de Ranking mostra "🌍 Tufos cortados hoje no mundo: 37" ✅ |
| Input Action System | tecla **L** (entrada real) abriu a loja Premium; o contexto `AtalhosLoja` existe ✅ |
| AnalyticsService | o console mostrou os passos do funil e os `LogEconomyEvent` de compras ✅ |
| Console | sem erros dos scripts novos ou alterados ✅ |

## Ocorrência durante o teste

Enquanto o teste rodava, o personagem comprou com **moedas** Colheitadeira, Mega e Imperial GX, pela loja normal (`ComprarItem`, só por clique). Nenhum script novo compra cortadores, e a tecla L só abre a loja Premium. Provavelmente foi o usuário jogando na mesma janela. **As compras não foram desfeitas.**

## Não testado (sem como no Studio, ou depende do dono)

- **CaptureService:** foto ao achar segredo. Não simulei o segredo, para não mexer no perfil.
- **Convite com LaunchData:** precisa de duas contas e servidor publicado.
- **Opt-in de notificações:** aparece só depois de 5 min jogando e de uma venda. Também precisa do jogo publicado e dos modelos de texto no Dashboard.
- **Vibração:** precisa de celular ou controle real.
- **Anúncio entre servidores diferentes:** precisa de 2 servidores publicados. Testei só no mesmo servidor.
- **Compra real de assinatura, passes e produtos:** precisa dos IDs.
