#!/bin/zsh
# Get the current working directory
CURRENT_DIR=$(pwd)

# Load environment variables from .env file in the current directory
if [ -f "$CURRENT_DIR/.env" ]; then
    source "$CURRENT_DIR/.env"
else
    echo "Error: .env file not found in the current directory."
    exit 1
fi

# Set your GitHub token here
GITHUB_TOKEN="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"

# GitHub API endpoint for creating a new repository
API_ENDPOINT="https://api.github.com/user/repos"

# Data payload for creating the repository
DATA='{"name":"testProject","description":"This is your first repo!","homepage":"https://github.com","private":false,"is_template":true}'

# cURL command to create the repository
curl -X POST \
-H "Authorization: token $GITHUB_TOKEN" \
-H "Accept: application/vnd.github.v3+json" \
-d "$DATA" \
"$API_ENDPOINT"
