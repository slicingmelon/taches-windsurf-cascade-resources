#!/usr/bin/env bash
# TACHES Windsurf Cascade Resources - Installer
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/slicingmelon/taches-windsurf-cascade-resources/main/install.sh | bash
#   curl -fsSL https://raw.githubusercontent.com/slicingmelon/taches-windsurf-cascade-resources/main/install.sh | bash -s -- update
#   curl -fsSL https://raw.githubusercontent.com/slicingmelon/taches-windsurf-cascade-resources/main/install.sh | bash -s -- uninstall
#
# Or download and run:
#   curl -fsSL https://raw.githubusercontent.com/slicingmelon/taches-windsurf-cascade-resources/main/install.sh -o install.sh
#   chmod +x install.sh && ./install.sh [install|update|uninstall]

set -euo pipefail

REPO="slicingmelon/taches-windsurf-cascade-resources"
BRANCH="main"
BASE_URL="https://raw.githubusercontent.com/${REPO}/${BRANCH}"
API_URL="https://api.github.com/repos/${REPO}/git/trees/${BRANCH}?recursive=1"

WINDSURF_DIR="${HOME}/.codeium/windsurf"
WORKFLOWS_DIR="${WINDSURF_DIR}/global_workflows"
SKILLS_DIR="${WINDSURF_DIR}/skills"
RULES_DIR="${WINDSURF_DIR}/global_rules"
MANIFEST="${WINDSURF_DIR}/taches-install-manifest.json"

ACTION="${1:-install}"

# ── colours ──────────────────────────────────────────────────────────────────
if [ -t 1 ]; then
    C_CYAN="\033[36m"
    C_GREEN="\033[32m"
    C_RED="\033[31m"
    C_YELLOW="\033[33m"
    C_GRAY="\033[90m"
    C_WHITE="\033[97m"
    C_RESET="\033[0m"
else
    C_CYAN="" C_GREEN="" C_RED="" C_YELLOW="" C_GRAY="" C_WHITE="" C_RESET=""
fi

# ── helpers ───────────────────────────────────────────────────────────────────
header() {
    echo ""
    echo -e "  ${C_CYAN}TACHES Windsurf Cascade Resources${C_RESET}"
    echo -e "  ${C_GRAY}https://github.com/${REPO}${C_RESET}"
    echo ""
}

die() {
    echo -e "  ${C_RED}ERROR: $*${C_RESET}" >&2
    exit 1
}

check_deps() {
    for cmd in curl jq; do
        command -v "$cmd" >/dev/null 2>&1 || die "'$cmd' is required but not installed. Install it and retry."
    done
}

get_repo_tree() {
    echo -e "  ${C_GRAY}Fetching file list from GitHub...${C_RESET}"
    curl -fsSL \
        -H "User-Agent: taches-installer" \
        "$API_URL" \
    | jq -r '.tree[] | select(.type == "blob") | .path' \
    || die "Could not fetch repo tree. Check your internet connection."
}

dest_for_path() {
    local path="$1"
    case "$path" in
        windsurf/workflows/*)
            echo "${WORKFLOWS_DIR}/${path#windsurf/workflows/}"
            ;;
        windsurf/skills/*)
            echo "${SKILLS_DIR}/${path#windsurf/skills/}"
            ;;
        windsurf/rules/*)
            echo "${RULES_DIR}/${path#windsurf/rules/}"
            ;;
        *)
            echo ""
            ;;
    esac
}

install_files() {
    local tree="$1"
    local installed=()

    while IFS= read -r path; do
        dest=$(dest_for_path "$path")
        [ -z "$dest" ] && continue

        mkdir -p "$(dirname "$dest")"

        if curl -fsSL \
            -H "User-Agent: taches-installer" \
            "${BASE_URL}/${path}" \
            -o "$dest" 2>/dev/null; then
            echo -e "  ${C_GREEN}+${C_RESET} ${path}"
            installed+=("$dest")
        else
            echo -e "  ${C_YELLOW}! Failed: ${path}${C_RESET}"
        fi
    done <<< "$tree"

    printf '%s\n' "${installed[@]}"
}

save_manifest() {
    local files_json
    # Build JSON array from stdin lines
    files_json=$(while IFS= read -r f; do printf '%s\n' "$f"; done | jq -R . | jq -s .)

    jq -n \
        --arg repo "$REPO" \
        --arg branch "$BRANCH" \
        --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || date -u +%Y-%m-%dT%H:%M:%SZ)" \
        --argjson files "$files_json" \
        '{installed_at: $ts, repo: $repo, branch: $branch, files: $files}' \
    > "$MANIFEST"

    echo -e "  ${C_GRAY}Manifest saved: ${MANIFEST}${C_RESET}"
}

# ── actions ───────────────────────────────────────────────────────────────────
do_install() {
    header
    echo -e "  ${C_WHITE}Action: INSTALL${C_RESET}"

    if [ -f "$MANIFEST" ]; then
        echo ""
        echo -e "  ${C_YELLOW}Already installed. Use 'update' to refresh or 'uninstall' to remove.${C_RESET}"
        echo ""
        exit 0
    fi

    mkdir -p "$WORKFLOWS_DIR" "$SKILLS_DIR" "$RULES_DIR"

    local tree
    tree=$(get_repo_tree)

    local filtered
    filtered=$(echo "$tree" | grep -E "^windsurf/(workflows|skills|rules)/")
    local count
    count=$(echo "$filtered" | wc -l | tr -d ' ')

    echo -e "  ${C_WHITE}Installing ${count} files...${C_RESET}"
    echo ""

    local installed_files
    installed_files=$(install_files "$filtered")

    local n
    n=$(echo "$installed_files" | grep -c . || true)

    echo "$installed_files" | save_manifest

    echo ""
    echo -e "  ${C_CYAN}Installed ${n} files.${C_RESET}"
    echo -e "  ${C_WHITE}Restart Windsurf for changes to take effect.${C_RESET}"
    echo ""
}

do_update() {
    header
    echo -e "  ${C_WHITE}Action: UPDATE${C_RESET}"

    mkdir -p "$WORKFLOWS_DIR" "$SKILLS_DIR" "$RULES_DIR"

    local tree
    tree=$(get_repo_tree)

    local filtered
    filtered=$(echo "$tree" | grep -E "^windsurf/(workflows|skills|rules)/")
    local count
    count=$(echo "$filtered" | wc -l | tr -d ' ')

    echo -e "  ${C_WHITE}Updating ${count} files...${C_RESET}"
    echo ""

    local installed_files
    installed_files=$(install_files "$filtered")

    local n
    n=$(echo "$installed_files" | grep -c . || true)

    echo "$installed_files" | save_manifest

    echo ""
    echo -e "  ${C_CYAN}Updated ${n} files.${C_RESET}"
    echo -e "  ${C_WHITE}Restart Windsurf for changes to take effect.${C_RESET}"
    echo ""
}

do_uninstall() {
    header
    echo -e "  ${C_WHITE}Action: UNINSTALL${C_RESET}"

    if [ ! -f "$MANIFEST" ]; then
        echo ""
        echo -e "  ${C_YELLOW}No manifest found. Nothing to uninstall.${C_RESET}"
        echo -e "  ${C_GRAY}(Expected: ${MANIFEST})${C_RESET}"
        echo ""
        exit 0
    fi

    local removed=0
    local missing=0

    echo ""
    while IFS= read -r file; do
        if [ -f "$file" ]; then
            rm -f "$file"
            echo -e "  ${C_RED}-${C_RESET} ${file}"
            removed=$((removed + 1))

            # Remove empty parent directories up to WINDSURF_DIR
            local dir
            dir=$(dirname "$file")
            while [ "$dir" != "$WINDSURF_DIR" ] && [ -d "$dir" ] && [ -z "$(ls -A "$dir" 2>/dev/null)" ]; do
                rmdir "$dir"
                dir=$(dirname "$dir")
            done
        else
            missing=$((missing + 1))
        fi
    done < <(jq -r '.files[]' "$MANIFEST")

    rm -f "$MANIFEST"

    echo ""
    echo -e "  ${C_CYAN}Removed ${removed} files (${missing} already missing).${C_RESET}"
    echo -e "  ${C_WHITE}Restart Windsurf for changes to take effect.${C_RESET}"
    echo ""
}

# ── entry point ───────────────────────────────────────────────────────────────
check_deps

case "$ACTION" in
    install)   do_install   ;;
    update)    do_update    ;;
    uninstall) do_uninstall ;;
    *)
        echo "Usage: $0 [install|update|uninstall]"
        echo ""
        echo "  install   - Download and install globally (default)"
        echo "  update    - Re-download and overwrite existing files"
        echo "  uninstall - Remove all installed files"
        exit 1
        ;;
esac
