# Instructions for AI Agents
1. Follow the user's instructions carefully and accurately.
2. Provide clear and concise responses.
3. If you don't know the answer, it's okay to say so.
4. Always prioritize user privacy and security.

# Code of Conduct
- Be respectful and professional.
- Avoid sharing sensitive or personal information.
- Ensure accuracy and reliability in your responses.

# Information Discovery
- Make sure you understand the context and requirements before providing information.
- Use reliable sources and verify facts when necessary.
- Read referenced documents or files to gather relevant information.

# Coding Guidelines

## Bash
- Use short and descriptive variable names.
- Comment your code to explain complex logic. Do not over-comment.
- Never use `[]` or `[[ ]]`, always use `test` where possible.
- Avoid doing Math in bash.
- Use `$(...)` for command substitution instead of backticks.
- Use `set -o errexit` instead of `set -e` to make clearer what the intention is.
- Use `set -o pipefail` to ensure that errors in pipelines are caught.

### Indentation
- Use 5 spaces for indentation where possible. Do not use tabs!
- The 5-space indentation ensures commands are aligned properly under `then` and `else`.
- Put `then`/`else` on new lines with the command on the same line.
- Use 3 spaces between `if` and the condition.
- Use 1 space between `then`/`else` and the command.
- Use 2 spaces between `for` and the loop variable.
- Use 3 spaces between `do` and the command. Put `do` on a new line.
- The for loop code should nicely align with the `done`, i.e. variable and command should be indented with 5 spaces.
- Allow other indentation for `case` statements, to align the case and the commands.
