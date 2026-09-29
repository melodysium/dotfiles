# dotfiles

My dotfiles.

If any of the productivity hacks here interest you, feel free to message me.

## Notable elements

-   synced with [yadm](https://yadm.io/)
-   OS: Mac OSX
-   shell: ZSH
-   packages: Homebrew wherever possible (with Brewfile)
-   "natural" shell text manipulation using [zsh-shift-select](https://github.com/jirutka/zsh-shift-select), [iterm2 config](./.config/iterm2/com.googlecode.iterm2.plist), and some other configs
-   [shell abbreviations](./.config/zsh-abbr/user-abbreviations) using [zsh-abbr](https://github.com/olets/zsh-abbr)
-   [keyboard shortcuts](./.config/karabiner/karabiner.json) using [karabiner-elements](https://karabiner-elements.pqrs.org/)
-   [git custom commands](./my-git-custom-commands/), especially:
    -   [git switch-fzf](./my-git-custom-commands/git-switch-fzf)
    -   [git merge-default](./my-git-custom-commands/git-merge-default), [git switch-default](./my-git-custom-commands/git-switch-default)
-   [“fuzzy” cd command](./.config/zsh/.zshrc_prompt) using [zoxide](https://github.com/ajeetdsouza/zoxide)
-   [VSCode editor wrapper script](./.local/bin/code-term-editor) which returns to the shell once VS Code is closed
-   [re-install bootstrap script](./.config/yadm/bootstrap) using [brew bundle/Brewfile](https://docs.brew.sh/Brew-Bundle-and-Brewfile) and [yadm bootstrap](https://yadm.io/docs/bootstrap)
-   [git pre-push hook](./my-git-template-dir/hooks/pre-push.stash-verify-stashpop) to stash uncommitted changes and run `mvn clean verify`
