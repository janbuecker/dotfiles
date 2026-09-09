# Private helpers, encrypted with git-crypt. A workstation that has not been
# unlocked yet still has the encrypted blobs on disk, so this has to check
# before sourcing rather than trust the file being there.
for _priv in $ZDOTDIR/scripts.private.d/*(N); do
    [[ -f $_priv ]] || continue
    file -b "$_priv" | grep -q "text" || continue
    source $_priv
done
unset _priv
