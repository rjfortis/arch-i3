#!/usr/bin/env bash
set -e

BASHRC="$HOME/.bashrc"

echo "Updating $BASHRC..."

# Bash completion
if ! grep -q "bash-completion/bash_completion" "$BASHRC" 2>/dev/null; then
cat >> "$BASHRC" <<'EOF'

# Bash completion
if [ -r /usr/share/bash-completion/bash_completion ]; then
  source /usr/share/bash-completion/bash_completion
fi
EOF
fi

# Mise activation
if ! grep -q "mise activate bash" "$BASHRC" 2>/dev/null; then
cat >> "$BASHRC" <<'EOF'

# Mise activation (if available)
if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate bash)"
fi
EOF
fi

echo "Done. Open a new shell or run: source ~/.bashrc"
