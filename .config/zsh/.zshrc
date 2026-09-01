# Loader. Real configuration lives in rc.d (core, portable) and rc.full.d
# (mac + work). See README for the profile split.

# Profile: environment wins, then the marker file written by install.sh,
# then a default of "full" on macOS and "core" everywhere else.
# $(<file) reports a missing file on stderr even when redirected, so the
# marker has to be tested for rather than read optimistically.
if [[ -z ${DOTFILES_PROFILE:-} && -r $ZDOTDIR/profile ]]; then
    DOTFILES_PROFILE=$(<$ZDOTDIR/profile)
fi
if [[ -z ${DOTFILES_PROFILE:-} ]]; then
    if [[ $OSTYPE == darwin* ]]; then
        DOTFILES_PROFILE=full
    else
        DOTFILES_PROFILE=core
    fi
fi
export DOTFILES_PROFILE

for f in $ZDOTDIR/rc.d/*.zsh(N); do source $f; done

if [[ $DOTFILES_PROFILE == full ]]; then
    for f in $ZDOTDIR/rc.full.d/*.zsh(N); do source $f; done
fi

# Machine-local overrides, not tracked
for f in $ZDOTDIR/rc.local.d/*.zsh(N); do source $f; done

unset f
