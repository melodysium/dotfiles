" Automatically soft-wrap at edge of window when writing git commit messages
" https://stackoverflow.com/questions/36950231/auto-wrap-lines-in-vim-without-inserting-newlines
" https://stackoverflow.com/questions/60707155/prevent-automatic-line-wrapping-when-editing-git-commit-message-in-vim
setlocal number " (optional - will help to visually verify that it's working)
setlocal textwidth=0
setlocal wrapmargin=0
setlocal wrap
setlocal linebreak " (optional - breaks by word rather than character)
