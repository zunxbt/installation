#!/bin/bash

# Step 1: Install foundryup using the official installation script from Foundry
curl -L https://foundry.paradigm.xyz | bash

# Step 2: Export Foundry binaries path (for forge, cast, anvil)
if ! grep -q 'source ~/.foundry/bin' ~/.bashrc; then
  echo 'source ~/.foundry/bin' >> ~/.bashrc
fi

if ! grep -q 'source ~/.foundry/bin' ~/.zshrc; then
  echo 'source ~/.foundry/bin' >> ~/.zshrc
fi

# Step 3: Source the updated .bashrc or .zshrc to reflect the changes immediately
if [ "$SHELL" = "/bin/bash" ]; then
    source ~/.foundry/bin  # Make it available for the current shell
    source ~/.bashrc       # For future bash shells
elif [ "$SHELL" = "/bin/zsh" ]; then
    source ~/.foundry/bin  # Make it available for the current shell
    source ~/.zshrc        # For future zsh shells
fi

# Step 4: Verify installation by running foundryup
foundryup
