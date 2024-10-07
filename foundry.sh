#!/bin/bash

BOLD=$(tput bold)
NORMAL=$(tput sgr0)
PINK='\033[1;35m'

show() {
    case $2 in
        "error")
            echo -e "${PINK}${BOLD}❌ $1${NORMAL}"
            ;;
        "progress")
            echo -e "${PINK}${BOLD}⏳ $1${NORMAL}"
            ;;
        *)
            echo -e "${PINK}${BOLD}✅ $1${NORMAL}"
            ;;
    esac
}

check_foundry_installed() {
    if command -v forge >/dev/null 2>&1; then
        show "Foundry is already installed."
        return 0
    else
        return 1
    fi
}

install_foundry() {
    show "Installing Foundry..." "progress"
    curl -L https://foundry.paradigm.xyz | bash

    export PATH="$HOME/.foundry/bin:$PATH"

    show "Installing essential tools: cast, anvil..." "progress"
    foundryup
}

add_foundry_to_path() {
    if grep -q "foundry/bin" "$HOME/.bashrc" || grep -q "foundry/bin" "$HOME/.zshrc"; then
        show "Foundry is already added to PATH."
    else
        show "Adding Foundry to PATH..." "progress"

        if [ -f "$HOME/.bashrc" ]; then
            echo 'export PATH="$HOME/.foundry/bin:$PATH"' >> "$HOME/.bashrc"
        elif [ -f "$HOME/.zshrc" ]; then
            echo 'export PATH="$HOME/.foundry/bin:$PATH"' >> "$HOME/.zshrc"
        else
            echo 'export PATH="$HOME/.foundry/bin:$PATH"' >> "$HOME/.profile"
        fi
    fi
}

validate_path() {
    show "Validating PATH setup..." "progress"
    if ! command -v forge >/dev/null 2>&1 || ! command -v cast >/dev/null 2>&1 || ! command -v anvil >/dev/null 2>&1; then
        show "Error: PATH not properly set in the current session." "error"
        return 1
    else
        show "Foundry tools are working fine in the current session."
    fi

    future_shell_test=$(bash -c "command -v forge && command -v cast && command -v anvil")
    if [ -z "$future_shell_test" ]; then
        show "Error: PATH not properly set for future shell sessions." "error"
        return 1
    else
        show "Foundry tools are working fine in future shell sessions."
    fi

    return 0
}

show "Checking if Foundry is already installed..." "progress"
if check_foundry_installed; then
    show "Foundry is already installed. Validating the PATH setup..."
    validate_path
else
    install_foundry
    add_foundry_to_path
    validate_path
fi

show "Foundry installation and PATH setup complete."
