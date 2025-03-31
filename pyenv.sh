#!/bin/zsh

# Ensure Pyenv is loaded
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/shims:$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"

# Display Python version before change
echo "🔄 Current Python version before change: $(python --version)"

# Run Pyenv Rehash
hash -r
pyenv rehash

# Display Python version after change
echo "✅ New Python version after change: $(python --version)"

# Auto-refresh the shell so the changes apply immediately
exec zsh
sh /pyenv.sh  && eval "$(pyenv init --path)" && cd ~
