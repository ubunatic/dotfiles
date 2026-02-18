# My Docs in Git/IDEs

In this repo, I keep my personal notes and documentation.
It serves as a central place for me to organize and access information on various topics needed for my projects and learning.

## Why Git/IDEs?
- use version control to track changes
- use AI to write fast
- use AI to create diagrams as text (Mermaid)
- use AI agents to brainstorm and organize information
- force myself to write in a clear and concise way with Markdown as common format that encourages condensation of information

## Overall Structure

- Each topic has its own folder with a README.md file that contains the main documentation for that topic.
- Each topic folder may have a `ref` subfolder that contains references, such as links, articles, and other resources related to the topic.
- The topic README.md must link and summarize the contents of the `ref` subfolder.
- The topic README.md must also link and breifly summarize all subdocs in the topic folder, if any.
- Topic folder can have subtopic folders, which follow the same structure as the main topic folder.

Example structure:

```
- topic1/
  - README.md       # contains the main documentation for topic1, and links to all subdocs and references
  - ref/            # contains references for topic1
    - article1.md
    - article2.md
  - subdoc1.md
  - subdoc2.md
- topic2/
  - README.md
  - subtopic1/
    - README.md
    - ref/
      - article3.md
  - subtopic2/
    - README.md
```

## Topics Covered

See [Topics](./TOPICS.md) for a list of topics covered in this docs repo.
