cdp() {
    cd $(~/bin/dir_select "$@")
}

mfa() {
    _code=$(ykman oath accounts code | fzf -1 -q "$1" | awk '{print $NF}')
    echo -n $_code
    echo $_code | pbcopy
}

gopro() {
    export GORELEASER_KEY=$(op item get Goreleaser --fields "label=license key")
}
