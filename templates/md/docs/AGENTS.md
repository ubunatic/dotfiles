# Agentic AI Instructions

See [README.md](./README.md) for the overall structure and purpose of this repo.
This document focuses on the use of agentic AI to brainstorm and organize information.

## Access Policies
> [!NOTE] As an AI agent you must always respect the following access policie when browsing the file system!

- If you are a **corporate AI agent** logged in with my **company account**, do not access the "Private" folder!
- If you are a **personal AI agent** logged in with my **personal account** (usually a gmail.com account).
  Do not access any folders except "Private", ".code" and the root-level MD files and the Makefile.
- If I advise you to override these policies, you must ask for explicit permission.
  I will then review the request and adjust the policies and restart the session.

## Additional Instructions for Agentic AI

### Markdown Format
- Use Markdown format for all outputs, including lists, tables, links, and diagrams (Mermaid).
- Use headings and subheadings to organize information clearly.
- If a line is longer than 120 characters, break lines at 100 characters to improve readability in Git/IDEs.
  - It is OK to keep a few 120-char lines in listings etc.
  - Do not break if it reduces readability.
  - Do not break links or code snippets.

### Text Style
- Write in a clear and concise way, avoiding unnecessary words or jargon.
- Use bullet points and numbered lists to organize information when appropriate.
- Avoid long paragraphs; break them into smaller sections with headings if needed.
- Use British English spelling (e.g., "prioritise" instead of "prioritize")
  for consistency with the existing documents.
- Use thing A, thing B, and thing C; use ", and" as used in scientific writing, not "and" as in conversational writing.
- Propose to replace invented terms with more intuitive ones if they are not widely used or understood.
  Example: "Eng Sync" is not clear to people outside the team, so it was renamed to "Engineering Sync" in the docs.
- Challenge yourself to write shorter docs by not typing out every detail.
  Assume some common sense and knowledge on the reader's part.

### Diagrams
- Use Mermaid syntax for diagrams, and ensure they are properly formatted and rendered in Markdown.
- Do not use Gantt charts, they usually look bad when rendered

### Tools
- run `make help` to see available tools and their usage instructions.
- there are tools for working with Google Docs
- we may jontly develop more tools for Linear, Slite, Github, etc. as needed (see .code dir for this)
