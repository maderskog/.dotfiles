# Environment Variables for secrets
export OPENAI_API_KEY=$(op read "op://Private/OpenAI API Key/credential")
export ANTHROPIC_API_KEY=$(op read "op://Private/Anthropic API Key/credential")
export MAMMOUTH_API_KEY=$(op read "op://Private/Mammouth/api-key")
