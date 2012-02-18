" PDV (phpDocumentor for Vim) Standalone
" ======================================
"
" Version: 1.0.1
"
" Copyright 2011 by Michael Härtl <haertl.mike@gmail.com>
"
" This is a fork of Tobias Schlitt's original PDV which
" mainly adds configuration options. The original version is
" Copyright 2005 by Tobias Schlitt <toby@php.net>
"
" Provided under the GPL (http://www.gnu.org/copyleft/gpl.html).
"
" This plugin can generate comment blocks for use with phpDocumentor.
" It currently documents:
"
" - Classes
" - Methods/Functions
" - Attributes
"
" For function/method parameters and attributes, the script tries to guess the
" type as good as possible from PHP5 type hints or default values (array, bool,
" int, string...).
"
" Configuration
" =============
"
" After moving the plugin to your local plugin folder (or installing it
" through a plugin manager like Vundle) you need to configure some tags in
" your .vimrc. You may want to configure the following tags, which are
" disabled by default:
"
"   let g:pdv_cfg_Package = "placeholder"
"   let g:pdv_cfg_Version = "1.0.0"
"   let g:pdv_cfg_Author = "Michael Härtl <haertl.mike@gmail.com>"
"   let g:pdv_cfg_Copyright = "Copyright 2011 by Michael Härtl"
"   let g:pdv_cfg_License = "GPL (http://www.gnu.org/copyleft/gpl.html)"
"
" See the source code below for all avaliable configuration options.
"
" Changelog
" =========
"
" Version 1.0.1
" -------------
"
"   * Fixed bug: @return is inserted now again
"
" Version 1.0.0
" -------------
"
"   * Created initial fork of Tobias Schlitts plugin. Made all tags optional
"   and configurable from .vimrc
"
if has ("user_commands")

" {{{ Globals

" Class level tags:
"
" Value of @package tag. Defaults to "" which means off.
if !exists('g:pdv_cfg_Package')
  let g:pdv_cfg_Package = ""
endif
" Value of @version tag. Defaults to "" which means off.
if !exists('g:pdv_cfg_Version')
  let g:pdv_cfg_Version = ""
endif
" Value of @author tag. Defaults to "" which means off.
if !exists('g:pdv_cfg_Author')
  let g:pdv_cfg_Author = ""
endif
" Value of @copyright tag. Defaults to "" which means off.
if !exists('g:pdv_cfg_Copyright')
  let g:pdv_cfg_Copyright = ""
endif
" Value of @license tag. Defaults to "" which means off.
if !exists('g:pdv_cfg_License')
  let g:pdv_cfg_License = ""
endif

" Function tags:
"
" Value of @return tag. Defaults to "void". Use "" to create no return tag.
if !exists('g:pdv_cfg_ReturnVal')
  let g:pdv_cfg_ReturnVal = "void"
endif

" Options:
"
" Default type of attributes and parameters. Defaults to "mixed".
if !exists('g:pdv_cfg_Type')
  let g:pdv_cfg_Type = "mixed"
endif
" Wether to create @uses tags. Defaults to 0 (off).
if !exists('g:pdv_cfg_Uses')
  let g:pdv_cfg_Uses = 0
endif
" Wether to :set paste before documenting. Defaults to 1 (on).
if !exists('g:pdv_cfg_paste')
  let g:pdv_cfg_paste = 1
endif
" Wether PHP4 tags should be set, like @access. Defaults to 0 (off).
if !exists('g:pdv_cfg_php4always')
  let g:pdv_cfg_php4always = 0
endif
" Wether to guess scopes from names ($_foo/_bar()). Defaults to 1 (on).
if !exists('g:pdv_cfg_php4guess')
  let g:pdv_cfg_php4guess = 1
endif
" Default scope for matches of g:pdv_cfg_php4guess. Defaults to "protected".
if !exists('g:pdv_cfg_php4guessval')
  let g:pdv_cfg_php4guessval = "protected"
endif

" Docblock formatting
"
" Start of any comment block. Defaults to "/**"
if !exists('g:pdv_cfg_CommentHead')
  let g:pdv_cfg_CommentHead = "/**"
endif
" Comment prefix of 1st line after start. Defaults to " * "
if !exists('g:pdv_cfg_Comment1')
  let g:pdv_cfg_Comment1 = " * "
endif
" Comment prefix of remaining lines. Defaults to " * "
if !exists('g:pdv_cfg_Commentn')
  let g:pdv_cfg_Commentn = " *"
endif
" End of any comment block. Defaults to " */"
if !exists('g:pdv_cfg_CommentTail')
  let g:pdv_cfg_CommentTail = " */"
endif
" Single line comment prefix. Defaults to "//"
if !exists('g:pdv_cfg_CommentSingle')
  let g:pdv_cfg_CommentSingle = "//"
endif

"
" Regular expressions
"
let g:pdv_re_comment = ' *\*/ *'

" (private|protected|public)
let g:pdv_re_scope = '\(private\|protected\|public\)'
" (static)
let g:pdv_re_static = '\(static\)'
" (abstract)
let g:pdv_re_abstract = '\(abstract\)'
" (final)
let g:pdv_re_final = '\(final\)'

" [:space:]*(private|protected|public|static|abstract)*[:space:]+[:identifier:]+\([:params:]\)
let g:pdv_re_func = '^\s*\([a-zA-Z ]*\)function\s\+\([^ (]\+\)\s*(\s*\(.*\)\s*)\s*[{;]\?$'
" [:typehint:]*[:space:]*$[:identifier]\([:space:]*=[:space:]*[:value:]\)?
let g:pdv_re_param = ' *\([^ &]*\) *&\?\$\([A-Za-z_][A-Za-z0-9_]*\) *=\? *\(.*\)\?$'

" [:space:]*(private|protected|public\)[:space:]*$[:identifier:]+\([:space:]*=[:space:]*[:value:]+\)*;
let g:pdv_re_attribute = '^\s*\(\(private\|public\|protected\|var\|static\)\+\)\s*\$\([^ ;=]\+\)[ =]*\(.*\);\?$'

" [:spacce:]*(abstract|final|)[:space:]*(class|interface)+[:space:]+\(extends ([:identifier:])\)?[:space:]*\(implements ([:identifier:][, ]*)+\)?
let g:pdv_re_class = '^\s*\([a-zA-Z]*\)\s*\(interface\|class\)\s*\([^ ]\+\)\s*\(extends\)\?\s*\([a-zA-Z0-9]*\)\?\s*\(implements*\)\? *\([a-zA-Z0-9_ ,]*\)\?.*$'

let g:pdv_re_array  = "^array *(.*"
" FIXME (retest regex!)
let g:pdv_re_float  = '^[0-9]*\.[0-9]\+'
let g:pdv_re_int    = '^[0-9]\+'
let g:pdv_re_string = "['\"].*"
let g:pdv_re_bool = "\(true\|false\)"

let g:pdv_re_indent = '^\s*'

" Shortcuts for editing the text:
let g:pdv_cfg_BOL = "norm! o"
let g:pdv_cfg_EOL = ""

" }}}

 " {{{ PhpDocSingle()
 " Document a single line of code ( does not check if doc block already exists )

func! PhpDocSingle()
    let l:endline = line(".") + 1
    call PhpDoc()
    exe "norm! " . l:endline . "G$"
endfunc

" }}}

 " {{{ PhpDocRange()
 " Documents a whole range of code lines ( does not add defualt doc block to
 " unknown types of lines ). Skips elements where a docblock is already
 " present.
func! PhpDocRange() range
    let l:line = a:firstline
    let l:endLine = a:lastline
    let l:elementName = ""
    while l:line <= l:endLine
        " TODO: Replace regex check for existing doc with check more lines
        " above...
        if (getline(l:line) =~ g:pdv_re_func || getline(l:line) =~ g:pdv_re_attribute || getline(l:line) =~ g:pdv_re_class) && getline(l:line - 1) !~ g:pdv_re_comment
            let l:docLines = 0
            " Ensure we are on the correct line to run PhpDoc()
            exe "norm! " . l:line . "G$"
            " No matter what, this returns the element name
            let l:elementName = PhpDoc()
            let l:endLine = l:endLine + (line(".") - l:line) + 1
            let l:line = line(".") + 1
        endif
        let l:line = l:line + 1
    endwhile
endfunc

 " }}}

" {{{ PhpDoc()

func! PhpDoc()
    " Needed for my .vimrc: Switch off all other enhancements while generating docs
    let l:paste = &g:paste
    let &g:paste = g:pdv_cfg_paste == 1 ? 1 : &g:paste

    let l:line = getline(".")
    let l:result = ""

    if l:line =~ g:pdv_re_func
        let l:result = PhpDocFunc()

    elseif l:line =~ g:pdv_re_attribute
        let l:result = PhpDocVar()

    elseif l:line =~ g:pdv_re_class
        let l:result = PhpDocClass()

    else
        let l:result = PhpDocDefault()

    endif

"   if g:pdv_cfg_folds == 1
"       PhpDocFolds(l:result)
"   endif

    let &g:paste = l:paste

    return l:result
endfunc

" }}}
" {{{  PhpDocFunc()

func! PhpDocFunc()
    " Line for the comment to begin
    let l:commentline = line (".") - 1

    let l:name = substitute (getline ("."), '^\(.*\)\/\/.*$', '\1', "")

    " First some things to make it more easy for us:
    " tab -> space && space+ -> space
    " let l:name = substitute (l:name, '\t', ' ', "")
    " Orphan. We're now using \s everywhere...

    " Now we have to split DECL in three parts:
    " \[(skopemodifier\)]\(funcname\)\(parameters\)
    let l:indent = matchstr(l:name, g:pdv_re_indent)

    let l:modifier = substitute (l:name, g:pdv_re_func, '\1', "g")
    let l:funcname = substitute (l:name, g:pdv_re_func, '\2', "g")
    let l:parameters = substitute (l:name, g:pdv_re_func, '\3', "g") . ","
    let l:scope = PhpDocScope(l:modifier, l:funcname)
    let l:static = g:pdv_cfg_php4always == 1 ? matchstr(l:modifier, g:pdv_re_static) : ""
    let l:abstract = g:pdv_cfg_php4always == 1 ? matchstr(l:modifier, g:pdv_re_abstract) : ""
    let l:final = g:pdv_cfg_php4always == 1 ? matchstr(l:modifier, g:pdv_re_final) : ""

    " Local indent
    let l:txtBOL = g:pdv_cfg_BOL . l:indent

    let l:comment_lines = []

    call add(l:comment_lines, l:indent . g:pdv_cfg_CommentHead)
    call add(l:comment_lines, l:indent . g:pdv_cfg_Comment1 . funcname)
    call add(l:comment_lines, l:indent . g:pdv_cfg_Commentn)

    while (l:parameters != ",") && (l:parameters != "")
        " Save 1st parameter
        let _p = substitute (l:parameters, '\([^,]*\) *, *\(.*\)', '\1', "")
        " Remove this one from list
        let l:parameters = substitute (l:parameters, '\([^,]*\) *, *\(.*\)', '\2', "")
        " PHP5 type hint?
        let l:paramtype = substitute (_p, g:pdv_re_param, '\1', "")
        " Parameter name
        let l:paramname = substitute (_p, g:pdv_re_param, '\2', "")
        " Parameter default
        let l:paramdefault = substitute (_p, g:pdv_re_param, '\3', "")

        if l:paramtype == ""
            let l:paramtype = PhpDocType(l:paramdefault)
        endif

        if l:paramtype != ""
            let l:paramtype = " " . l:paramtype
        endif
        call add(l:comment_lines, l:indent . g:pdv_cfg_Commentn . " @param" . l:paramtype . " $" . l:paramname)
    endwhile

    if l:static != ""
        call add(l:comment_lines, l:indent . g:pdv_cfg_Commentn . " @static")
    endif
    if l:abstract != ""
        call add(l:comment_lines, l:indent . g:pdv_cfg_Commentn . " @abstract")
    endif
    if l:final != ""
        call add(l:comment_lines, l:indent . g:pdv_cfg_Commentn . " @final")
    endif
    if l:scope != ""
        call add(l:comment_lines, l:indent . g:pdv_cfg_Commentn . " @access " . l:scope)
    endif
    if g:pdv_cfg_ReturnVal != ""
        call add(l:comment_lines, l:indent . g:pdv_cfg_Commentn . " @return " . g:pdv_cfg_ReturnVal)
    endif

    " Close the comment block.
    call add(l:comment_lines, l:indent . g:pdv_cfg_CommentTail)

    call append(l:commentline, l:comment_lines)
    return l:modifier ." ". l:funcname
endfunc

" }}}
 " {{{  PhpDocVar()

func! PhpDocVar()
    " Line for the comment to begin
    let commentline = line (".") - 1

    let l:name = substitute (getline ("."), '^\(.*\)\/\/.*$', '\1', "")

    " Now we have to split DECL in three parts:
    " \[(skopemodifier\)]\(funcname\)\(parameters\)
    " let l:name = substitute (l:name, '\t', ' ', "")
    " Orphan. We're now using \s everywhere...

    let l:indent = matchstr(l:name, g:pdv_re_indent)

    let l:modifier = substitute (l:name, g:pdv_re_attribute, '\1', "g")
    let l:varname = substitute (l:name, g:pdv_re_attribute, '\3', "g")
    let l:default = substitute (l:name, g:pdv_re_attribute, '\4', "g")
    let l:scope = PhpDocScope(l:modifier, l:varname)

    let l:static = g:pdv_cfg_php4always == 1 ? matchstr(l:modifier, g:pdv_re_static) : ""

    let l:type = PhpDocType(l:default)

    let l:comment_lines = []

    call add(l:comment_lines, l:indent . g:pdv_cfg_CommentHead)
    call add(l:comment_lines, l:indent . g:pdv_cfg_Comment1 . l:varname)
    call add(l:comment_lines, l:indent . g:pdv_cfg_Commentn)
    if l:static != ""
        call add(l:comment_lines, l:indent . g:pdv_cfg_Commentn . " @static")
    endif
    call add(l:comment_lines, l:indent . g:pdv_cfg_Commentn . " @var " . l:type)
    if l:scope != ""
        call add(l:comment_lines, l:indent . g:pdv_cfg_Commentn . " @access " . l:scope)
    endif

    " Close the comment block.
    call add(l:comment_lines, l:indent . g:pdv_cfg_CommentTail)

    call append(l:commentline, l:comment_lines)
    return l:modifier ." ". l:varname
endfunc

" }}}
"  {{{  PhpDocClass()

func! PhpDocClass()
    " Line for the comment to begin
    let commentline = line (".") - 1

    let l:name = substitute (getline ("."), '^\(.*\)\/\/.*$', '\1', "")

    " Now we have to split DECL in three parts:
    " \[(skopemodifier\)]\(classname\)\(parameters\)
    let l:indent = matchstr(l:name, g:pdv_re_indent)

    let l:modifier = substitute (l:name, g:pdv_re_class, '\1', "g")
    let l:classname = substitute (l:name, g:pdv_re_class, '\3', "g")
    let l:extends = g:pdv_cfg_Uses == 1 ? substitute (l:name, g:pdv_re_class, '\5', "g") : ""
    let l:interfaces = g:pdv_cfg_Uses == 1 ? substitute (l:name, g:pdv_re_class, '\7', "g") . "," : ""

    let l:abstract = g:pdv_cfg_php4always == 1 ? matchstr(l:modifier, g:pdv_re_abstract) : ""
    let l:final = g:pdv_cfg_php4always == 1 ?  matchstr(l:modifier, g:pdv_re_final) : ""

    let l:comment_lines = []

    call add(l:comment_lines, l:indent . g:pdv_cfg_CommentHead)
    call add(l:comment_lines, l:indent . g:pdv_cfg_Comment1 . l:classname)
    call add(l:comment_lines, l:indent . g:pdv_cfg_Commentn)
    if l:extends != "" && l:extends != "implements"
        call add(l:comment_lines, l:indent . g:pdv_cfg_Commentn . " @uses " . l:extends)
    endif

    while (l:interfaces != ",") && (l:interfaces != "")
        " Save 1st parameter
        let interface = substitute (l:interfaces, '\([^, ]*\) *, *\(.*\)', '\1', "")
        " Remove this one from list
        let l:interfaces = substitute (l:interfaces, '\([^, ]*\) *, *\(.*\)', '\2', "")
        call add(l:comment_lines, l:indent . g:pdv_cfg_Commentn . " @uses " . l:interface)
    endwhile

    if l:abstract != ""
        call add(l:comment_lines, l:indent . g:pdv_cfg_Commentn . " @abstract")
    endif
    if l:final != ""
        call add(l:comment_lines, l:indent . g:pdv_cfg_Commentn . " @final")
    endif
    if g:pdv_cfg_Package != ""
        call add(l:comment_lines, l:indent . g:pdv_cfg_Commentn . " @package " . g:pdv_cfg_Package)
    endif
    if g:pdv_cfg_Version != ""
        call add(l:comment_lines, l:indent . g:pdv_cfg_Commentn . " @version " . g:pdv_cfg_Version)
    endif
    if g:pdv_cfg_Copyright != ""
        call add(l:comment_lines, l:indent . g:pdv_cfg_Commentn . " @copyright " . g:pdv_cfg_Copyright)
    endif
    if g:pdv_cfg_Author != ""
        call add(l:comment_lines, l:indent . g:pdv_cfg_Commentn . " @author " . g:pdv_cfg_Author)
    endif
    if g:pdv_cfg_License != ""
        call add(l:comment_lines, l:indent . g:pdv_cfg_Commentn . " @license " . g:pdv_cfg_License)
    endif

    " Close the comment block.
    call add(l:comment_lines, l:indent . g:pdv_cfg_CommentTail)

    call append(l:commentline, l:comment_lines)
    return l:modifier ." ". l:classname
endfunc

" }}}
" {{{ PhpDocScope()

func! PhpDocScope(modifiers, identifier)
" exe g:pdv_cfg_BOL . DEBUG: . a:modifiers . g:pdv_cfg_EOL
    let l:scope  = ""
    if  matchstr (a:modifiers, g:pdv_re_scope) != ""
        if g:pdv_cfg_php4always == 1
            let l:scope = matchstr (a:modifiers, g:pdv_re_scope)
        else
            let l:scope = "x"
        endif
    endif
    if l:scope =~ "^\s*$" && g:pdv_cfg_php4guess
        if a:identifier[0] == "_"
            let l:scope = g:pdv_cfg_php4guessval
        else
            let l:scope = "public"
        endif
    endif
    return l:scope != "x" ? l:scope : ""
endfunc

" }}}
" {{{ PhpDocType()

func! PhpDocType(typeString)
    let l:type = ""
    if a:typeString =~ g:pdv_re_array
        let l:type = "array"
    endif
    if a:typeString =~ g:pdv_re_float
        let l:type = "float"
    endif
    if a:typeString =~ g:pdv_re_int
        let l:type = "int"
    endif
    if a:typeString =~ g:pdv_re_string
        let l:type = "string"
    endif
    if a:typeString =~ g:pdv_re_bool
        let l:type = "bool"
    endif
    if l:type == ""
        let l:type = g:pdv_cfg_Type
    endif
    return l:type
endfunc

"  }}}
" {{{  PhpDocDefault()

func! PhpDocDefault()
    " Line for the comment to begin
    let commentline = line (".") - 1

    let l:indent = matchstr(getline("."), '^\ *')

    exe "norm! " . commentline . "G$"

    " Local indent
    let l:txtBOL = g:pdv_cfg_BOL . indent

    exe l:txtBOL . g:pdv_cfg_CommentHead . g:pdv_cfg_EOL
    exe l:txtBOL . g:pdv_cfg_Commentn . g:pdv_cfg_EOL

    " Close the comment block.
    exe l:txtBOL . g:pdv_cfg_CommentTail . g:pdv_cfg_EOL
endfunc

" }}}

endif " user_commands
