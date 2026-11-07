#!/usr/bin/env bash
# Build the ZIP for the OpenAI plugin portal: plugin.json, mcp.json, skills/, assets/ at the archive root.
# Usage: scripts/build-openai-zip.sh [out.zip]
#   DEMO_RECORDING_URL=https://...   written into the ZIP's plugin.json as review.demo_recording_url (the
#                                    portal reads the video link from the package; the repo file is untouched).
# Refuses to build if a file looks like it holds a secret.
set -euo pipefail
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
out="${1:-$root/dist/docudetect-openai.zip}"
mkdir -p "$(dirname "$out")"
rm -f "$out"
DEMO_RECORDING_URL="${DEMO_RECORDING_URL:-}" python3 -I - "$root" "$out" <<'PY'
import json, os, re, sys, zipfile
root, out = sys.argv[1:3]
entries = ["plugin.json", "mcp.json", "LICENSE", "skills", "assets"]
demo = os.environ.get("DEMO_RECORDING_URL", "").strip()
SECRET = re.compile(r"(?i)(ghp_[A-Za-z0-9]{20,}|github_pat_|sk-[A-Za-z0-9]{20,}|AKIA[0-9A-Z]{16}|-----BEGIN [A-Z ]*PRIVATE KEY|client_?secret\"?\s*[:=]\s*\"[^\"]+|password\"?\s*[:=]\s*\"[^\"]+|bearer\s+[A-Za-z0-9._-]{20,})")

def plugin_json():
    data = json.load(open(os.path.join(root, "plugin.json")))
    review = data["extensions"]["com.openai"]["review"]
    if demo:
        if not demo.startswith("https://"):
            sys.exit("DEMO_RECORDING_URL must be an https:// link")
        review["demo_recording_url"] = demo
    elif not review.get("demo_recording_url"):
        print("WARNING: no demo_recording_url; the portal needs one before you can submit (set DEMO_RECORDING_URL)", file=sys.stderr)
    cases = review["test_cases"]
    assert len(cases["positive"]) == 5 and len(cases["negative"]) == 3, "need 5 positive and 3 negative test cases"
    return (json.dumps(data, indent=2, ensure_ascii=False) + "\n").encode()

def files():
    for e in entries:
        p = os.path.join(root, e)
        if os.path.isdir(p):
            for d, _, fs in sorted(os.walk(p)):
                for f in sorted(fs):
                    if f != ".DS_Store":
                        full = os.path.join(d, f)
                        yield os.path.relpath(full, root), open(full, "rb").read()
        else:
            yield e, plugin_json() if e == "plugin.json" else open(p, "rb").read()

with zipfile.ZipFile(out, "w", zipfile.ZIP_DEFLATED) as z:
    for name, data in files():
        if not name.endswith(".png") and SECRET.search(data.decode("utf-8", "ignore")):
            sys.exit(f"refusing to package {name}: it looks like it contains a secret")
        z.writestr(name, data)
    for i in z.infolist():
        print(f"{i.file_size:>8}  {i.filename}")
PY
echo "wrote $out"
