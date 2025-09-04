" Syntax highlighting for timeline filetype

if exists("b:current_syntax")
  finish
endif

" Define highlights
syntax match TimelineHeader "^Timeline.*"
syntax match TimelineRule "^=\+$"
syntax match TimelineVisited "^👁️.*"
syntax match TimelineEdited "^✏️.*"
syntax match TimelineTime "\[\d\d:\d\d:\d\d\]"
syntax match TimelinePath " [~/].*$"
" Note: File icons are highlighted separately via nvim API highlights

" Link to standard highlight groups
highlight link TimelineHeader Title
highlight link TimelineRule Comment
highlight link TimelineVisited Normal
highlight link TimelineEdited Special
highlight link TimelineTime Number
highlight link TimelinePath String

let b:current_syntax = "timeline"