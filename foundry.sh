#!/bin/bash

# Step 1: Install foundryup using the official installation script from Foundry
curl -L https://foundry.paradigm.xyz | bash

# Step 2: Export Foundry binaries path (for forge, cast, anvil)
if ! grep -q 'export PATH="$HOME/.foundry/bin:$PATH"' ~/.bashrc; then
  echo 'export PATH="$HOME/.foundry/bin:$PATH"' >> ~/.bashrc
fi

if ! grep -q 'export PATH="$HOME/.foundry/bin:$PATH"' ~/.zshrc 2>/dev/null; then
  echo 'export PATH="$HOME/.foundry/bin:$PATH"' >> ~/.zshrc
fi

# Step 3: Source the updated .bashrc or .zshrc to reflect the changes immediately
if [ "$SHELL" = "/bin/bash" ]; then
  export PATH="$HOME/.foundry/bin:$PATH"  # Make it available for the current shell
  source ~/.bashrc                        # For future bash shells
elif [ "$SHELL" = "/bin/zsh" ]; then
  export PATH="$HOME/.foundry/bin:$PATH"  # Make it available for the current shell
  source ~/.zshrc                         # For future zsh shells
fi

# Step 4: Verify installation by running foundryup
foundryup
