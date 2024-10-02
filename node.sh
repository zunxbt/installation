#!/bin/bash

# Function to check if a command is available
check_command() {
    command -v "$1" >/dev/null 2>&1
}

# Function to install NVM
install_nvm() {
    # Change to the home directory to avoid path issues
    cd ~ || exit

    # Install NVM
    echo "Installing NVM..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash

    # Load NVM into the current shell
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
}

# Function to install Node.js and npm
install_node() {
    echo "Installing Node.js..."
    nvm install node
}

# Function to update profile for NVM
update_profile() {
    echo "Updating profile for future sessions..."
    {
        echo "# NVM configuration"
        echo "export NVM_DIR=\"$HOME/.nvm\""
        echo "[ -s \"$NVM_DIR/nvm.sh\" ] && \. \"$NVM_DIR/nvm.sh\""
        echo "[ -s \"$NVM_DIR/bash_completion\" ] && \. \"$NVM_DIR/bash_completion\""
    } >> ~/.bashrc
}

# Check if the user is root
if [ "$(id -u)" -eq 0 ]; then
    echo "Running as root user."
else
    echo "Running as non-root user."
fi

# Check if NVM is installed
if ! check_command "nvm"; then
    echo "NVM is not installed."
    install_nvm
else
    echo "NVM is already installed."
fi

# Load NVM for the current session
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Check if Node.js is installed
if ! check_command "node"; then
    echo "Node.js is not installed."
    install_node
else
    echo "Node.js is already installed."
fi

# Check if npm is installed
if ! check_command "npm"; then
    echo "npm is not installed."
    install_node
else
    echo "npm is already installed."
fi

# Check if paths are exported for the current shell
echo "Current shell paths:"
echo "NVM: $NVM_DIR"
echo "Node: $(command -v node)"
echo "NPM: $(command -v npm)"

# Update profile for future shells if not done
if ! grep -q "NVM_DIR" ~/.bashrc; then
    update_profile
fi

echo "Script execution completed"
