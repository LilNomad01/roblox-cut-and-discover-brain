#!/usr/bin/env bash
set -euo pipefail
# Atualizar a documentacao local. Nao conecta modelos automaticamente.
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
git -C "$ROOT" pull --ff-only
python3 "$ROOT/scripts/validate_brain.py"
echo "BRAIN atualizado localmente. Releia status.json + handoffs/LOG.md."
