"""Modelo de progressão do Corte & Descubra (Claude, 2026-11-11).

Simula um jogador eficiente que só faz jardins no lote com o cortador (sem floresta, segredos
nem ferramentas manuais) e compra o próximo cortador assim que tem moedas.

Premissas (medidas ou lidas do jogo; ajuste aqui para recalibrar):
  - jardim = 64 tufos; cada tufo: 1 grama x multiplicador do cortador e 5 XP (ConfigJogo)
  - venda: 2 moedas por grama; fim do jardim +40 moedas/+40 XP; fechamento +20/+20 (GameServer)
  - prêmio por nível: 25 x nível (ConfigJogo.RecompensaNivel)
  - tempo por jardim = 45 s cortando + 10 s por viagem até a caçamba + 5 s para pegar o serviço
    (medido em Play: ~1,5-2 tufos/s cortando; a velocidade não depende do cortador comprado)

Uso: python modelo_progressao.py
"""
import math

CORTADORES = [  # nome, preço, multiplicador, saco
    ("Basico", 0, 1, 50),
    ("Eletrico", 800, 2, 100),
    ("Turbo", 3200, 4, 250),
    ("Trator", 16000, 10, 800),
    ("OffRoad", 47000, 14, 1200),
    ("Colheitadeira", 75000, 18, 1800),
    ("Mega", 140000, 30, 3000),
    ("Imperial", 360000, 45, 5000),
]


def xp_para_nivel(n):
    return math.floor(110 * n ** 1.4)


def simular(horas=9):
    t = coins = xp = 0
    nivel, idx = 1, 0
    compras, niveis = {}, {}
    while t < 3600 * horas and idx < len(CORTADORES) - 1:
        _, _, mult, saco = CORTADORES[idx]
        viagens = math.ceil(64 * mult / saco)
        t += 45 + 10 * viagens + 5
        coins += 64 * mult * 2 + 60
        xp += 64 * 5 + 60
        while xp >= xp_para_nivel(nivel):
            xp -= xp_para_nivel(nivel)
            nivel += 1
            coins += 25 * nivel
            niveis.setdefault(nivel, t)
        while idx < len(CORTADORES) - 1 and coins >= CORTADORES[idx + 1][1]:
            coins -= CORTADORES[idx + 1][1]
            idx += 1
            compras[CORTADORES[idx][0]] = (round(t / 60), nivel)
    return compras, {k: round(v / 60) for k, v in niveis.items()}


if __name__ == "__main__":
    compras, niveis = simular()
    print("compra (minutos, nível):", compras)
    print("níveis (minutos):", {k: niveis[k] for k in (5, 10, 15, 20, 25) if k in niveis})
