#!/bin/bash
# Bloqbit Installation Script
# Server Files: /mnt/server

# Inherited from node.js generic egg https://www.pterodactyleggs.com/egg/673601c24924a4e9bbd4bed3/

# Constants
GIT_ADDRESS="https://github.com/CubicCommunity/Bloqbit.git"
SERVER_DIR="/mnt/server"

# Update and install required dependencies
install_dependencies() {
    echo "Updating system and installing dependencies..."
    apt update && apt install -y \
        git curl jq file unzip make gcc g++ python3 python3-dev python3-pip libtool

    if ! command -v git &>/dev/null; then
        echo "git could not be installed or is not in PATH."
        exit 1
    fi
}

# Update npm to the latest version
update_npm() {
    echo "Updating npm to the latest version..."

    npm install -g npm@latest

    npm install --save-dev typescript
    npm install --save-dev rimraf
}

# Clone or pull the repository
manage_repository() {
    echo "Checking server directory: $SERVER_DIR"
    mkdir -p "$SERVER_DIR"
    cd "$SERVER_DIR"

    if [ "$(ls -A "$SERVER_DIR")" ]; then
        echo "$SERVER_DIR is not empty."
        if [ -d .git ]; then
            echo ".git directory exists."
            if [ -f .git/config ]; then
                echo "Loading info from git config..."
                ORIGIN=$(git config --get remote.origin.url)
            else
                echo "Files found with no git config. Exiting to avoid breaking anything."
                exit 10
            fi
        fi

        if [ "${ORIGIN}" == "${GIT_ADDRESS}" ]; then
            echo "Pulling latest Bloqbit public update..."
            git pull
        fi
    else
        echo "$SERVER_DIR is empty. Cloning repository..."
        if [ -z "${BRANCH}" ]; then
            echo "Cloning public Bloqbit branch..."
            git clone "${GIT_ADDRESS}" .
        else
            echo "Cloning branch: ${BRANCH}..."
            git clone --single-branch --branch "${BRANCH}" "${GIT_ADDRESS}" .
        fi
    fi
}

# Install Node.js dependencies
install_dependencies_node() {
    if [ -f "$SERVER_DIR/package.json" ]; then
        echo "Installing Node.js dependencies..."
        npm install --production
    else
        echo "No package.json found. Skipping npm install."
    fi
}

# Main script execution
main() {
    install_dependencies
    update_npm
    manage_repository
    install_dependencies_node
    echo "Installation complete!"
    exit 0
}

# Execute the main function
main

# End of script
