#!/usr/bin/env bash
# Build the claude.ai uploads: the plugin (Customize > Plugins > Add > Upload plugin) and the skill alone
# (Customize > Skills). The plugin ZIP holds one top-level docudetect/ folder with .claude-plugin/plugin.json,
# .mcp.json and skills/; the OpenAI-only files stay out.
set -euo pipefail
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
out="${1:-$root/dist}"
version="$(python3 -I -c 'import json,sys; print(json.load(open(sys.argv[1]))["version"])' "$root/.claude-plugin/plugin.json")"
stage="$(mktemp -d)"
trap 'rm -rf "$stage"' EXIT
mkdir -p "$stage/docudetect/.claude-plugin" "$out"
cp "$root/.claude-plugin/plugin.json" "$root/.claude-plugin/icon.png" "$stage/docudetect/.claude-plugin/"
cp -r "$root/.mcp.json" "$root/skills" "$root/README.md" "$root/LICENSE" "$stage/docudetect/"
if command -v claude >/dev/null; then claude plugin validate "$stage/docudetect" --strict >/dev/null; fi
rm -f "$out/docudetect-plugin-$version.zip" "$out/docudetect-documents-skill.zip"
(cd "$stage" && zip -qrX "$out/docudetect-plugin-$version.zip" docudetect -x '*.DS_Store')
(cd "$root/skills" && zip -qrX "$out/docudetect-documents-skill.zip" docudetect-documents -x '*.DS_Store')
echo "wrote $out/docudetect-plugin-$version.zip and $out/docudetect-documents-skill.zip"
