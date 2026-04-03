# Environment Variables for secrets
export OPENAI_API_KEY=$(op read "op://Personal/OpenAI API Key/credential")
export ANTHROPIC_API_KEY=$(op read "op://Personal/Anthropic API Key/credential")
