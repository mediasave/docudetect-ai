#!/usr/bin/env bash
# Build the ZIP for the OpenAI plugin portal: plugin.json, mcp.json, skills/, assets/ at the archive root.
set -euo pipefail
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
out="${1:-$root/dist/docudetect-openai.zip}"
mkdir -p "$(dirname "$out")"
rm -f "$out"
python3 -I - "$root" "$out" <<'PY'
import os, sys, zipfile
root, out = sys.argv[1:3]
entries = ["plugin.json", "mcp.json", "LICENSE", "README.md", "skills", "assets"]
with zipfile.ZipFile(out, "w", zipfile.ZIP_DEFLATED) as z:
    for e in entries:
        p = os.path.join(root, e)
        if os.path.isdir(p):
            for d, _, fs in sorted(os.walk(p)):
                for f in sorted(fs):
                    if f != ".DS_Store":
                        full = os.path.join(d, f)
                        z.write(full, os.path.relpath(full, root))
        else:
            z.write(p, e)
    for i in z.infolist():
        print(f"{i.file_size:>8}  {i.filename}")
PY
echo "wrote $out"
