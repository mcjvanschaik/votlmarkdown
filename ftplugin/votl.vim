"# Markdownotl, Vim Markdown Outline conversion

if exists("Markdownotl_loaded")
	finish
endif
let Markdownotl_loaded=1

" Convert from and to markdown or otl
"VimOutliner to Markdown {{{
function! VO2MD()
	let lines = []
	let was_body = 0
	for line in getline(1,'$')
		if line =~ '^\t*[^:\t]'
			let indent_level = len(matchstr(line, '^\t*'))
			if was_body " <= remove this line to have body lines separated
				call add(lines, '')
			endif " <= remove this line to have body lines separated
			call add(lines, substitute(line, '^\(\t*\)\([^:\t].*\)', '\=repeat("#", indent_level + 1)." ".submatch(2)', ''))
			call add(lines, '')
			let was_body = 0
		else
			call add(lines, substitute(line, '^\t*: ', '', ''))
			let was_body = 1
		endif
	endfor
	silent %d _
	call setline(1, lines)
endfunction"}}}
"Markdown  to VimOutliner  {{{
function! MD2VO()
	let lines = []
	for line in getline(1,'$')
		if line =~ '^\s*$'
			continue
		endif
		if line =~ '^#\+'
			let indent_level = len(matchstr(line, '^#\+')) - 1
			call add(lines, substitute(line, '^#\(#*\) ', repeat("\<Tab>", indent_level), ''))
		else
			call add(lines, substitute(line, '^', repeat("\<Tab>", indent_level) . ': ', ''))
		endif
	endfor
	silent %d _
	call setline(1, lines)
endfunction "}}}
" Toggle between file formats and save in new file with other filetype {{{
function! VOMDToggle()
	let extension = expand("%:e")
	if extension == "otl"
		call VO2MD()
		write! %:r.md
		set filetype=markdown
	elseif extension == "md"
		call MD2VO()
		write! %:r.otl
		set filetype=votl
	endif
endfunction "}}}

command -nargs=0 Vo2md :call VO2MD()
command -nargs=0 Md2vo :call MD2VO()
command -nargs=0 VMToggle :call VOMDToggle()
noremap <leader>vm :call VOMDToggle()

" vim:set foldmethod=marker foldlevel=0 filetype=vim:
