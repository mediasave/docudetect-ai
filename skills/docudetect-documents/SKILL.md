---
name: docudetect-documents
description: Prepare PDFs for e-signature in a DocuDetect account through the DocuDetect MCP server. Use when the user wants to upload a PDF to DocuDetect, detect, place or check signature, text, date and checkbox fields, fill in known values, copy a master form for a new client or property, set who signs, get a document ready to send, or organise DocuDetect documents into folders. Works on drafts only; it never sends or signs.
license: MIT
compatibility: Needs the DocuDetect MCP server (https://docudetect.com/mcp, OAuth sign-in to a DocuDetect account) connected in the agent, and network access.
metadata:
  author: Media Save LLC
  homepage: https://docudetect.com
  version: "1.5.0"
---

# DocuDetect documents

The DocuDetect MCP server holds drafts. It cannot send, sign, remind, cancel or delete; the user does those in the app. Every write tool returns either a result or `{ ok: false, refusal: { code, message } }`. A refusal is the answer: relay its message, and change course only the way the message says. The tools that overwrite data (`save_fields`, `set_field_values`, `set_recipient`, `rename_folder`, `move_to_folder`) are marked destructive, so the app asks the user to approve each call; wait for the approval and never look for a way around it.

1. **Connect.** Call `whoami`. If the DocuDetect tools (`whoami`, `list_documents`, `save_fields` and the rest) are not available, or `whoami` fails with an authorization error, do not improvise with other tools or the website: read [references/connect.md](references/connect.md), give the user the steps for the agent they are using, and stop until they have connected. Note `canWrite`, `limits.maxFieldsPerDocument` and `limits.detectionMaxPages`; with `canWrite` false, only read.
2. **Find or create the document.**
   - Existing: `list_documents` (filter by `folderId`, `status` or `query`), then `get_document`.
   - Another copy of a document the user already has (a master form, a template): `duplicate_document`, not a second upload. See the packet workflow below.
   - New PDF: `start_upload` with the title, filename and exact byte size (and the folder the user named, if any). Tell the user once that the source PDF is stored permanently. If you can run shell commands and read the file, PUT it with the returned `curl` command; otherwise give the user `uploadPageUrl` (they open it signed in to DocuDetect and drop the PDF) and wait until they say it is uploaded. In claude.ai, if the PUT fails because the network blocks docudetect.com, tell the user once that they can let Claude upload attachments directly by allowing docudetect.com under Settings > Capabilities (Code execution and file creation > Allow network egress; on team and enterprise plans an owner sets it under Organization settings > Capabilities), and still give them `uploadPageUrl` now. Both links expire after `limits.uploadLinkMinutes` minutes and take one file. Then `finish_upload`.
3. **Fields.** Positions are fractions of the page from the top-left.
   - Look first: `render_preview` each page that matters and show the images to the user.
   - Suggestions: `detect_fields`, then poll `get_detection` every few seconds until `status` is `done` or `failed`. Its `fields` are suggestions and are not saved; read its `losses`. Detection covers the first `limits.detectionMaxPages` pages (25 today).
   - Agree before saving: list the fields you will save (page, type, label), with the previews beside them, and save only on the user's go-ahead. `save_fields` takes the whole list and the `revision` from your last read; on `stale_revision`, read again and redo the change on the new revision.
   - Prove it: after every save, `render_preview` each changed page from the new revision and show it. A change is done once its page was re-rendered and the user saw it.
4. **Values.** `set_field_values` fills fields that already exist, by field id: `documentId`, the `revision` from your last read, and `values: [{ fieldId, value }]`. Text takes a string, checkbox true or false, date `YYYY-MM-DD`; `null` clears. It changes only values, never positions, so use it, not `save_fields`, to fill a document whose placements the user has adjusted. It is all or nothing: an unknown id, an invalid value or a stale revision saves nothing. It refuses signature fields. Filled values are locked for the signer and printed on the document, so fill only facts the user gave you or the document owner knows, then `get_document` and show the user what was filled.
5. **Losses.** The model holds only signature, text, date and checkbox fields and one signer. When the PDF needs radio groups, initials or more signers (`get_detection` lists some as `losses`), say so plainly and ask how to proceed; `save_fields` refuses other types, it never maps them.
6. **Signer.** `set_recipient` only with a name and email the user gave you in this conversation. Never guess or look up an email.
7. **Hand over.** `check_ready`, then give the user its `url` and the blockers, if any. Say that they review and send it from the app.
8. **Report.** For each document: title, status, `revision`, saved field count and `fieldsHash` from the last `save_fields` or `get_document`, the signer, and the link. Then state what you did not check (for example, "pages 4-9 not previewed", "detection covers the first 25 pages only").

Folders: `list_folders`, `create_folder`, `rename_folder`, `move_to_folder` (`folderId: null` takes documents out of folders). Moving changes nothing else about a document.

Copies: `duplicate_document` takes `documentId` and optionally `title`, `folderId` (omit it to leave the copy ungrouped) and `keepValues` (default false; signature values are never copied). The copy is a new draft at revision 0 with its own copy of the PDF, the same fields, no signer. The source is untouched. Tell the user once that each copy's PDF is stored permanently.

## Listing packet

For a property (or client) that needs a set of forms:

1. One folder per property, named by its address (`create_folder`). Master forms live in a folder of their own (for example Templates); never fill or send a master.
2. `duplicate_document` each form needed from the masters folder into that folder (`folderId`). Copy only the forms that apply, and say which you left out and why (for example a lead-paint form for a house built after 1978).
3. Fill known facts with `set_field_values`, form by form: the listing agent's own profile, usually the user's (name, licence, brokerage, address, phone), property identification (address, county, parcel, legal description only if the user supplied one) and the seller of record. Match each value to the field by what the printed form asks beside it, not by the field label, which can be wrong; render the page first. Show the user the list before you save and the rendered page after.
4. Leave blank, and list for the user as gaps: price, commission, listing term and dates, the seller's contact details unless given, and anything you were not told.
5. Never fill the seller's disclosure answers (seller's property disclosure, latent defects, lead-paint seller section, flood and similar): they are the seller's own statements. Never fill signatures, initials or signing dates. A property-identification header on those forms is fine.
6. Hand over with `check_ready`. Never send, sign, remind, void or delete through the MCP server; the user reviews and sends from the app.
