# Connect the DocuDetect MCP server

The skill needs the DocuDetect MCP server connected in the agent. It is a remote Streamable HTTP server:

- URL: `https://docudetect.com/mcp`
- Sign-in: OAuth 2.1 in the browser (dynamic client registration, PKCE). No API key. The user signs in to their DocuDetect account (or creates one at https://docudetect.com) and approves access. The documents app at docudetect.com is called Way of That; it is the same account.
- Scopes: `documents:read` and `documents:write`. Unticking "Upload PDFs as drafts ..." on the approval page gives a read-only connection.

Give the user the steps for the agent they are using, then ask them to come back once it is connected (some agents need a restart or a new session before new tools appear). Never ask the user to paste tokens or passwords into the chat.

## Claude Code

```bash
claude mcp add --transport http --scope user docudetect https://docudetect.com/mcp
```

Then run `/mcp` in a session, pick `docudetect` and sign in (or `claude mcp login docudetect` from a shell).

## Claude.ai and Claude Desktop

Settings > Connectors > Add custom connector, URL `https://docudetect.com/mcp`, then Connect and sign in.

## ChatGPT and the Codex app

Install the DocuDetect plugin from the plugin directory; it connects the server and asks the user to sign in. Until it is listed, in ChatGPT on the web open Plugins > Add custom MCP server (developer mode, available on some plans), enter `https://docudetect.com/mcp`, choose OAuth and sign in.

## Codex CLI

```bash
codex mcp add docudetect --url https://docudetect.com/mcp
codex mcp login docudetect
```

Or in `~/.codex/config.toml`:

```toml
[mcp_servers.docudetect]
url = "https://docudetect.com/mcp"
```

## Gemini CLI

```bash
gemini mcp add --transport http docudetect https://docudetect.com/mcp
```

Then `/mcp auth docudetect` in a session. Or in `~/.gemini/settings.json`:

```json
{ "mcpServers": { "docudetect": { "httpUrl": "https://docudetect.com/mcp" } } }
```

## Cursor (desktop)

`~/.cursor/mcp.json` (all projects) or `.cursor/mcp.json` (one project):

```json
{ "mcpServers": { "docudetect": { "url": "https://docudetect.com/mcp" } } }
```

Then open Cursor Settings > MCP and click the sign-in button next to `docudetect`.

## VS Code (GitHub Copilot)

`.vscode/mcp.json`, or run "MCP: Add Server" and choose HTTP:

```json
{ "servers": { "docudetect": { "type": "http", "url": "https://docudetect.com/mcp" } } }
```

Start the server from the file or the MCP view and sign in when asked.

## OpenCode

In `opencode.json`:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "mcp": { "docudetect": { "type": "remote", "url": "https://docudetect.com/mcp" } }
}
```

Then `opencode mcp auth docudetect`.

## Other agents

Any MCP client that supports remote Streamable HTTP servers with OAuth works if it signs in through a local browser callback (`http://localhost` or `http://127.0.0.1` on any port). Add a server named `docudetect` with URL `https://docudetect.com/mcp` in that agent's MCP settings and sign in.

## When sign-in fails

- "Invalid redirect URI" or similar: the client uses a hosted or custom-scheme callback other than the ones DocuDetect accepts (Claude, ChatGPT and local `http://localhost` or `http://127.0.0.1` callbacks). Use one of the agents above.
- Tools still missing after sign-in: restart the agent or start a new session.
- Access tokens last an hour and are refreshed while the connection stays in use. If calls start failing with an authorization error, sign in again from the agent's MCP settings.
