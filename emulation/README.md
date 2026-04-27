# Threat Emulation Staging Folder

Use this folder to stage files for the optional Check Point Threat Emulation MCP.

Supported workflow:

- Copy or move files into `emulation/`
- Or download files here from the terminal, for example:

```bash
cd emulation
wget <URL>
```

Then ask OpenCode to scan the file by path, for example:

- `Scan emulation/suspicious.pdf with Threat Emulation and summarize the verdict.`
- `Analyze emulation/invoice.docm with the threat-emulation MCP.`

Important limitation:

- Uploading or attaching a file directly in the OpenCode chat is not the supported Threat Emulation workflow in this repository.
- The Threat Emulation MCP reads files from disk by path, so the file must already exist locally.
