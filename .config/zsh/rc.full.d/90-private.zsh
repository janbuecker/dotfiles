# Private scripts, encrypted with git-crypt. Source them only once they are
# actually decrypted, otherwise the still-encrypted blob would be sourced.
for f in $ZDOTDIR/scripts.private.d/*(N); do
    # skip if not a regular file
    [[ -f "$f" ]] || continue

    # check if file is a text file using the file command
    # encrypted files will be detected as "data" or specific binary formats
    if ! file -b "$f" | grep -q "text"; then
        # file is likely encrypted or binary, skip silently
        continue
    fi

    source "$f"
done
