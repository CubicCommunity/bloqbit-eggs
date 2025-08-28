#!/bin/bash
# Bloqbit Installation Script
# Server Files: /mnt/server

# Derived from node.js generic egg https://www.pterodactyleggs.com/egg/673601c24924a4e9bbd4bed3/

# Constants
GIT_ADDRESS="https://github.com/CubicCommunity/Bloqbit.git"
SERVER_DIR="/mnt/server"

# Update and install required dependencies
install_dependencies() {
    echo "Cleaning packages..."

    apt-get autoremove -y && apt-get clean && apt-get autoclean

    echo "Updating system and installing dependencies..."

    apt update && apt install -y git

    if ! command -v git &>/dev/null; then
        echo "git could not be installed or is not in PATH."
        exit 1
    fi
}

# Update npm to the latest version
update_npm() {
    echo "Updating npm to the latest version..."
    npm i -g npm@latest
}

# Clone or pull the repository
manage_repository() {
    echo "Checking server directory: $SERVER_DIR"

    mkdir -p "$SERVER_DIR"
    cd "$SERVER_DIR" || exit 1

    # Determine branch or release tag
    if [ "$USE_RELEASE" = true ]; then
        echo "Detecting latest release tag from remote..."
        BRANCH=$(git ls-remote --tags --sort=-v:refname "$GIT_ADDRESS" | \
                 grep -o 'refs/tags/[^\^]*' | \
                 sed 's/refs\/tags\///' | \
                 head -n 1)

        if [ -z "$BRANCH" ]; then
            echo "No release tags found. Exiting..."
            exit 11
        fi

        echo "Latest release tag detected: $BRANCH"
    fi

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
            echo "Forcing latest update from origin (discarding local changes)..."
            git fetch --all

            # Detect current branch or tag
            BRANCH_NAME=$(git rev-parse --abbrev-ref HEAD)

            if [ "$BRANCH_NAME" = "HEAD" ]; then
                echo "Detached HEAD detected. Resetting to latest tag: $BRANCH"
                git reset --hard "tags/${BRANCH}"
            else
                echo "Resetting to origin/${BRANCH_NAME}"
                git reset --hard "origin/${BRANCH_NAME}"
            fi
        fi
    else
        echo "$SERVER_DIR is empty. Cloning repository..."

        if [ -z "${BRANCH}" ]; then
            echo "Cloning default branch..."
            git clone "${GIT_ADDRESS}" .
        else
            echo "Cloning branch or tag: ${BRANCH}..."
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

    echo "▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬"
    echo "Bloqbit is now installed!"
    echo "▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬"

    exit 0
}

# Execute the main function
main

# End of script