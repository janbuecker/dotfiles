autocmd TextYankPost * if v:event.operator ==# 'y' | call echoraw("\e]52;c;" . system('base64 | tr -d "\n"', join(v:event.regcontents, "\n") . (v:event.regtype ==# 'V' ? "\n" : '')) . "\x07") | endif
