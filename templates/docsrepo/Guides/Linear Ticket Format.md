# Linear Ticket Format

Conventions for writing Linear tickets — applies to human authors and AI agents.

---

## Structure

A good ticket has three sections:

1. As a [persona], I want to [action] so that [outcome].
2. **Acceptance Criteria** — past-tense statements describing the done state
3. **Background / Problem** — context, what is broken or missing

---

## Acceptance Criteria

Write acceptance criteria in the **past tense**, as if the work is already done:

```markdown
## Acceptance Criteria

- [ ] Fact 1 has become true
- [ ] Requirement 2 is now met
- [ ] Problem 3 does not occur anymore
```

Avoid imperative phrasing ("Add X", "Fix Y") in acceptance criteria.

Use `- [ ]` checkbox syntax. Nest sub-items with two-space indentation

```markdown
- [ ] Problem A is resolved
  - [ ] The root cause of A is identified and fixed
  - [ ] A post-mortem document is created summarizing the issue and resolution
  - [ ] AI agents will watch for similar patterns in the future

---

## Example

```markdown
As a backend engineer, I need to observe structured logs during load testing so that I can identify bottlenecks and optimize performance.

## Acceptance Criteria
- [ ] The system supports structured logging in the load testing stage
   - [ ] Logs include timestamps, log levels, and contextual information
   - [ ] Logs in Go use `slog.<level>()` and not a custom wrapper

## Background / Problem
The initial implementation of the load testing framework only captures unstructured logs, making it difficult to analyze performance issues. This ticket aims to enhance the logging capabilities to support structured logs, which will facilitate better debugging and optimization during load testing.
```
