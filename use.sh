#!/bin/sh

# CONFIGURATION
GITHUB_USER="xxXtermuxXxx"
INSTALL_DIR="$HOME/.usepkgs"
API_URL="https://api.github.com/users/$GITHUB_USER/repos"

mkdir -p "$INSTALL_DIR"

# Function: list available repos
list_repos() {
    echo "Fetching available repos from GitHub user: $GITHUB_USER"
    curl -s "$API_URL" | grep -o '"name": *"[^"]*"' | sed 's/"name": "//;s/"//' | sort
}

# Function: install a repo
install_repo() {
    REPO="$1"

    if [ -z "$REPO" ]; then
        echo "Usage: use install <repo>"
        exit 1
    fi

    echo "[*] Checking for repository '$REPO'..."
    EXISTS=$(curl -s "$API_URL" | grep -o "\"name\": *\"$REPO\"")

    if [ -z "$EXISTS" ]; then
        echo "[!] Repository '$REPO' not found in $GITHUB_USER"
        exit 1
    fi

    TARGET="$INSTALL_DIR/$REPO"

    if [ -d "$TARGET" ]; then
        echo "[*] Repo already exists. Updating..."
        cd "$TARGET" || exit
        git pull
    else
        echo "[*] Cloning $REPO..."
        git clone "https://github.com/$GITHUB_USER/$REPO.git" "$TARGET"
    fi

    # Run install.sh if available
    if [ -f "$TARGET/install.sh" ]; then
        echo "[*] Running install.sh..."
        sh "$TARGET/install.sh"
    else
        echo "[*] No install.sh found. Repo installed but no installer executed."
    fi

    echo "[✓] Installation complete for $REPO."
}

# Main command parser
case "$1" in
    list)
        list_repos
        ;;
    install)
        install_repo "$2"
        ;;
    *)
        echo "use - simple repo installer"
        echo "Usage:"
        echo "  use list               # list available repos"
        echo "  use install <repo>     # install repository"
        ;;
esac

