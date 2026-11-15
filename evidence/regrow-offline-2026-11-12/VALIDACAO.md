# Validação — rebrota do lote e progresso offline (PAD-04)

**Data:** 2026-11-12 · **IA:** Claude · **Place:** `106412085364108` · **Ambiente:** Play no Studio (PC), store `CorteEDescubra_v1_Studio`

## Progresso offline

1. Com o perfil salvo, `lastSaveTime` foi recuado 2 h na store de Studio.
2. Ao entrar de novo: moedas **14.502 → 15.270 (+768)**. Conta: 120 min × 6,4 × 1 = 768. ✅
3. O cliente mostrou o aviso "(2h 00min) +768 moedas" uma única vez. ✅

## Rebrota do lote

Leitura no servidor, a cada 3 s:

```
antes da coleta (baú revelado, por desenho a rebrota espera):
t=0s  Cortes=64 Pronto=true tufos_visiveis=0 dourados=0 bau_no_lote=true
t=24s Cortes=64 Pronto=true tufos_visiveis=0 dourados=0 bau_no_lote=true

baú pego com E, depois:
t=0s  Cortes=64 Pronto=true  tufos_visiveis=0  dourados=0 bau=false
t=3s  Cortes=0  Pronto=false tufos_visiveis=64 dourados=2 bau=false
t=12s Cortes=0  Pronto=false tufos_visiveis=64 dourados=2 bau=false
```

✅ Serviço novo, 64 tufos e 2 dourados sorteados. Console sem erros de script.

## Não testado

- Rebrota sem baú revelado (só o atraso de 20 s);
- servidor publicado (relógio e saves reais);
- celular e multiplayer.
