[[ $OSTYPE == darwin* ]] || return

export PATH="$PATH:/Applications/WezTerm.app/Contents/MacOS"

# alias tailscale="/Applications/Tailscale.app/Contents/MacOS/Tailscale"

# 1Password SSH agent socket
_op_sock="$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
[ -S "$_op_sock" ] && export SSH_AUTH_SOCK="$_op_sock"
unset _op_sock

mfa() {
    _code=$(ykman oath accounts code | fzf -1 -q "$1" | awk '{print $NF}')
    echo -n $_code
    echo $_code | pbcopy
}
