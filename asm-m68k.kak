# Detection
# ---------
hook global BufCreate .*\.(s|S|asm)$ %{
    set-option buffer filetype asm-m68k
}

hook global WinSetOption filetype=asm-m68k %{
    require-module asm-m68k

    hook window ModeChange pop:insert:.* -group asm-m68k-trim-indent asm-m68k-trim-indent
    hook window InsertChar \n -group asm-m68k-indent asm-m68k-indent-on-new-line
    hook -once -always window WinSetOption filetype=.* %{ remove-hooks window asm-m68k-.+ }
}

hook -group asm-m68k-highlight global WinSetOption filetype=asm-m68k %{
    add-highlighter window/asm-m68k ref asm-m68k
    hook -once -always window WinSetOption filetype=.* %{ remove-highlighter window/asm-m68k }
}


provide-module asm-m68k %{

add-highlighter shared/asm-m68k regions
add-highlighter shared/asm-m68k/code default-region group
add-highlighter shared/asm-m68k/string         region '"' (?<!\\)(\\\\)*"        fill string
add-highlighter shared/asm-m68k/commentMulti   region /\*       \*/              fill comment
#add-highlighter shared/asm-m68k/commentSingle1 region '#'       '$'              fill comment
add-highlighter shared/asm-m68k/commentSingle2 region ';'       '$'              fill comment

# Constant
add-highlighter shared/asm-m68k/code/ regex (\$[0-9a-fA-F]+|\b[0-9]+)\b 0:value

# Labels
add-highlighter shared/asm-m68k/code/ regex ^([A-Za-z0-9_.-]+):? 0:operator

# vasm Directives, Mot syntax
add-highlighter shared/asm-m68k/code/ regex ((^|\s+)(=(\.[sdxp])?|align|assert|blk.[bdlqswx]|bss(_[cf])?|cargs|clrfo|clrso|cnop|code(_[cf])?|comm|comment|cseg|data(_[cf])?|db|dc.[bdlpqswx]|dcb.[bdlqswx]|dl|dr.[bwl]|ds.[bdlqswx]|dseg|dw|dx.[bdlqswx]|echo|einline|else|elseif|elif|end|endif|endm|endr|equ(.[sdxp])?|erem|even|fail|fequ.[sdxp]|fo.[bwlqsdxp]|idnt|if|if1|if2|ifeq|ifne|ifgt|ifge|iflt|ifle|ifb|ifnb|ifc|ifnc|ifd|ifnd|ifmacrod|ifmacrond|ifp1|iif|ncbin|incdir|include|inline|list|llen|local|macro|mexit|msource|nolist|nopage|nref|odd|offset|org|output|page|plen|printt|printv|public|popsection|pushsection|rem|rept|rorg|rs.[bwlqsdxp]|rseven|rsreset|rsset|section|set|setfo|setso|showoffset|so.[bwlqsdxp]|spc|text|ttl|ttl|weak|xdef|xref)(\h+|$)) 0:type

# Registers
add-highlighter shared/asm-m68k/code/ regex \b([ad][0-7]|ccr|pc|sp|sr|usp)\b 0:variable

# 68000 Instructions
add-highlighter shared/asm-m68k/code/ regex (\
\h+[ans]bcd(.b)?|\
\h+(add|and|eor|or|sub)[i]?(\.[bwl])?|\
\h+(add|sub)[qx](\.[bwl])?|\
\h+adda(\.[wl])?|\
\h+(([al]s|rox?)[lr])(\.[bwl])?|\
\h+b(cc|cs|eq|ge|gt|hi|le|ls|lt|mi|ne|pl|vc|vs|ra|sr|t|f)(\.[bsw])?|\
\h+b(chg|clr|set|tst)(\.[bl])?|\
\h+chk(\.w)?|\
\h+clr(\.[bwl])?|\
\h+cmp[im]?(\.[bwl])?|\
\h+cmpa(\.[wl])?|\
\h+db(cc|cs|eq|ge|gt|hi|le|ls|lt|mi|ne|pl|vc|vs|ra|sr|t|f)|\
\h+(div|mul)[su](\.w)?|\
\h+exg(\.l)?|\
\h+ext(\.[wl])?|\
\h+illegal|\
\h+jmp|jsr|\
\h+[lp]ea(\.l)?|\
\h+link(\.w)?|\
\h+move(\.[bwl])?|\
\h+move[amp](\.[wl])?|\
\h+moveq(\.l)?|\
\h+(negx?|not)(\.[bwl])?|\
\h+nop|\
\h+reset|\
\h+rt[ers]|\
\h+s(cc|cs|eq|ge|gt|hi|le|ls|lt|mi|ne|pl|vc|vs|ra|sr|t|f)(\.b)?|\
\h+stop|\
\h+swap(\.w)?|\
\h+tas(\.b)?|\
\h+trapv?|\
\h+tst(\.[bwl])?|\
\h+unlk\
)\b 0:keyword


define-command -hidden asm-m68k-trim-indent %{
    evaluate-commands -draft -itersel %{
        execute-keys x
        # remove trailing white spaces
        try %{ execute-keys -draft s \h+$ <ret> d }
    }
}

define-command -hidden asm-m68k-indent-on-new-line %~
    evaluate-commands -draft -itersel %<
        # preserve previous line indent
        try %{ execute-keys -draft <semicolon> K <a-&> }
        # filter previous line
        try %{ execute-keys -draft k : asm-m68k-trim-indent <ret> }
        # indent after label
        try %[ execute-keys -draft k x <a-k> :$ <ret> j <a-gt> ]
    >
~

}
