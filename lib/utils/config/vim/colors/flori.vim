" Vim color file based on desert.vim

" cool help screens
" :he group-name
" :he highlight-groups

if has("gui_running")
  set background=dark
endif
if exists("syntax_on")
   syntax reset
endif
if version > 580
    " no gearantees for version 5.8 and below, but this makes it stop
    " complaining
    hi clear
    if exists("syntax_on")
      syntax reset
    endif
endif
let g:colors_name="flori"

" general highlight groups
hi Normal guifg=lightyellow guibg=grey20
hi ColorColumn guibg=grey25
hi Cursor guibg=khaki guifg=slategrey
hi CursorIM guibg=khaki guifg=slategrey
hi CursorColumn guibg=grey25
hi CursorLine guibg=grey25
hi Folded guibg=grey30 guifg=gold
hi FoldColumn guibg=grey30 guifg=tan
hi IncSearch guifg=slategrey guibg=khaki
hi ModeMsg guifg=goldenrod
hi MoreMsg guifg=seagreen
hi NonText guifg=lightblue guibg=grey30
hi Question guifg=springgreen
hi Search guibg=peru guifg=white
hi SpecialKey guifg=yellowgreen
hi VertSplit guibg=#c2bfa5 guifg=grey50 gui=none
hi StatusLine guibg=#c2bfa5 guifg=black gui=none
hi StatusLineNC guibg=#c2bfa5 guifg=grey40 gui=none
hi Title guifg=indianred
hi Visual guifg=NONE guibg=peru
hi VisualNOS guifg=NONE guibg=grey25 gui=none
hi WarningMsg guifg=salmon guibg=NONE
hi LineNr guifg=slategrey guibg=NONE
hi Pmenu guifg=grey40 guibg=#c2bfa5 gui=NONE
hi PmenuSel guifg=white guibg=grey40 gui=NONE
hi PmenuSbar guifg=black guibg=grey30
hi PmenuThumb guifg=black guibg=white

" syntax highlighting groups
hi Comment guifg=slategrey guibg=NONE
"
hi Constant guifg=lightgreen guibg=NONE
hi String guifg=salmon guibg=NONE
hi Character guifg=greenyellow guibg=NONE
hi Number guifg=red guibg=NONE
hi Boolean guifg=red guibg=NONE
hi link Float Number
hi Regexp guifg=tomato guibg=NONE
"
hi Identifier guifg=palegreen guibg=NONE
hi Function guifg=limegreen guibg=NONE
"
hi Statement guifg=khaki guibg=NONE
hi Keyword guifg=brown gui=bold guibg=NONE
hi Operator guifg=orangered guibg=NONE
"
hi PreProc guifg=indianred guibg=NONE
"
hi Type  guifg=darkkhaki guibg=NONE
"
hi Special guifg=orange guibg=NONE
"
hi Underlined guifg=darkslateblue gui=underline guibg=NONE
"
hi Ignore guifg=grey40 guibg=NONE
"
hi Error guifg=yellow guibg=orangered
"
hi Todo guifg=orangered guibg=yellow
"

hi rubyInterpolation guifg=moccasin guibg=NONE
hi rubyInstanceVariable guifg=orangered guibg=NONE
hi rubyClassVariable guifg=#dc1436 guibg=NONE
hi rubyGlobalVariable guifg=deeppink guibg=NONE
hi rubyEval guifg=red guibg=NONE
hi rubyBlockParameter guifg=orchid guibg=NONE
hi rubyBlockArgument guifg=orchid guibg=NONE
hi link rubyEscape              Character
hi link rubySymbol              Function
hi link rubyPseudoVariable      Special
hi link rubyBoolean             Boolean
hi link rubyPredefinedVariable  Special
hi link rubyPredefinedConstant  Constant
hi link rubyConstant            Constant
hi link railsMethod             PreProc
hi link rubyDefine              Keyword
hi link rubyAccess              rubyMethod
hi link rubyAttribute           rubyMethod
hi link rubyException           rubyMethod
hi link rubyInclude             Keyword
hi link rubyStringDelimiter     rubyString
hi link rubyRegexp              Regexp
hi link rubyRegexpDelimiter     rubyRegexp
hi link javascriptRegexpString  Regexp
hi link javascriptNumber        Number
hi link javascriptNull          Constant
hi DiffAdd guibg=green guifg=white
hi DiffChange guibg=blue guifg=white
hi DiffText guifg=yellow
hi DiffDelete guibg=red guifg=white
