all: start

models:
	ollama create m4-coder -f m4-coder.Modelfile
	ollama create fast-coder -f fast-coder.Modelfile

env:
	launchctl setenv OLLAMA_FLASH_ATTENTION 1 || true

DEBUG=
ifeq ($(DEBUG),)
detached = >/dev/null 2>&1 & \# run detached
else
detached = \# run in foreground for debugging
endif

ollama: models
	killall ollama || true
	OLLAMA_FLASH_ATTENTION=1 ollama serve $(detached)
	@echo "Starting ollama serve in background..."
	@sleep 1
	@echo "Available models:"
	@ollama list

export OLLAMA_API_BASE=http://127.0.0.1:11434
MODEL=fast-coder
aider:
	@echo "Using OLLAMA_API_BASE=$(OLLAMA_API_BASE)"
	curl -s ${OLLAMA_API_BASE}/v1/models | jq .data[].id
	@echo "Starting aider with model MODEL=$(MODEL)"
	cd .. && aider --model ollama_chat/$(MODEL) --watch-files

restart: stop ollama aider

aider_pids=$(shell pgrep -f "aider --model ollama_chat/$(MODEL)")
stop:
	@echo "Stopping aider and ollama processes..."
	@killall ollama || true
	@test -z "$(aider_pids)" || kill $(aider_pids)
	@echo "Remaining aider processes (should be none):"
	@pgrep -f "aider" || true
	@pgrep -f "ollama" || true
