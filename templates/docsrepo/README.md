# My Docs in Git/IDEs

This repo holds my personal notes and documentation — a central place to organise
and access information across projects and learning topics.

## Why Git/IDEs?
- Version control tracks changes and enables rollback
- AI writes and formats fast
- AI creates diagrams as text (Mermaid)
- AI agents brainstorm and organise information
- Markdown enforces clear, concise writing

## Overall Structure

- Each topic has its own folder with a README.md file that contains the main documentation for that topic.
- Each topic folder may have a `ref` subfolder that contains references, such as links, articles, and other resources related to the topic.
- The topic README.md must link and summarize the contents of the `ref` subfolder.
- The topic README.md must also link and briefly summarize all subdocs in the topic folder, if any.
- Topic folder can have subtopic folders, which follow the same structure as the main topic folder.

Actual top-level structure:

```
docs/
├── Docs/         # general notes: goals, meetings, progress, career, etc.
├── Guides/       # how-to guides and conventions for this repo
├── People/       # people management: 1-on-1s, onboarding, team info, hiring, reviews
├── Private/      # personal / private notes (access-restricted for AI agents)
└── Projects/     # project documentation: load testing, data pipeline, schema design, etc.
```

## Guides

See [Guides/Style Guide.md](<Guides/Style Guide.md>) for writing and formatting conventions.
See [Guides/Getting Started.md](<Guides/Getting Started.md>) for initial setup and trial tasks.
See [DocsRepo.md](DocsRepo.md) for the daily workflow.

## Topics Covered

See [Topics](./Docs/Topics.md) for a list of topics covered in this docs repo.
See [Context](./Docs/Context.md) for the current working context.