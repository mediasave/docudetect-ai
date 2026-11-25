<p align="center"><img src="assets/logo.png" alt="DocuDetect" width="96" height="96"></p>

# DocuDetect for AI assistants

Plugin, extension and agent skill for [DocuDetect](https://docudetect.com), the e-signature app. Connect it to Claude, Cursor, Gemini CLI, Codex, ChatGPT or any agent that loads `SKILL.md` skills, and the assistant can prepare, send and track PDFs for signature in your DocuDetect account. It can:

- upload a PDF as a draft;
- detect, preview, check and place signature, initials, text, date and checkbox fields;
- fill in values you give it;
- copy a master form for each new client or property;
- set the signer and send when you ask;
- see whether the signer opened or signed, and remind or cancel;
- organise folders.

It never signs or deletes.

| Skill | What it does |
|-------|--------------|
| [`docudetect-documents`](skills/docudetect-documents/SKILL.md) | The workflow: connect, find or create a draft, agree and save fields, fill values, send and track. |

The skill drives the DocuDetect MCP server at `https://docudetect.com/mcp`. You sign in with your DocuDetect account in the browser (OAuth); there is no API key. You need a DocuDetect account: create one free at [docudetect.com](https://docudetect.com).

## Install

**Claude Code** (plugin: skill and server together)

```
/plugin marketplace add mediasave/docudetect-ai
/plugin install docudetect@docudetect-ai
```

Then run `/mcp`, pick `docudetect` and sign in.

**Claude.ai and Claude Desktop** (Pro, Max, Team or Enterprise): Customize > Plugins > Add > **Add marketplace**, enter `mediasave/docudetect-ai`, install `docudetect`, then open the plugin's **Connectors** tab and connect DocuDetect. To add only the connector: Settings > Connectors > Add custom connector, URL `https://docudetect.com/mcp`.

**Cursor**: install DocuDetect from the Cursor Marketplace, or add only the server with one click:

[![Add DocuDetect MCP server to Cursor](https://cursor.com/deeplink/mcp-install-dark.svg)](https://cursor.com/install-mcp?name=docudetect&config=eyJ1cmwiOiJodHRwczovL2RvY3VkZXRlY3QuY29tL21jcCJ9)

Then open Cursor Settings > MCP and sign in next to `docudetect`.

**Gemini CLI** (extension: skill and server together)

```bash
gemini extensions install https://github.com/mediasave/docudetect-ai
```

Then run `/mcp auth docudetect` in a session.

**Any agent with skills** (Codex, GitHub Copilot, OpenCode and others)

```bash
npx skills add mediasave/docudetect-ai
```

Add `-g` for all your projects, or `-a codex`, `-a cursor` and so on to pick agents. Then connect the server: per-agent steps are in [connect.md](skills/docudetect-documents/references/connect.md). If the server is not connected, the skill tells the agent to show you these steps instead of guessing.

**ChatGPT and Codex**: a DocuDetect plugin for the ChatGPT and Codex plugin directory is in review. Until it is listed, add `https://docudetect.com/mcp` as a custom MCP server (steps in [connect.md](skills/docudetect-documents/references/connect.md)).

## What the agent can and cannot do

- It sends a document only when you ask, after showing you the signer and the fields. Sending needs the "Send documents" permission on the approval page; untick it and you send from the app yourself. It cannot sign or delete: the MCP server has no tools for those.
- It shows you the fields it plans to save, saves them only when you agree, then shows each changed page again so you can check it.
- It sets the signer only from a name and email you gave it, and fills only values you gave it. It never fills signatures, initials, signing dates or another person's statements.
- Uploaded PDFs and copies are stored permanently in your account.

## Data and privacy

This repository holds instructions and configuration only. It stores nothing and runs no code. Through the MCP server, your assistant sends document titles, field positions and values, signer names and emails, and the PDFs you upload to your DocuDetect account at docudetect.com. Every change made through the server is recorded in an audit log. See the [privacy policy](https://docudetect.com/privacy) and [terms](https://docudetect.com/terms).

## Support

- Troubleshooting: [docudetect.com/ai/troubleshooting](https://docudetect.com/ai/troubleshooting)
- Contact: [contact@docudetect.com](mailto:contact@docudetect.com) or [docudetect.com/contact](https://docudetect.com/contact)
- Problems with this package: open an issue in this repository.

## Layout

| Path | Used by |
|------|---------|
| `skills/docudetect-documents/` | every target (skills.sh, Claude, Cursor, Gemini CLI, Codex, ChatGPT) |
| `.claude-plugin/plugin.json`, `.mcp.json` | Claude Code and the Claude plugin directory |
| `.claude-plugin/marketplace.json` | `/plugin marketplace add` (this repo is its own marketplace) |
| `.cursor-plugin/` | Cursor Marketplace and cursor.directory |
| `gemini-extension.json` | Gemini CLI extension |
| `plugin.json`, `mcp.json`, `assets/` | ChatGPT and Codex plugin directory |
| `scripts/` | build the upload ZIPs for the OpenAI portal and claude.ai |

## License

[MIT](LICENSE). DocuDetect is operated by Media Save LLC.
