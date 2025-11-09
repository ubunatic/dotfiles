#!/usr/bin/env bash
#
# Script help building AI prompts with context information

set -o errexit
set -o pipefail

# define default values for all variables
# default chat command is 'gemini' in interactive mode.

default_files="$(echo AGENTS.md Makefile "$0" "$CHAT_SKILL_FILE")"
skill_dirs="
.ai/instructions/skills
.ai/instructions/simple
.ai/instructions
.ai/skills
.github/instructions/skills
.github/instructions
.spec/skills
"

DOTFILES="${DOTFILES:-"$HOME/git/.dotfiles"}"

CHAT_CMD="${CHAT_CMD:-gemini --prompt-interactive}"
CHAT_INVOKER="${CHAT_INVOKER:-$0}"
CHAT_SKILL="${CHAT_SKILL:-assist}"
CHAT_FILES="${CHAT_FILES:-$default_files}"
# CHAT_PROMPT is set externally or via args
# CHAT_SKILL_FILE is set later if needed

log() { echo -n "[ai-prompt] INF "        >/dev/stderr; echo "$@" >/dev/stderr; }
err() { echo -n "[ai-prompt] ERR " >/dev/stderr; echo "$@" >/dev/stderr; }
dbg() {
     if test -n "$DEBUG"
     then echo -n "[ai-prompt] DBG: " >/dev/stderr; echo "$@" >/dev/stderr;
     fi
}

prompt_skill_file() {
     if test -n "$CHAT_SKILL_FILE"
     then echo "$CHAT_SKILL_FILE"; return
     fi
     for dir in $skill_dirs
     do   local file="$dir/$CHAT_SKILL.md"
          if test -f "$file"
          then echo "$file"; return
          else dbg "skill file '$file' not found in '$dir', skipping"
          fi
     done
     err "Skill file for skill '$CHAT_SKILL' not defined and not found in any of the skill directories: $skill_dirs."
}

# find the referenced and default prompt files
prompt_files() {
     for file in $CHAT_FILES
     do   if test -f "$file"
          then echo -e "\t$file"
          else dbg "context file '$file' not found, skipping"
          fi
     done
}

prompt_vars() {
     local CHAT_SKILL_FILE="${CHAT_SKILL_FILE:-".ai/instructions/simple/$CHAT_SKILL.md"}"
     cat <<-EOF
CHAT_CMD="$CHAT_CMD"
CHAT_SKILL="$CHAT_SKILL"
CHAT_SKILL_FILE="$(prompt_skill_file)"
CHAT_FILES="
$(prompt_files)
"
CHAT_INVOKER="$CHAT_INVOKER"
EOF
}

prompt_vars_debug() {
     if test -n "$DEBUG"
     then prompt_vars
     fi
}

prompt_print() {
     # NOTE: We add an empty line to not start the prompt with a '-', since some
     #       A CLI tools (like gemini) get confused.
     local CHAT_SKILL_FILE="$(prompt_skill_file)"
     cat <<-EOF
<!-- context -->
$(prompt_vars)
CWD="$(pwd)"
<!-- prompt -->
Use your skill '$CHAT_SKILL' as defined in the file '$CHAT_SKILL_FILE',
respecting the context provided in the CHAT_FILES above, and following the
instructions below.

$CHAT_PROMPT
$*
EOF
}

# For quick reference, return the first 100 characters of the prompt
prompt_preview() {
     prompt_vars_debug
     local prompt preview
     if test -z "$CHAT_PROMPT" && test $# -eq 0
     then prompt="Default prompt for skill '$CHAT_SKILL'"
     else prompt="Prefix prompt for skill '$CHAT_SKILL'. $*"
     fi

     preview="$(echo "$prompt" | cut -c1-100 | tr '\n' ' ')"
     if test "${#prompt}" -gt 100
     then preview="$preview..."
     fi
     echo "$preview"
}

prompt_run() {
     if test -z "$CHAT_CMD"
     then err "CHAT_CMD is not defined."
     fi
     $CHAT_CMD "$(prompt_print "$@")"
}

prompt_selftest() {
     if test -f "$DOTFILES/shell/assert.sh"
     then source "$DOTFILES/shell/assert.sh"
          assert ok "assert.sh loaded successfully"
     else err "Self-test requires assert.sh from dotfiles shell library."
          return 1
     fi
     log "Running self-test of ai-prompt.sh"
     (
          main preview -s assist       | assert contains "prompt for skill 'assist'"
          main preview -s assist "123" | assert contains "prompt for skill 'assist'. 123"
          main prompt  -s assist       | assert contains "Use your skill 'assist' as defined in the file"
          main prompt  -s assist "123" | assert line "123"
          main vars    -s assist       | assert contains 'CHAT_SKILL="assist"'
          main run     -s assist -c 'echo TESTCMD:' "123" |
               assert all "TESTCMD:" "skill 'assist'" 'CHAT_SKILL="assist"' "123"
          main help 2>&1 | assert contains "Usage:"
          main preview "this is a test prompt" | assert contains this is a test prompt
          if main foo 2>&1
          then assert fail "unknown command did not fail as expected"
          fi | assert contains "Unknown command"
     ) >/dev/stderr

     log "Self-test completed."
}

prompt_usage() {
     prompt_vars_debug
     cat <<-EOF
Usage: $0 [command]

Commands:
  help       Show this help message
  preview    Show first 100 characters of the prompt for quick reference
  print      Show full prompt with context information
  run        Run the chat command with the prompt
  vars       Show the current chat variable settings
  chat       Alias for 'run'
  test       Run self-tests of the script

Options:
  -h, --help                    Show this help message
  -c, --chat, --cmd CMD         Override the chat command to use
  -s, --skill SKILL             Override the chat skill to use
  -S, --skill-file FILE         Override the chat skill file to use
  -f, --files FILES             Override the chat context files to use
  -a, --add-file FILE           Add a file to the chat context files
  -d, --debug, -v, --verbose    Enable debug output
  --invoker INFO                Override the info about the command invoking the chat

EOF
}

main() {
     dbg "AI Prompt Builder started"

     if arg1="$1" && shift
     then dbg "command specified: '$arg1'"
     else dbg "no command specified"
          prompt_usage
          return 0
     fi

     # set a default command in case of bugs (must be overridden later)
     cmd="err 'No command specified.'; false"

     dbg "parsing command: '$arg1'"

     case "$arg1" in
          # valid commands
          preview)      cmd="prompt_preview" ;;
          print|prompt) cmd="prompt_print"   ;;
          run|chat)     cmd="prompt_run"     ;;
          vars)         cmd="prompt_vars"    ;;
          test)         cmd="prompt_selftest" ;;

          # anything else must exit (with info or error)
          help|-h|--help)
               prompt_usage; return 0
               ;;
          *)
               err "Unknown command: '$arg1'. Use '--help' to see available commands."
               return 1
               ;;
     esac

     dbg "parsing options for command: '$arg1'"

     # parse options in std. while-case loop
     while test $# -gt 0; do case "$1" in
          # options
          -h|--help)       prompt_usage; return 0 ;;
          -c|--chat|--cmd) CHAT_CMD="$2";               shift 2 ;;
          -s|--skill)      CHAT_SKILL="$2";             shift 2 ;;
          -S|--skill-file) CHAT_SKILL_FILE="$2";        shift 2 ;;
          -f|--files)      CHAT_FILES="$2";             shift 2 ;;
          -a|--add-file)   CHAT_FILES="$CHAT_FILES $2"; shift 2 ;;
          --invoker)       CHAT_INVOKER="$2";           shift 2 ;;

          # flags
          -d|--debug|-v|--verbose) DEBUG="1"; shift ;;

          # anything else
          *) break ;;  # no more options, the rest must be prompt content
     esac; done

     # args are now shifted to the prompt content (if any), we can pass them to the command

     dbg "command $cmd starting with $# extra prompt words"
     $cmd "$@"
     dbg "command $cmd completed"
}

main "$@"
