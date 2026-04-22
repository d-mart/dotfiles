export PATH="$PATH:$HOME/.lmstudio/bin"
export OLLAMA_MODEL="devstral" # gemma3n qwen3:30b qwen3:14b
export OLLAMA_MODELS="$HOME/.ollama"
# Put in local file - not putting here by default for laptops that wander
#export OLLAMA_HOST=0.0.0.0:11434
# -1==forever other values: 5m, 1h, 0 (unload immediately), etc

alias cc="claude --enable-auto-mode --chrome"

# Add LM Studio CLI to PATH if it exists
if [ -x "$HOME/.lmstudio/bin" ]; then
  export PATH="$PATH:$HOME/.lmstudio/bin"
fi

export OLLAMA_KEEP_ALIVE=-1

function bootstrap_llama() {
  local readonly OLLAMA_MODEL="devstral"

  ollama pull "$OLLAMA_MODEL"
  ollama serve &
  ollama run  "$OLLAMA_MODEL"
}

# A CLI coding agent powered by a local Ollama model
asst() {
  # The model to use for the agent
  local model="$OLLAMA_MODEL"

  # The system prompt that primes the model to act as a CLI assistant
  local system_prompt="You are an expert command-line assistant.
  Provide only the command or code snippet requested, with no additional explanation, commentary, or pleasantries.
  Your output will be piped directly into other programs or executed, so it must be clean.
  If asked for a command, provide ONLY the command.
  If asked to refactor code, provide ONLY the refactored code."

  # Combine the prompt into a single variable for Ollama
  local prompt="$@"

  # Run Ollama non-interactively with the system prompt and user query
  ollama run "$model" "$system_prompt\n\nUser: $prompt\n\nAssistant:"

}

# One-shot query helper for installed LLM CLIs.
llmq() {
  local provider="$1"

  if [ -z "$provider" ]; then
    echo "usage: llmq {claude|gemini|copilot} <prompt>" >&2
    return 2
  fi

  shift

  local prompt="$*"
  if [ -z "$prompt" ]; then
    echo "error: prompt is required" >&2
    echo "usage: llmq {claude|gemini|copilot} <prompt>" >&2
    return 2
  fi

  case "$provider" in
    claude)
      if ! command -v claude > /dev/null 2>&1; then
        echo "error: claude is not installed or not in PATH" >&2
        return 127
      fi
      claude --print "$prompt"
      ;;
    gemini)
      if ! command -v gemini > /dev/null 2>&1; then
        echo "error: gemini is not installed or not in PATH" >&2
        return 127
      fi
      gemini --prompt "$prompt"
      ;;
    copilot)
      if ! command -v copilot > /dev/null 2>&1; then
        echo "error: copilot is not installed or not in PATH" >&2
        return 127
      fi
      copilot -p "$prompt" -s
      ;;
    *)
      echo "usage: llmq {claude|gemini|copilot} <prompt>" >&2
      return 2
      ;;
  esac
}

alias haiku='llmq claude'
alias gemq='llmq gemini'
alias copq='llmq copilot'
