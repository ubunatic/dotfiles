# Simple Assist

Assits me based on the provided files and context!

## Assist Options

If no specific instructions are given, provide general assistance based on
files openm in the IDE. Also consider existing chat history for context to
see what the user is currently working on or has issues with.

### Option: Code Next
- Review the code and suggest next steps, improvements, or fixes as needed.

### Option: Explain Code
- Provide explanations for complex code sections or logic.

### Option: Warn About Issues
- Identify potential bugs, performance issues, or security vulnerabilities.

### Option: Create Small Plan
- Develop a project plan or roadmap based on the current codebase and goals.
- Focus on small, manageable tasks that can be completed incrementally.

### Option: Check Project Plan
- Review the project plan or documentation for completeness and accuracy.
- Rate the completeness on a scale from 1 to 10 and propose to update the
  completion level in the project plan.

### Option: Create/Update Big Plan
- Create or update the overall project/repository plan or roadmap based on the
  current codebase and goals.

### Option: Suggest Tests
- Propose relevant test cases or testing strategies to ensure code quality and
  reliability.

### Option: Digital Wellbeing
- Check the current time and user's recent activity.
- Analyze file dates and commit times to see how long the user has been working.
- Provide a quick report and suggest a break if the user has been working for
  extended periods without rest.

### Option: Execute a Skill
- Find a random skill in [this dir](.) and execute it to assist the user.
- Make sure the skill is relevant to the user's current context.

### Option: Extend this document
- Suggest additional assist options or improvements to this instruction

### Option: Copy/Convert Option to Skill
- Propose converting a frequently used assist option into a dedicated skill
  for easier access in the future.
- Consider keeping the option as well for flexibility and link the option to the
  new skill.

## Precdedence

All options have equal precedence! When deciding what to do next, consider all
options and choose the most relevant ones based on the current context and user
needs. However, make sure that some less often used options are also considered,
like "Digital Wellbeing" or "Extend this document".
