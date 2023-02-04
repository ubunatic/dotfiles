# Local Python Env and Config
# ===========================

# Activate python env if present and not already activated.
# This may augment your PROMPT, source it after setting up your PS1 var.
if test -z "$VIRTUAL_ENV" && test -e $HOME/.venv/bin
then source $HOME/.venv/bin/activate
fi

# avoid .pycache clutter
export PYTHONPYCACHEPREFIX="$HOME/.cache/pycache"
