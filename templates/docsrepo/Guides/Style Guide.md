# Style Guide for Docs Repo

Writing and formatting conventions for this docs repo.
Applies to human contributors and AI agents alike.

See [AGENTS.md](../AGENTS.md) for AI agent behaviour and role instructions.

---

## Markdown Format

- Use Markdown format for all outputs, including lists, tables, links, and diagrams (Mermaid).
- Use tables sparingly and only when they add clarity; prefer bullet points and numbered lists
  for most information. Tables are harder to edit manually and can become unwieldy.
- Use headings and subheadings to organise information clearly.
- Avoid long paragraphs; break them into smaller sections with bullet points or numbered lists.
- Use HTML <details>/<summary> tags (which VS Code's Markdown preview supports) for collapsible sections, especially for long content or big imported images.


## Links and References
- Always link to relevant files and sections within the repo for context.
- Use relative links (e.g., `[Goals](../Docs/Goals.md)`
- Use `[Other File](<File with spaces.md>)` link ref syntax for files with spaces in the name. Do not use `%20` encoding unless needed for http URLs, etc.

## File Structure

- Create new files when docs become too long or cover multiple distinct topics.
  Link between files for easy navigation.
- Act on this autonomously when a doc grows beyond 2–3 pages or covers multiple distinct topics. Do not wait for instructions to split docs.
- New docs must follow the overall file layout and naming conventions:
  - Add a folder prefix (e.g., `Reports/`, `Guides/`) to make the type clear.
  - Use dates in file names when archiving old versions.
  - File date format: `YYYY-MM-DD` for easy sorting and consistency.
  - File name formats:
    - `YYYY-MM-DD Short-Description.md` — for reports, reviews, and time-stamped notes
    - `TYPE Short-Description.md` — for guides, how-tos, and reference docs
    - Do not repeat `TYPE` if the folder already indicates it (e.g., `Guides/Style-Guide.md` not `Guides/Guide Style-Guide.md`).

## Text Style

- Write clearly and concisely; avoid unnecessary words and jargon.
- Use British English spelling (e.g., "prioritise" not "prioritize").
- Use ", and" as in scientific writing — not a bare "and" before the last item in a list.
- Propose replacing invented or unclear terms with more intuitive ones.
  Example: "Eng Sync" → "Engineering Sync".
- Write shorter docs by default. Assume common sense on the reader's part.

## Diagrams

- Use Mermaid syntax for diagrams; ensure they are properly formatted and render in Markdown.
- Do not use Gantt charts — they rarely render well.
- Split complex diagrams into multiple simpler ones if needed for clarity.
- In mermaid diagrams, avoid using `\n` these are often rendered literally and break the diagram. Instead, use actual line breaks in the code block for multi-line labels.
