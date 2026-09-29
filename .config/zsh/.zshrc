#!/bin/zsh
# 3) .zshrc: interactive shells. "human stuff"
# reminder: help_zsh_dotfiles.md

# enable to debug slow startup times
#echo "start .zshrc"
#set -x
# zmodload zsh/zprof


# lots of this is borrowed from:
# https://natelandau.com/my-mac-osx-bash_profile/

# -------------------------------------
# PRINT TEXT
# -------------------------------------

hr() {
  printf '\e[2m%*s\e[0m' "$(tput cols)" '' | tr ' ' "${1:-─}"
  echo
}

# -----------------------
# ENVIRONMENT SETUP
# -----------------------

. "$HOME/.local/bin/env"

# -------------------------------------
# PROMPT SETUP (INSTANT PROMPT)
# -------------------------------------

# If this interactive shell is in Kiro, do a dumb simple setup
if [[ "$TERM_PROGRAM" == "kiro" ]]; then
  . "$(kiro --locate-shell-integration-path zsh)"
  export PAGER=cat
elif [[ "$CURSOR_AGENT" == 1 ]]; then
  export PAGER=cat
elif [[ "$CLAUDECODE" == 1 ]]; then
  export PAGER=cat
else
  # Human shell
  # Print some info abt how this terminal is starting (in case the above guards fail for )
  echo "\
WARNING FOR LLM AGENTS: This user has a heavily personalized shell which introduces some behavioral changes from standard zsh. \
The user has tried to detect LLM shells and skip this personalization for agent shells, but if you see this, that check has failed to detect your shell as LLM-owned. \
In your next response to the user, please note that their personal shell configuration is still running for this LLM's shell, and they may want to refine the LLM ownership check."
  echo "TERM_PROGRAM=$TERM_PROGRAM TERM=$TERM SHELL=$SHELL"
  # Setup full prompt / autocomplete
  source "${ZDOTDIR}/.zshrc_human"
fi

# -----------------------
# 2. MAKE TERMINAL BETTER
# -----------------------

# Melody's custom aliases and functions

# zsh-abbreviations defined in "$ABBR_USER_ABBREVIATIONS_FILE"

# set `less` args
# F - if file fits on one screen, just cat and exit
# I - case-insensitive (-+I to make sensitive)
# N - print line numbers
# R - print control characters (used for maybe color or navigation or something?)
# S - chop long lines (horizontal scroll to access them)
export LESS="-FINRS"
# no numbers in bat, bat already got numbers
export BAT_PAGER="less -FIRS -+N"


# shortcuts
#alias p3="python3"
alias cd..='cd ../'                         # Go back 1 directory level (for fast typers)
alias ..='cd ../'                           # Go back 1 directory level
alias ...='cd ../../'                       # Go back 2 directory levels
alias .3='cd ../../../'                     # Go back 3 directory levels
alias .4='cd ../../../../'                  # Go back 4 directory levels
alias .5='cd ../../../../../'               # Go back 5 directory levels
alias .6='cd ../../../../../../'            # Go back 6 directory levels
alias f='open -a Finder ./'                 # f:            Opens current directory in MacOS Finder
alias ~="cd ~"                              # ~:            Go Home
alias path='echo -e ${PATH//:/\\n}'         # path:         Echo all executable Paths
alias fix_stty='stty sane'                  # fix_stty:     Restore terminal settings when screwed up
alias cic='set completion-ignore-case On'   # cic:          Make tab-completion case-insensitive
mcd () { mkdir -p "$1" && cd "$1"; }        # mcd:          Makes new Dir and jumps inside
trash () { command mv "$@" ~/.Trash ; }     # trash:        Moves a file to the MacOS trash
ql () { qlmanage -p "$*" >& /dev/null; }    # ql:           Opens any file in MacOS Quicklook Preview
alias DT='tee ~/Desktop/terminalOut.txt'    # DT:           Pipe content to file on MacOS Desktop
alias bitcoin="open /System/Library/Image\ Capture/Devices/VirtualScanner.app/Contents/Resources/simpledoc.pdf"
alias mdlint-global='markdownlint-cli2 --config "$HOME/.config/markdownlint-cli2/.markdownlint-cli2.jsonc"'

# open IntelliJ IDEA with `idea` command, but make it behave like `code` (open and detach)
function idea () {
  /Applications/IntelliJ\ IDEA.app/Contents/MacOS/idea "$@" >/dev/null 2>&1 & disown
}

# use python3 always
alias python="python3"
alias pip="python3 -m pip"
#alias python3="uv run python3" # run with uv

# open man pages in browser
function webman () {
  man "$1" | col -b > "/tmp/$1"
  open -a "Firefox" "/tmp/$1"
}

# using ripgrep combined with preview
# find-in-file - usage: fif <searchTerm>
fif() {
  if [ ! "$#" -gt 0 ]; then echo "Need a string to search for!"; return 1; fi
  rg --files-with-matches --no-messages "$1" | fzf --preview "highlight -O ansi -l {} 2> /dev/null | rg --colors 'match:bg:yellow' --ignore-case --pretty --context 10 '$1' || rg --ignore-case --pretty --context 10 '$1' {}"
}

fif-hidden() {
  if [ ! "$#" -gt 0 ]; then echo "Need a string to search for!"; return 1; fi
  rg --files-with-matches --no-messages --hidden "$1" | fzf --preview "highlight -O ansi -l {} 2> /dev/null | rg --colors 'match:bg:yellow' --ignore-case --pretty --context 10 '$1' || rg --ignore-case --pretty --context 10 '$1' {}"
}

# use Homebrew's git
#alias git='/opt/homebrew/bin/git' see

# custom command to make little scripts and make them executable
function e-sh() {
  if [[ $# -eq 0 ]]; then echo "usage: touch-sh [filename] <file-contents>" & return 1; fi
  printf "$2" > "$1"
  chmod +x "$1"
  $EDITOR $1
}


# Maven aliases for multi-module development

# Build a module and all its dependencies
alias mvn-build-deps='mvn clean install -am -pl'

# Build a module and everything that depends on it
alias mvn-build-dependents='mvn clean install -amd -pl'

# Build a module, its dependencies, and dependents
alias mvn-build-all-related='mvn clean install -am -amd -pl'

# Examples:
# mvn-build-deps public-api-v2

#   lr:  Full Recursive Directory Listing
#   ------------------------------------------
alias lr='ls -R | grep ":$" | sed -e '\''s/:$//'\'' -e '\''s/[^-][^\/]*\//--/g'\'' -e '\''s/^/   /'\'' -e '\''s/-/|/'\'' | less'

#   mans:   Search manpage given in agument '1' for term given in argument '2' (case insensitive)
#           displays paginated result with colored search terms and two lines surrounding each hit.            Example: mans mplayer codec
#   --------------------------------------------------------------------
    mans () {
        man $1 | grep -iC2 --color=always $2 | less
    }

# urlencode/urldecode utils
alias urldecode='python -c "import sys, urllib as ul; \
    print ul.unquote_plus(sys.argv[1])"'
alias urlencode='python -c "import sys, urllib as ul; \
    print ul.quote_plus(sys.argv[1])"'

# `refresh cmd` executes clears the terminal and prints
# the output of `cmd` in it.
function refresh {
  tput clear || exit 2; # Clear screen. Almost same as echo -en '\033[2J';
  bash -ic "$@";
}

# Like watch, but with color
function cwatch {
   while true; do
     CMD="$@";
     # Cache output to prevent flicker. Assigning to variable
     # also removes trailing newline.
     output=`refresh "$CMD"`;
     # Exit if ^C was pressed while command was executing or there was an error.
     exitcode=$?; [ $exitcode -ne 0 ] && exit $exitcode
     printf '%s' "$output";  # Almost the same as echo $output
     sleep 1;
   done;
}

function cp_compare {
  # TODO: finish later
  # compare against source file
  SOURCE_FILE="$HOME/my-git-hooks/prepare-commit-msg.add-ticket-in-msg-prefix"

  # expect $1 to be the file we're looking for
  if [ ! -f "$1" ]; then
    echo "not a file: [$1]"
    exit 1
  fi
  test_file="$1"

  # diff between source_file and test_file
  diff "$test_file" "$SOURCE_FILE"
  if [ $? -eq 0 ]; then
    echo "no difference; skipping"
    echo
    exit 0
  fi

  # check if user wants to replace
  printf "want to replace? [Enter] for yes, [CTRL]+[D] for no: "
  read
  if [ $? -eq 0 ]; then
    echo "ok!"
    cp "$SOURCE_FILE" "$test_file"
  else
    echo "skipping..."
  fi
  echo
}

# list env variables
# from comments on https://www.reddit.com/r/commandline/comments/o5iu5x/4_useful_fzf_tricks_for_your_terminal/
# i added the bit abt printing with --preview
# andrew found --preview-window=wrap and had idea for the bat coloring
function list-env {
  var=$(printenv | cut -d= -f1 | fzf --preview-window=wrap --preview 'printf "%s=%q" {1} "$(printenv {1})" | bat -l bash --color=always --style=plain') \
    && echo "$var=$(printenv "$var")" \
    && unset var
}

#   rand:   Print a single random number, either 'under' or 'between' two bounds
#   ----------------------------------------------------------------------------
rand () {
  if [ $1 = 'between' ]; then
    lo=$2
    hi=$3
    diff=$((hi-lo))
    num=$(( (RANDOM % diff) + lo ))
    echo $num
  elif [ $1 = 'under' ]; then
    rand between 0 $2
  else
    >&2 echo "error: unknown argument $1."
    >&2 echo "usage: rand [under EXCLUSIVE] | [between INCLUSIVE EXCLUSIVE]"
  fi
}

#   -------------------------------
#   3. FILE AND FOLDER MANAGEMENT
#   -------------------------------

zipf () { zip -r "$1".zip "$1" ; }          # zipf:         To create a ZIP archive of a folder
alias numFiles='echo $(ls -1 | wc -l)'      # numFiles:     Count of non-hidden files in current dir

#   cdf:  'Cd's to frontmost window of MacOS Finder
#   ------------------------------------------------------
    cdf () {
        currFolderPath=$( /usr/bin/osascript <<EOT
            tell application "Finder"
                try
            set currFolder to (folder of the front window as alias)
                on error
            set currFolder to (path to desktop folder as alias)
                end try
                POSIX path of currFolder
            end tell
EOT
        )
        echo "cd to \"$currFolderPath\""
        cd "$currFolderPath"
    }

#   extract:  Extract most know archives with one command
#   ---------------------------------------------------------
    extract () {
        if [ -f $1 ] ; then
          case $1 in
            *.tar.bz2)   tar xjf $1     ;;
            *.tar.gz)    tar xzf $1     ;;
            *.bz2)       bunzip2 $1     ;;
            *.rar)       unrar e $1     ;;
            *.gz)        gunzip $1      ;;
            *.tar)       tar xf $1      ;;
            *.tbz2)      tar xjf $1     ;;
            *.tgz)       tar xzf $1     ;;
            *.zip)       unzip $1       ;;
            *.Z)         uncompress $1  ;;
            *.7z)        7z x $1        ;;
            *)     echo "'$1' cannot be extracted via extract()" ;;
             esac
         else
             echo "'$1' is not a valid file"
         fi
    }


#   ---------------------------
#   4. SEARCHING
#   ---------------------------

alias qfind="find . -name "                 # qfind:    Quickly search for file
ff () { /usr/bin/find . -name "$@" ; }      # ff:       Find file under the current directory
ffs () { /usr/bin/find . -name "$@"'*' ; }  # ffs:      Find file whose name starts with a given string
ffe () { /usr/bin/find . -name '*'"$@" ; }  # ffe:      Find file whose name ends with a given string

#   spotlight: Search for a file using MacOS Spotlight's metadata
#   -----------------------------------------------------------
    spotlight () { mdfind "kMDItemDisplayName == '$@'wc"; }


#   ---------------------------
#   5. PROCESS MANAGEMENT
#   ---------------------------

#   findPid: find out the pid of a specified process
#   -----------------------------------------------------
#       Note that the command name can be specified via a regex
#       E.g. findPid '/d$/' finds pids of all processes with names ending in 'd'
#       Without the 'sudo' it will only find processes of the current user
#   -----------------------------------------------------
    findPid () { lsof -t -c "$@" ; }

#   memHogsTop, memHogsPs:  Find memory hogs
#   -----------------------------------------------------
    alias memHogsTop='top -l 1 -o rsize | head -20'
    alias memHogsPs='ps wwaxm -o pid,stat,vsize,rss,time,command | head -10'

#   cpuHogs:  Find CPU hogs
#   -----------------------------------------------------
    alias cpu_hogs='ps wwaxr -o pid,stat,%cpu,time,command | head -10'

#   topForever:  Continual 'top' listing (every 10 seconds)
#   -----------------------------------------------------
    alias topForever='top -l 9999999 -s 10 -o cpu'

#   ttop:  Recommended 'top' invocation to minimize resources
#   ------------------------------------------------------------
#       Taken from this macosxhints article
#       http://www.macosxhints.com/article.php?story=20060816123853639
#   ------------------------------------------------------------
    alias ttop="top -R -F -s 10 -o rsize"

#   my_ps: List processes owned by my user:
#   ------------------------------------------------------------
    my_ps() { ps $@ -u $USER -o pid,%cpu,%mem,start,time,bsdtime,command ; }


#   ---------------------------
#   6. NETWORKING
#   ---------------------------

alias myip='curl ip.appspot.com'                    # myip:         Public facing IP Address
alias netCons='lsof -i'                             # netCons:      Show all open TCP/IP sockets
alias flushDNS='dscacheutil -flushcache'            # flushDNS:     Flush out the DNS Cache
alias lsock='sudo /usr/sbin/lsof -i -P'             # lsock:        Display open sockets
alias lsockU='sudo /usr/sbin/lsof -nP | grep UDP'   # lsockU:       Display only open UDP sockets
alias lsockT='sudo /usr/sbin/lsof -nP | grep TCP'   # lsockT:       Display only open TCP sockets
alias ipInfo0='ipconfig getpacket en0'              # ipInfo0:      Get info on connections for en0
alias ipInfo1='ipconfig getpacket en1'              # ipInfo1:      Get info on connections for en1
alias openPorts='sudo lsof -i | grep LISTEN'        # openPorts:    All listening connections
alias showBlocked='sudo ipfw list'                  # showBlocked:  All ipfw rules inc/ blocked IPs

#   ii:  display useful host related informaton
#   -------------------------------------------------------------------
    ii() {
        echo -e "\nYou are logged on ${RED}$HOST"
        echo -e "\nAdditionnal information:$NC " ; uname -a
        echo -e "\n${RED}Users logged on:$NC " ; w -h
        echo -e "\n${RED}Current date :$NC " ; date
        echo -e "\n${RED}Machine stats :$NC " ; uptime
        echo -e "\n${RED}Current network location :$NC " ; scselect
        echo -e "\n${RED}Public facing IP Address :$NC " ;myip
        #echo -e "\n${RED}DNS Configuration:$NC " ; scutil --dns
        echo
    }


#   ---------------------------------------
#   7. SYSTEMS OPERATIONS & INFORMATION
#   ---------------------------------------

#   cleanupDS:  Recursively delete .DS_Store files
#   -------------------------------------------------------------------
    alias cleanupDS="find . -type f -name '*.DS_Store' -ls -delete"

#   finderShowHidden:   Show hidden files in Finder
#   finderHideHidden:   Hide hidden files in Finder
#   -------------------------------------------------------------------
    alias finderShowHidden='defaults write com.apple.finder ShowAllFiles TRUE'
    alias finderHideHidden='defaults write com.apple.finder ShowAllFiles FALSE'

#   cleanupLS:  Clean up LaunchServices to remove duplicates in the "Open With" menu
#   -----------------------------------------------------------------------------------
    alias cleanupLS="/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user && killall Finder"

#    screensaverDesktop: Run a screensaver on the Desktop
#   -----------------------------------------------------------------------------------
    alias screensaverDesktop='/System/Library/Frameworks/ScreenSaver.framework/Resources/ScreenSaverEngine.app/Contents/MacOS/ScreenSaverEngine -background'

#   ---------------------------------------
#   8. WEB DEVELOPMENT
#   ---------------------------------------

httpHeaders () { /usr/bin/curl -I -L $@ ; }             # httpHeaders:      Grabs headers from web page

#   httpDebug:  Download a web page and show info on what took time
#   -------------------------------------------------------------------
    httpDebug () { /usr/bin/curl $@ -o /dev/null -w "dns: %{time_namelookup} connect: %{time_connect} pretransfer: %{time_pretransfer} starttransfer: %{time_starttransfer} total: %{time_total}\n" ; }


#   ---------------------------------------
#   9. LOCAL LLM SHORTCUTS
#   ---------------------------------------

# from:
# - https://huggingface.co/collections/Qwen/qwen3
# - https://huggingface.co/collections/unsloth/qwen3

function llama-cli-env () {
 if [[ $# -lt 1 ]]; then echo "requires 1 argument (name of env var holding model config)" >2; fi
 llama-cli ${(z)1} --color ${@:2}
}

function llama-server-env () {
 if [[ $# -lt 1 ]]; then echo "requires 1 argument (name of env var holding model config)" >2; fi
 llama-server ${(z)1} ${@:2}
}

# general-purpose
function qwen3-general() {
  if [[ $# -ne 1 ]]; then echo "requires 1 argument (model name)" >2; fi
  echo "-hf $1 --jinja -ngl 99 -sm row --temp 0.6 --top-k 20 --top-p 0.95 --min-p 0 --presence-penalty 1.5 -c 32768 -n 32768 --no-context-shift"
}

# memory: ~33GB; MoE (mixture-of-experts) should also give faster compute time
# https://huggingface.co/Qwen/Qwen3-30B-A3B-GGUF
export QWEN3_30B="$(qwen3-general Qwen/Qwen3-30B-A3B-GGUF:Q8_0)"

# memory: ~20GB
# https://huggingface.co/Qwen/Qwen3-14B-GGUF
export QWEN3_14B="$(qwen3-general Qwen/Qwen3-14B-GGUF:Q8_0)"

# memory: ~14GB
# https://huggingface.co/Qwen/Qwen3-8B-GGUF
export QWEN3_8B="$(qwen3-general Qwen/Qwen3-8B-GGUF:Q8_0)"

# memory: ~10GB
# https://huggingface.co/Qwen/Qwen3-4B-GGUF
export QWEN3_4B="$(qwen3-general Qwen/Qwen3-4B-GGUF:Q8_0)"

# memory: ~6GB
# https://huggingface.co/Qwen/Qwen3-1.7B-GGUF
export QWEN3_1_7B="$(qwen3-general Qwen/Qwen3-1.7B-GGUF:Q8_0)"

# visual
# memory: 11GB
# https://huggingface.co/Qwen/Qwen3-VL-8B-Thinking-GGUF
export QWEN3_VL_8B="-hf Qwen/Qwen3-VL-8B-Thinking-GGUF -c 32768" # can go up to 256k

# coding
# memory: ~33GB
# https://huggingface.co/unsloth/Qwen3-Coder-30B-A3B-Instruct-GGUF
export QWEN3_CODER_30B="-hf unsloth/Qwen3-Coder-30B-A3B-Instruct-GGUF:Q8_0 --jinja -ngl 99 -sm row --temp 0.7 --top-k 20 --top-p 0.8 --min-p 0 --presence-penalty 1.05 -c 32768 -n 32768 --no-context-shift"

export LOCAL_ZSHRC="${ZDOTDIR}/.zshrc.local"
if [[ -f "$LOCAL_ZSHRC" ]]; then
  source "$LOCAL_ZSHRC"
fi

# zprof
##set +x
#echo "end .zshrc"

