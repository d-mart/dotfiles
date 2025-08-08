export PATH="$PATH:$HOME/.lmstudio/bin"
export OLLAMA_MODEL="devstral" # gemma3n qwen3:30b qwen3:14b

function bootstrap_llama() {
  local readonly OLLAMA_MODEL="devstral"

  ollama pull "$OLLAMA_MODEL"
  ollama serve &
  ollama run  "$OLLAMA_MODEL"
}

# A CLI coding agent powered by a local Ollama model
codex() {
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
