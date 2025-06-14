" MIT LICENSE Copyright (c) 2024-2025 Kareem Ahmad.
" Autocomplete plugin

let s:ft_auto_defs = {}

function! autocomplete#main(marker, default, trusted_ft)
    let _match = []
    let _expan = ""

    if has_key(s:ft_auto_defs, &ft)
        let definitions = s:ft_auto_defs[&ft]
        let _line = getline(line('.'))[0:col('.')-2]

        for definition in definitions
            let _match = matchlist(_line, definition[0])
            if _match != [] | let _expan = definition[1] | break | endif
        endfor
    endif

    if _match == [] | return a:default | endif

    let _i = 0
    let _spchr = '((_|\^)?\d|[!:nN<>()dtb])'
    let _expan = substitute(_expan, '\v\\'._spchr, '\\\0', "g")
    let _expan = substitute(_expan, '\v\\\\(\\'._spchr.')', '\1', "g")

    let t = (a:trusted_ft == "all") || (a:trusted_ft =~ &ft)

    let _split = split(_expan, '\\\\', 1)
    let _expan = remove(_split, 0)
    let _marker = 0
    let _skip = 0

    for chunk in _split
        if     chunk[0]   =~ '\d'     | let _expan = _expan . _match[chunk[0]]                . chunk[1:]
        elseif chunk[0]   == 'n'      | let _expan = _expan . "\<CR>"                         . chunk[1:]
        elseif chunk[0]   == 'N'      | let _expan = _expan . "\<CR> \<BS>"                   . chunk[1:]
        elseif chunk[0]   == ':'      | let _expan = _expan . "\<Esc>m".a:marker."a"          . chunk[1:] | let _marker = 1
        elseif chunk[0:1] =~ '\^\d'   | let _expan = _expan . tolower(_match[chunk[0] + 0])   . chunk[2:]
        elseif chunk[0:1] =~ '_\d'    | let _expan = _expan . toupper(_match[chunk[0] + 0])   . chunk[2:]
        elseif chunk[0]   == '!'      | let _expan = _expan . repeat("\<BS>", len(_match[0])) . chunk[1:]
        elseif chunk[0]   == '<'      | let _expan = _expan . expand(chunk[1:])                           | let _skip = 1
       "elseif chunk[0]   == '(' && t | let _expan = _expan . eval(chunk[1:])                             | let _skip = 1
        elseif chunk[0]   == '(' && t | let _expan = _expan . "\<C-R>=" . chunk[1:] . "\n"                | let _skip = 1
        elseif chunk[0]   == 'd'      | let _expan = _expan . strftime("%Y %b %d")            . chunk[1:]
        elseif chunk[0]   == 't'      | let _expan = _expan . strftime("%Y %b %d %X")         . chunk[1:]
        elseif chunk[0]   == 'b'      | let _expan = _expan . "\<BS>"                         . chunk[1:]
        endif
    endfor

    if _marker
        return _expan . "\<Esc>`".a:marker."a"
    else
        return _expan
    endif
endfunction

function! autocomplete#register(ft, matches)
    let s:ft_auto_defs[a:ft] = a:matches
endfunction
