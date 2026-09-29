# Information about zsh dotfiles

-   **Interactive** shells are intended for human use, or generally for continuous, bidirectional, multi-turn interactions.
-   **Login** shells are intended for initial setup when first entering an environment (though OSX loads them for every new user shell).

## execution order

1.  zshenv (always).
    -   Universal behavior changes, e.g. $PATH, $EDITOR, $PAGER. Specify $ZDOTDIR to change location for remaining user zsh dotfiles.
1.  zprofile (login shells)
    -   According to the zsh documentation, ".zprofile is meant as an alternative to .zlogin for ksh fans;
        the two are not intended to be used together, although this could certainly be done if desired."
1.  zshrc (interactive shells)
    -   Configure desired behavior for interactive shells - prompt, completions, hotkeys, etc
1.  zlogin (login shells)
    -   post-zshrc alternative to zprofile

On quit:

1.  zlogout (login shells)

In each phase, first from system `/etc/FILE`, then from user `$ZDOTDIR/FILE` (default: `~/FILE`)

### references

-   <https://unix.stackexchange.com/questions/71253/what-should-shouldnt-go-in-zshenv-zshrc-zlogin-zprofile-zlogout>

### my custom additions

1.  zpath
    -   when is it sourced?
        -   login shells: .zprofile
        -   non-login shells: .zshenv
    -   what does it hold?
        -   universal behavior changes
    -   why not in zshenv?
        -   because /etc/zprofile modifies PATH and puts a bunch of system binaries earlier than I want, but I don't want to modify default OS dotfiles

see: <https://www.zsh.org/mla/users/2003/msg00600.html>
