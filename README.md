# DocuDetect for AI assistants

Plugin and agent skill for [DocuDetect](https://docudetect.com), the e-signature app. Connect it to Claude, ChatGPT, Codex, Cursor, Gemini CLI or any agent that loads `SKILL.md` skills, and the assistant can prepare PDFs for signature in your DocuDetect account: upload a PDF as a draft, detect, preview and place signature, text, date and checkbox fields, fill in values you give it, copy a master form for each new client or property, set the signer and organise folders. It never sends or signs; you review and send from the app.

| Skill | What it does |
|-------|--------------|
| [`docudetect-documents`](skills/docudetect-documents/SKILL.md) | The workflow: connect, find or create a draft, agree and save fields, fill values, hand over for review. |

The skill drives the DocuDetect MCP server at `https://docudetect.com/mcp`. Sign in with your DocuDetect account (OAuth in the browser, no API key). Your documents live at docudetect.com, where the documents app itself is called Way of That.

## Install

**Claude Code** (plugin: skill and server together)

```
/plugin marketplace add mediasave/docudetect-ai
/plugin install docudetect@docudetect-ai
```

In one step on Claude Code 2.1.275 or later: `/plugin install docudetect --marketplace mediasave/docudetect-ai`. Then run `/mcp` and sign in.

**Claude.ai and Claude Desktop:** add the connector at Settings > Connectors > Add custom connector, URL `https://docudetect.com/mcp`, or install the plugin from the Claude directory.

**Any agent with skills** (Claude Code, Codex, Cursor, Gemini CLI, GitHub Copilot, OpenCode and others)

```bash
npx skills add mediasave/docudetect-ai
```

Add `-g` for all your projects, or `-a codex`, `-a cursor` and so on to pick agents. Then connect the server; per-agent steps are in [connect.md](skills/docudetect-documents/references/connect.md). If the server is not connected, the skill tells the agent to show you these steps instead of guessing.

**ChatGPT and Codex:** install the DocuDetect plugin from the plugin directory. Maintainers can build the upload package with `scripts/build-openai-zip.sh`.

## What the agent can and cannot do

- It works on drafts only. It cannot send, sign, remind, void or delete; the MCP server has no tools for those.
- It shows you the fields it plans to save and saves only when you agree, then re-renders each changed page so you can check it.
- It sets the signer only from a name and email you gave it, and fills only values you gave it. It never fills signatures, initials, signing dates or another person's statements.
- Uploaded PDFs and copies are stored permanently in your account.

## Data

The package is instructions and configuration only; it stores nothing and runs no code. Through the MCP server, your assistant sends document titles, field positions and values, signer names and emails, and the PDFs you upload to your DocuDetect account at docudetect.com. Every change made through the server is recorded in an audit log. See the [privacy policy](https://docudetect.com/privacy) and [terms](https://docudetect.com/terms). Support: [contact@docudetect.com](mailto:contact@docudetect.com) or [docudetect.com/contact](https://docudetect.com/contact). Troubleshooting: [docudetect.com/claude/troubleshooting](https://docudetect.com/claude/troubleshooting).

## Layout

| Path | Used by |
|------|---------|
| `skills/docudetect-documents/` | skills.sh, Claude Code, Claude, Codex, ChatGPT |
| `.claude-plugin/plugin.json`, `.mcp.json` | Claude Code and the Claude directory |
| `.claude-plugin/marketplace.json` | `/plugin marketplace add` (this repo is its own marketplace) |
| `plugin.json`, `mcp.json`, `assets/` | ChatGPT and Codex plugin directory |
| `scripts/build-openai-zip.sh` | builds the ZIP the OpenAI portal takes |

## License

[MIT](LICENSE)
