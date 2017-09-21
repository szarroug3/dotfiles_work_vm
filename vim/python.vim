syn match FunctionCall /\v\zs\w+\ze\(/
hi link FunctionCall Identifier
syn region Comment start=/\v^\s*"""/ end=/"""/
