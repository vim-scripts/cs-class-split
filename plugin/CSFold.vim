"
" cs file fold with #region and #endregion
"
function CSFold() 
    " to first line
    "
    normal gg
    let regionlist = []
    let beginRegion = "#Region"
    let endRegion = "#EndRegion"

    let maxLineNumber = line("$")
    echo maxLineNumber

    let currLineNumber = 0

    let lastBeginRegionNumber = 0

    while currLineNumber < maxLineNumber 
        let currLine = getline(".")
        let currLineNumber = line(".")

        if( -1 != match(currLine, beginRegion ) )
            call add(regionlist, currLineNumber)

            "             echo "fine begin at " . currLine
            "             echo "len : " . len(regionlist)
            "             echo "last add line: " . regionlist[len(regionlist)-1]
        endif

        if( -1 != match(currLine, endRegion ) )
            let index = len(regionlist)
            let index = index - 1

            let lastBeginRegionNumber = regionlist[index]
            call remove(regionlist, index)
            let c =  lastBeginRegionNumber . "," .currLineNumber . "fo"
            execute c

            "             echo "find end at " . currLine
            "             echo "cmd : " . c
        endif
        normal j
    endwhile
endfunction


"
"
"
function GetUsing()
    let result = ""
    
    let begin = 1
    let endNumber = line("$")

    let useRegex = "^\s*using "

    while begin < endNumber
        let currentLine = getline(begin)
        
        if ( -1 != match( currentLine, useRegex) )
            let result = result . currentLine . "\n"
        endif
        let begin = begin + 1
    endwhile

    return result

endfunction

"
"
"
function GetNameSpace()
    let begin = 1
    let endNumber = line("$")
    echo endNumber

    let nsRegex = "^\s*namespace"
    let result = "namespace Unknown"

    while begin < endNumber
        let currentLine = getline(begin)
        "echo currentLine

        if ( -1 != match(currentLine, nsRegex))
            let result = currentLine
            "echo result
            return result
        endif
        let begin = begin + 1
    endwhile
endfunction

"
" split class to .cs file
"
function! SCF()
    normal viw"ay
    let filename = getreg("a")
    let filename = filename . ".cs"
    echo filename 
    call setreg('a', filename)

    " class name line
    "
    let classBeginLine = line(".")

    " class end line -- }
    "
    normal j%
    let classEndLine = line(".")

    let emptyLine = FindLineNumber( classBeginLine, 0, "^\s*$" )

    echo classBeginLine
    echo classEndLine
    echo emptyLine

    call CutLines( emptyLine, classEndLine - emptyLine + 1, "b" )

    " content
    "
    " normal Vj%x

    let filehead = GetUsing()
    let filehead = filehead . "\n"
    let filehead = filehead . GetNameSpace() . "\n"
    let filehead = filehead . "{\n"
    let filehead = filehead . getreg('b') . ""
    let filehead = filehead . "}\n"

    call setreg('*', filehead)

    "      normal j0wv%zf
    "      normal kVj

    execute ":new " . filename

    " select all lines in new window
    "
    normal ggVG

    normal p
    normal gg=G
    execute ":wq"

endfunction


" 
" dir 0 - up, 1 - down 
"
function! FindLineNumber( baseLine, dir, pattern )
    let maxLine = line("$")

    if (a:dir == 0 )
        let step = -1
        let result = 1
    else
        let step = 1
        let result = maxLine
    endif


    let i = a:baseLine 
    let i = i + step
    while 1
        let theLine = getline(i)
        let mr = match( theLine, a:pattern)
        
        if ( mr != -1 )
            let result = i
            break
        else
            let i = i + step
        endif

        if i<= 0 || i > maxLine
            break
        endif
    endwhile
    return result
endfunction

"
" copy lines to clip, cannot copy 1 line
"
function! CutLines(beginLine, lines, regName)
    if (a:lines <= 0 )
        return
    endif

    if ( a:lines == 1 )
        execute "normal " . a:beginLine . "GV\"" . a:regName . "x"
    endif

    let lines = a:lines - 1

    let cmd = "normal " . a:beginLine . "GV" . lines . "j\"" . a:regName . "x"
    echo "copy lines: " . cmd
    execute cmd
endfunction
