#!/usr/bin/env python3
"""Validacao estatica da documentacao. Nao testa gameplay Roblox."""
from pathlib import Path
import json, re, sys

root=Path(__file__).resolve().parents[1]
required=["README.md","AGENTS.md","CLAUDE.md","BRAIN_COMPLETO.md","SECURITY.md",
"brain/status.json","handoffs/LOG.md","handoffs/TEMPLATE.md","tasks/BACKLOG.md","assets/MANIFESTO.md"]
required += [f"brain/{i:02d}_{name}.md" for i,name in enumerate([
"START_HERE","VISAO_E_DECISOES","ESTADO_REAL_E_VERSOES","PROGRESSAO_E_ECONOMIA",
"EQUIPAMENTOS_E_ANIMACOES","GRAMA_E_CORTE","MUNDO_FLORESTA_ESQUECIDA",
"ARVORE_E_HABILIDADES","UI_UX","BAUS_ITENS_E_DESCOBERTAS","ARQUITETURA_E_DADOS",
"ASSETS_E_BLENDER","BUGS_RISCOS_TESTES","ROADMAP","HISTORICO_DECISOES",
"SINCRONIZACAO_DAS_IAS","QUESTOES_ABERTAS"])]
errors=[]
for name in required:
    path=root/name
    if not path.is_file() or path.stat().st_size==0: errors.append("Missing or empty: "+name)
try:
    status=json.loads((root/"brain/status.json").read_text(encoding="utf-8"))
    for key in ("project","baseline","audit","status","critical_risks","evidence"):
        if key not in status:errors.append("status.json missing key: "+key)
    if status.get("evidence",{}).get("playtest_verified") is True:
        errors.append("Do not change playtest_verified without documented evidence")
except Exception as e: errors.append("Invalid JSON: "+str(e))
for path in root.rglob("*"):
    if not path.is_file() or path.suffix not in (".md",".json",".yml",".yaml",".sh",".py"):continue
    text=path.read_text(encoding="utf-8",errors="replace")
    if re.search(r"gh[pousr]_[A-Za-z0-9_]{30,}|github_pat_[A-Za-z0-9_]{30,}",text):
        errors.append("Potential secret: "+str(path.relative_to(root)))
if errors:
    print("BRAIN validation FAIL:")
    for e in errors:print("-",e)
    sys.exit(1)
print(f"BRAIN static validation OK — {len(required)} required files. NOT a Roblox Play test.")
