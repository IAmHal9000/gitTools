CURRENT_DIR=$(pwd)

# Function to interpret HTTP response codes
interpret_response() {
    local code="$1"

    case "$code" in
        200) echo "Success: The operation was successful." ;;
        201) echo "Success: The resource was created successfully." ;;
        204) echo "Success: The resource was deleted successfully." ;;
        400) echo "Error: Bad request. The request could not be understood." ;;
        401) echo "Error: Unauthorized. Please check your GitHub token." ;;
        403) echo "Error: Forbidden. You don't have permission to access the resource." ;;
        404) echo "Error: Not found. The requested resource was not found." ;;
        405) echo "Error: Method not allowed. The HTTP method is not supported." ;;
        422) echo "Error: Unprocessable entity. The request was well-formed but unable to be followed." ;;
        500) echo "Error: Internal server error. Please try again later." ;;
        *) echo "Error: Unexpected HTTP response code: $code" ;;
    esac
}

# Function to make GitHub API requests
make_github_api_request() {
    local method="$1"
    local endpoint="$2"
    local data="$3"

    # Send the cURL request and capture the HTTP response code
    HTTP_RESPONSE=$(curl -s -X "$method" \
    -H "Authorization: token $GITHUB_TOKEN" \
    -H "Accept: application/vnd.github.v3+json" \
    -d "@$data" \
    -w "%{http_code}" \
    -o /dev/null \
    "$endpoint")

    # Interpret the HTTP response code
    interpret_response "$HTTP_RESPONSE"
}

# Function to create a repository on GitHub
create_repository() {
    local REPO_DATA_FILE="$CURRENT_DIR/gitTools.json"
    local API_ENDPOINT="https://api.github.com/user/repos"
    make_github_api_request "POST" "$API_ENDPOINT" "$REPO_DATA_FILE"
}

# Function to update a repository on GitHub
update_repository() {
    local REPO_DATA_FILE="$CURRENT_DIR/gitTools.json"
    local REPO_OWNER="$(jq -r '.owner' "$REPO_DATA_FILE")"
    local REPO_NAME="$(jq -r '.name' "$REPO_DATA_FILE")"
    local API_ENDPOINT="https://api.github.com/repos/$REPO_OWNER/$REPO_NAME"
    make_github_api_request "PATCH" "$API_ENDPOINT" "$REPO_DATA_FILE"
}

# Function to delete a repository on GitHub
delete_repository() {
    local REPO_DATA_FILE="$CURRENT_DIR/gitTools.json"
    local REPO_OWNER="$(jq -r '.owner' "$REPO_DATA_FILE")"
    local REPO_NAME="$(jq -r '.name' "$REPO_DATA_FILE")"
    local API_ENDPOINT="https://api.github.com/repos/$REPO_OWNER/$REPO_NAME"
    make_github_api_request "DELETE" "$API_ENDPOINT" "/dev/null"
}



# Parse command line arguments
case "$1" in
    "repo")
        case "$2" in
            "create") create_repository ;;
            "update") update_repository ;;
            "delete") delete_repository ;;
            *) echo "Usage: gitTools repo {create|update|delete}"; exit 1 ;;
        esac
        ;;
    *) echo "Usage: gitTools repo {create|update|delete}"; exit 1 ;;
esac
