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

check_command() {
    command -v "$1" >/dev/null 2>&1
}

install_package() {
    if ! check_command "$1"; then
        show "Installing $1..." "progress"
        if ! sudo apt-get install -y "$1"; then
            show "Error: Failed to install $1" "error"
            exit 1
        fi
    else
        show "$1 is already installed."
    fi
}

update_package_list() {
    show "Updating package list..." "progress"
    if ! sudo apt-get update; then
        show "Error: Failed to update package list" "error"
        exit 1
    fi
}

install_curl() {
    install_package curl
}

add_docker_gpg_key() {
    if ! sudo apt-key list | grep -q "Docker"; then
        show "Adding Docker GPG key..." "progress"
        if ! curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -; then
            show "Error: Failed to add Docker GPG key" "error"
            exit 1
        fi
    else
        show "Docker GPG key is already added."
    fi
}

install_docker() {
    update_package_list

    for tool in apt-transport-https ca-certificates software-properties-common; do
        install_package "$tool"
    done

    install_curl

    add_docker_gpg_key

    show "Adding Docker repository..." "progress"
    if ! sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"; then
        show "Error: Failed to add Docker repository" "error"
        exit 1
    fi

    update_package_list

    show "Installing the latest version of Docker..." "progress"
    if ! sudo apt-get install -y docker-ce docker-ce-cli containerd.io; then
        show "Error: Failed to install Docker" "error"
        exit 1
    fi

    show "Reloading Docker daemon..." "progress"
    if ! sudo systemctl daemon-reload; then
        show "Error: Failed to reload Docker daemon" "error"
        exit 1
    fi

    show "Enabling and starting Docker service..." "progress"
    if ! sudo systemctl enable docker; then
        show "Error: Failed to enable Docker service" "error"
        exit 1
    fi

    if ! sudo systemctl start docker; then
        show "Error: Failed to start Docker service" "error"
        exit 1
    fi

    if ! groups "$USER" | grep -q '\bdocker\b'; then
        show "Adding $USER to the docker group..." "progress"
        if ! sudo usermod -aG docker "$USER"; then
            show "Error: Failed to add user to the docker group" "error"
            exit 1
        fi
        show "Please log out and log back in for the group changes to take effect."
    else
        show "$USER is already in the docker group."
    fi
}

install_docker_compose() {
    if ! check_command docker-compose; then
        show "Installing Docker Compose..." "progress"
        ARCH=$(uname -m)
        if [[ "$ARCH" == "x86_64" ]]; then
            ARCH="amd64"
        elif [[ "$ARCH" == "aarch64" ]]; then
            ARCH="arm64"
        else
            show "Unsupported architecture: $ARCH" "error"
            exit 1
        fi

        if ! sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$ARCH" -o /usr/local/bin/docker-compose; then
            show "Error: Failed to download Docker Compose for architecture $ARCH" "error"
            exit 1
        fi

        if ! sudo chmod +x /usr/local/bin/docker-compose; then
            show "Error: Failed to make Docker Compose executable" "error"
            exit 1
        fi
    else
        show "Docker Compose is already installed."
    fi
}

validate_installation() {
    show "Validating Docker installation..." "progress"
    if ! docker --version; then
        show "Error: Docker installation verification failed" "error"
        exit 1
    fi

    show "Validating Docker Compose installation..." "progress"
    if ! docker-compose --version; then
        show "Error: Docker Compose installation verification failed" "error"
        exit 1
    fi

    show "Docker and Docker Compose are installed successfully!"
}

add_to_path() {
    if ! echo "$PATH" | grep -q "/usr/local/bin"; then
        show "Adding /usr/local/bin to PATH..." "progress"
        echo 'export PATH="/usr/local/bin:$PATH"' >> ~/.bashrc
        if [ $? -eq 0 ]; then
            show "/usr/local/bin has been added to PATH. Please run 'source ~/.bashrc' or restart your terminal."
        else
            show "Error: Failed to add /usr/local/bin to PATH" "error"
        fi
    else
        show "/usr/local/bin is already in your PATH."
    fi
}

show "Checking if Docker is already installed..." "progress"
if check_command docker; then
    show "Docker is already installed. Validating the installation..."
    validate_installation
    add_to_path
else
    install_docker
    install_docker_compose
    validate_installation
    add_to_path
fi

show "Docker installation and PATH setup complete."
