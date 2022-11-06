if set -q KITTY_INSTALLATION_DIR
    set --global KITTY_SHELL_INTEGRATION enabled
    source "$KITTY_INSTALLATION_DIR/shell-integration/fish/vendor_conf.d/kitty-shell-integration.fish"
    set --prepend fish_complete_path "$KITTY_INSTALLATION_DIR/shell-integration/fish/vendor_completions.d"
end

# We should move this somewhere else but it works for now
mkdir -p $HOME/.vim/{backup,swap,undo}

# Do not show any greeting
set --universal --erase fish_greeting
function fish_greeting; end
funcsave fish_greeting &>/dev/null

if isatty
    set -x GPG_TTY (tty)
end
