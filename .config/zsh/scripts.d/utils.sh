cdp() {
    if [ "$1" = "" ]; then
        p=$(find ~/opt/cloud -maxdepth 1 -type d | fzf)
    else
        p=$(find ~/opt/cloud -maxdepth 1 -type d | fzf -1 -q "$@")
    fi

    cd "$p" || return
}

mfa() {
    _code=$(ykman oath accounts code | fzf -1 -q "$1" | awk '{print $NF}')
    echo -n $_code
    echo $_code | pbcopy
}

gopro() {
    export GORELEASER_KEY=$(op item get Goreleaser --fields "label=license key")
}

cdenv() {
    if [[ $(pwd) =~ /staging/ ]]; then
        cd $(pwd | sed 's!/staging/!/production/!')
    else
        cd $(pwd | sed 's!/production/!/staging/!')
    fi
}
