# STILL IN ALPHA

# About

This is a Godot powered Discord Bot that allows you to chat with local LLM, handled by different agents.

At the moment, though, this just forwards chat requests to a Ollama agent.

Supported so far :
* Autoregistering Discord commands
* Manage user prompts though a Discord modal
* Creating answer threads
* Handling chat by the user within that thread

There's still a ton of design issues here and there, so it's VERY FAR from ready.
The bot, for example, still cannot handle reconnecting to Discord if it gets disconnected !

# Configuration

Copy the .env.sample file to .env and fill it with the appropriate information.
