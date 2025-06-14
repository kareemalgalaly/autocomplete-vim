# autocomplete-vim
An autocomplete engine for vim.

Users can create autocomplete definitions that are invoked by calling `autocomplete#main()` in insert mode using the expression register. 

## Examples

This plugin allows each filetype to register a list of powerful macros, including shorthand expansions, and smart autocomplete. The autocomplete engine does not run constantly but is triggered by a user mapping. The `autocomplete#main(...)` task generates the text to follow the cursor, and should only called in insert mode using the expression register. 

## Getting started
1. Add an insert mode mapping to your vimrc to `<C-R>=autocomplete#main(marker,default,trusted_ft)<CR>`

`marker` : the marker to use to for expressions that set cursor position. you can use "a" if you don't care

`default` : the text to write if no autocomplete definition matches the current text. A decent choice is the same text that triggers the autocomplete. An empty string is possible, but this makes it very difficult to write the text that triggers the mappping.

`trusted_ft` : a colon separated string containing filetypes whose autocomplete definitions are trusted to run vim expressions. `"all"` can be used to allow all filetypes.

For example:
```
inoremap <tab> <C-R>=autocomplete#main("a","\<tab>", "")<CR>
```

2. Use the mapping in insert mode after writing the text trigger. 

For example, assuming <tab> is the mapping and the following autocomplete definition exists
```
['error', '\!`uvm_error(get_type_name(), $sformatf("\:"))']
```

by typing `error<tab>` the text `error` is replaced by 
```
`uvm_error(get_type_name(), $sformatf(""))
```
with the cursor placed in between the quotation

## Defining matches
1. Create a list of match definitions
2. Register the list with the desired filetype

### Match Definition
Each match is definied by a two element list. 

`[match_expr, expansion_expr]`

The match expression is a basic vim-style regular expression (regex) that the autocomplete engine will search for before the cursor's location. If the engine finds the regex, it will generate the autocomplete text using the expansion expression. 

**NOTE:** *Since the match_expr is a vim-style regex, be sure to use `'\v'` unless you want to use vim's non-standard escaping rules.*

The expansion expression can be as simple as plain text, in which it is simply placed where the cursor is. There are however a number of special characters that allow for more complex behaviors. The expansion expression, after being processed for special characters, is executed as if one were to type those exact characters in insert mode. To disable a special character simply escape it. eg) `\n` -> `\\n`

**Summary of Special Characters**
| Character | Description |
| --------- | ----------- |
| `\!`      | Should only be placed at the start of the expression. Interprets the expression as intending to replace the entire regex match. Without it, the new expression is placed after the regex match. |
| `\n`      | A newline character, the same as pressing enter/return. |
| `\N`      | A newline character that preserves indentation. Used when the cursor should be placed on a blank line in the middle of the new text. |
| `\0`      | Replaced with the entire regex match|
| `\1`-`\9` | Replaced with the nth regex group match. |
| `\^2`     | Like \0 ... \9, but make it uppercase. |
| `\_2`     | Like \0 ... \9, but make it lowercase. |
| `\:`      | Indicates the location to place the cursor after expansion is completed. A maximum of one is allowed per expression. If not included, the cursor will remain at the end of the expansion. |
| `\d`      | Replaced by the current date |
| `\t`      | Replaced by the current date and time |
| `\b`      | Replaced by backspacing the previous character |
| `\<\>`    | Replaced by running expand on the enclosed text. Nesting is not supported |
| `\(\)`    | Replaced by the output of the specified vim expression. Requires that the filetype is included in `trusted_ft` list. Nesting is not supported |

### Registration
To register the list of matches use 
```
:call g:autocomplete#register(filetype, matches)
```
where filetype is the string printed by `:set ft`, and matches is the list of matches.

### Examples

**Basic Expansion**
```
['\<error', '\!`uvm_error(get_type_name(), $sformatf("\:"))']
```
This match replaces `error` with a `uvm_error` call placing the cursor between the quotation marks. The `$` prevents the autocomplete for triggering on `error` existing early in the line. In most cases, it is recommended to end match expressions with `$`. The `\<` prevents the autocomplete from matching on words ending in error. It is highly recommended to use single quotes for defining regex strings in vim to prevent the need for excessive escaping.

**Basic Complete**
```
['\vfunction\s+(\S+\s+)*(\w+)\s*\(.*\);'.s:eol, '\N\:\nendfunction : \2']
```
Generates the end of a function declaration after observing the start. Requires that the function's arguments are not split over multiple lines. The `\2` is used to include the function name in the endfunction tag, while the `\N\:\n` is used to place the cursor on a blank line between start and end. The `\N` is required because vim often drops the indent after two consecutive returns with no text.
         
# License
Copyright © 2024 - 2025 Kareem Ahmad

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


