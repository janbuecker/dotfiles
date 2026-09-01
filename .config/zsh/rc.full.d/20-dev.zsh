export GOPRIVATE="github.com/shopware-saas"
export GOLANGCI_LINT_CACHE="$XDG_CACHE_HOME"/golangci-lint

export TG_PROVIDER_CACHE="1"
export TG_PROVIDER_CACHE_DIR="$XDG_CACHE_HOME/terragrunt"
export TF_PLUGIN_CACHE_DIR="$XDG_CACHE_HOME/terraform"
export TF_CLI_CONFIG_FILE="$XDG_CONFIG_HOME/terraform/config.tfrc"

export COMPOSER_HOME="$XDG_CONFIG_HOME"/composer
export DOCKER_CONFIG="$XDG_CONFIG_HOME"/docker
export HOMEBREW_BUNDLE_FILE="$XDG_CONFIG_HOME/brewfile/Brewfile"

# Shells out to gh, so only when it is actually installed
(( $+commands[gh] )) && export GITHUB_TOKEN=$(gh auth token)

# needs zstd, which is not available through mise on a core box
alias tarz="tar --use-compress-program=zstdmt"

alias mclidev="go build -C ~/opt/cloud/mcli -o mcli main.go && ~/opt/cloud/mcli/mcli"
alias ghcr='docker login ghcr.io --username $(gh config get -h github.com user) --password $(gh config get -h github.com oauth_token)'

# dotfiles (bare repo with $HOME as work tree)
alias config="git --git-dir=$HOME/dotfiles/ --work-tree=$HOME"
alias lgdot="lg -w $HOME -g $HOME/dotfiles/"

cdp() {
    local p
    p=$(find ~/opt/cloud -mindepth 1 -maxdepth 1 -type d | fzf -1 -q "$*")
    [[ -n "$p" ]] && cd "$p"
}

gopro() {
    local _cache="$TMPDIR/.goreleaser_license"
    if [[ ! -f "$_cache" ]]; then
        op item get Goreleaser --fields "label=license key" > "$_cache"
        chmod 600 "$_cache"
    fi
    export GORELEASER_KEY="$(< "$_cache")"
}

goreleaser() {
    if [[ -z "$GORELEASER_KEY" ]]; then
        gopro
    fi
    command goreleaser "$@"
}

cdenv() {
    if [[ $(pwd) =~ /staging/ ]]; then
        cd $(pwd | sed 's!/staging/!/production/!')
    else
        cd $(pwd | sed 's!/production/!/staging/!')
    fi
}

cdop() {
    local dir="$PWD"
    while [[ "$dir" != "/" ]]; do
        if [[ -d "$dir/outpost" ]]; then
            break
        fi
        dir=$(dirname "$dir")
    done

    if [[ "$dir" == "/" ]]; then
        echo "No outpost directory found"
        return 1
    fi

    # dir = root/{env}; root is the parent that holds every {env}
    local root="${dir:h}"

    # rest = path inside the current outpost (after root/{env}/outpost/{outpostID}/)
    local rel="${PWD#"$dir"/outpost/}"
    local rest=""
    [[ "$rel" == */* ]] && rest="${rel#*/}"

    # Collect {env}/{outpostID} for staging + production and pick one
    local selection
    selection=$(
        for env in staging production; do
            for o in "$root/$env/outpost"/*(/N); do
                print -r -- "$env/${o:t}"
            done
        done | fzf
    )
    [[ -z "$selection" ]] && return

    local target="$root/${selection%%/*}/outpost/${selection#*/}"
    [[ -n "$rest" ]] && target="$target/$rest"

    cd "$target" || return
}

(( $+commands[wt] )) && eval "$(command wt config shell init zsh)"
