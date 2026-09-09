# Loader. Real configuration lives in three directories, and a file is active
# on a machine only if it is present there:
#
#   rc.d/        portable, on every machine
#   rc.work.d/   workstation only, never checked out on a server
#   rc.local.d/  per-machine, untracked
#
# There is no profile to set and nothing to switch. What a machine gets is
# decided once, by the sparse-checkout list install.sh writes. See README.
for f in $ZDOTDIR/rc.d/*.zsh(N) $ZDOTDIR/rc.work.d/*.zsh(N) $ZDOTDIR/rc.local.d/*.zsh(N); do
    source $f
done
unset f
