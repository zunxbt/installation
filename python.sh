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

check_python_installed() {
    if command -v python3 >/dev/null 2>&1; then
        show "Python 3 is already installed."
        return 0
    else
        show "Python 3 is not installed." "error"
        return 1
    fi
}

check_pip_installed() {
    if command -v pip3 >/dev/null 2>&1; then
        show "pip3 is already installed."
        return 0
    else
        show "pip3 is not installed." "error"
        return 1
    fi
}

install_python() {
    show "Installing Python 3 and pip..." "progress"
    sudo apt update
    sudo apt install -y python3 python3-pip

    show "Python and pip installation complete."
}

install_dev_tools() {
    show "Installing essential development tools..." "progress"
    sudo apt install -y build-essential libssl-dev libffi-dev python3-dev

    show "Development tools installed successfully."
}

install_virtualenv() {
    show "Installing virtualenv..." "progress"
    pip3 install virtualenv

    show "virtualenv installed."
}

add_python_to_path() {
    if grep -q "python3" "$HOME/.bashrc" || grep -q "python3" "$HOME/.zshrc"; then
        show "Python is already added to PATH."
    else
        show "Adding Python to PATH..." "progress"
        if [ -f "$HOME/.bashrc" ]; then
            echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
        elif [ -f "$HOME/.zshrc" ]; then
            echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.zshrc"
        else
            echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.profile"
        fi
    fi
}

validate_python() {
    show "Validating Python and pip installation..." "progress"

    if ! command -v python3 >/dev/null 2>&1; then
        show "Error: Python is not installed properly." "error"
        return 1
    else
        show "Python 3 is working fine in the current session."
    fi

    if ! command -v pip3 >/dev/null 2>&1; then
        show "Error: pip3 is not installed properly." "error"
        return 1
    else
        show "pip3 is working fine in the current session."
    fi

    future_shell_test=$(bash -c "command -v python3 && command -v pip3")
    if [ -z "$future_shell_test" ]; then
        show "Error: PATH not properly set for future shell sessions." "error"
        return 1
    else
        show "Python and pip are set up correctly for future shell sessions."
    fi

    return 0
}

show "Checking if Python 3 is already installed..." "progress"
if check_python_installed; then
    show "Python 3 is already installed. Checking pip3..."
    if ! check_pip_installed; then
        install_python
    fi
    validate_python
else
    install_python
    install_dev_tools
    install_virtualenv
    add_python_to_path
    validate_python
fi

show "Python installation and setup complete."
