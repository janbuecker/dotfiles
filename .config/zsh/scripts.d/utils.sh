cdp() {
    local p
    p=$(find ~/opt/cloud -mindepth 1 -maxdepth 1 -type d | fzf -1 -q "$*")
    [[ -n "$p" ]] && cd "$p"
}

mfa() {
    _code=$(ykman oath accounts code | fzf -1 -q "$1" | awk '{print $NF}')
    echo -n $_code
    echo $_code | pbcopy
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
