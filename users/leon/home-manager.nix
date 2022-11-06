{ config, lib, pkgs, ... }:

let sources = import ../../nix/sources.nix; in {
  xdg.enable = true;

  home.packages = [
    pkgs.bat
    pkgs.exa
    pkgs.du-dust
    pkgs.fzf
    pkgs.htop
    pkgs.jq
    pkgs.go
    pkgs.gopls
    pkgs.rustup
    pkgs.tree
    pkgs.watch
    pkgs.ripgrep
    pkgs.feh
  ];

  home.sessionVariables = {
    LANG = "en_US.UTF-8";
    LC_CTYPE = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
    EDITOR = "nvim";
    PAGER = "bat -p";
    MANPAGER = "bat -p";
  };

  home.file.".inputrc".source = ./config/inputrc;
  home.file.".git-credentials".source = ../../private/git-credentials;

  xdg.configFile."nvim/parser/proto.so".source = "${pkgs.tree-sitter-proto}/parser";
  xdg.configFile."nvim/queries/proto/folds.scm".source = "${sources.tree-sitter-proto}/queries/folds.scm";
  xdg.configFile."nvim/queries/proto/highlights.scm".source = "${sources.tree-sitter-proto}/queries/highlights.scm";
  xdg.configFile."nvim/queries/proto/textobjects.scm".source = ./config/textobjects.scm;

  services.picom = {
    enable = true;
    shadow = true;

    # in home-manager 22.11, this moves to settings, see below
    extraOptions = ''
      shadow-radius = 20;
      corner-radius = 10;
      rounded-corners-exclude = [
        "! class_g = 'Polybar' && ! class_g = 'Rofi'"
      ];
    '';

    #settings = {
    #  "shadow-radius" = 20;
    #  "corner-radius" = 10;
    #  "rounded-corners-exclude" = ["! class_g = 'Polybar' && ! class_g = 'Rofi'"];
    #};
  };

  xsession.windowManager.bspwm = {
    enable = true;
    monitors = {
      "Virtual-1" = [ "1" "2" "3" "4" "5" "6" "7" "8" "9" ];
    };
    alwaysResetDesktops = true;
    settings = {
      border_width = 4;
      border_radius = 10;
      focused_border_color = "#8fbcbb";
      active_border_color = "#2e3440";
      normal_border_color = "#2e3440";
      top_padding = 60;
      window_gap = 20;
      borderless_monocle = true;
      gapless_monocle = false;
      split_ratio = 0.52;
      focus_follows_pointer = true;
    };
  };

  services.sxhkd = {
    enable = true;
    keybindings = {
      "super + Return" = "kitty";
      "super + @space" = "rofi";
      "super + shift + q" = "bspc quit";
      # focus node in direction
      "super + {_,shift + }{Left,Down,Up,Right}" = "bspc node -{f,s} {west,south,north,east}";
      # switch desktops
      "super + 1" = "bspc desktop -f 1";
      "super + 2" = "bspc desktop -f 2";
      "super + 3" = "bspc desktop -f 3";
      "super + 4" = "bspc desktop -f 4";
      "super + 5" = "bspc desktop -f 5";
      "super + 6" = "bspc desktop -f 6";
      "super + 7" = "bspc desktop -f 7";
      "super + 8" = "bspc desktop -f 8";
      "super + 9" = "bspc desktop -f 9";
      # move node to desktop
      "super + shift + 1" = "bspc node -d 1";
      "super + shift + 2" = "bspc node -d 2";
      "super + shift + 3" = "bspc node -d 3";
      "super + shift + 4" = "bspc node -d 4";
      "super + shift + 5" = "bspc node -d 5";
      "super + shift + 6" = "bspc node -d 6";
      "super + shift + 7" = "bspc node -d 7";
      "super + shift + 8" = "bspc node -d 8";
      "super + shift + 9" = "bspc node -d 9";
    };
  };

  services.polybar = {
    enable = true;
    config = ./config/polybar;
    script = ''
      polybar desktop &
      polybar status &
      polybar title &
    '';
  };

  systemd.user.services.polybar.Install.WantedBy = [ "graphical-session.target" "tray.target" ];

  programs.rofi = {
    enable = true;
    font = "IosevkaJB 12";
    theme = "paper-float";
  };

  programs.gpg.enable = true;

  programs.direnv = {
    enable = true;
    config = {
      whitelist = {
        prefix= [
        ];
        exact = ["$HOME/.envrc"];
      };
    };
  };

  programs.fish = {
    enable = true;
    interactiveShellInit = lib.strings.concatStrings (lib.strings.intersperse "\n" [
      "source ${sources.theme-bobthefish}/functions/fish_prompt.fish"
      "source ${sources.theme-bobthefish}/functions/fish_right_prompt.fish"
      "source ${sources.theme-bobthefish}/functions/fish_title.fish"
      (builtins.readFile ./config/config.fish)
      "set -g SHELL ${pkgs.fish}/bin/fish"
    ]);

    shellAliases = {
      ga = "git add";
      gc = "git commit";
      gca = "git commit --all";
      gco = "git co";
      gfa = "git fap";
      gd = "git diff";
      gl = "git lg";
      gp = "git push";
      gs = "git status";
      gt = "git tag";

      vi = "nvim";
      vim = "nvim";

      pbcopy = "xclip";
      pbpaste = "xclip -o";
    };

    plugins = map (n: {
      name = n;
      src  = sources.${n};
    }) [
      "fish-fzf"
      "fish-foreign-env"
      "theme-bobthefish"
    ];
  };

  programs.git = {
    enable = true;
    userName = "Leon Breedt";
    userEmail = "leon@sector42.io";
    signing = {
      key = "8EDF16F241C988805D6019FDC7FC3270F57FA785";
      signByDefault = true;
    };
    aliases = {
      co = "checkout";
      ca = "commit --all";
      fa = "fetch --all";
      fap = "!git fetch --all && git pull --autostash";
      lg = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(r) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative";
      st = "status";
      root = "rev-parse --show-toplevel";
    };
    extraConfig = {
      branch.autosetuprebase = "always";
      color.ui = true;
      color.diff = "auto";
      color.status = "auto";
      color.interactive = "auto";
      color.pager = true;
      core.askPass = "";
      credential.helper = "store";
      github.user = "leonbreedt";
      push.default = "tracking";
      init.defaultBranch = "main";
    };
  };

  programs.go = {
    enable = true;
    goPath = "$HOME/.go";
    goPrivate = [ "github.com/leonbreedt" ];
  };

  programs.kitty = {
    enable = true;
    extraConfig = builtins.readFile ./config/kitty;
  };

  programs.neovim = {
    enable = true;
    package = pkgs.neovim-nightly;

    plugins = with pkgs; [
      customVim.vim-cue
      customVim.vim-fish
      customVim.vim-fugitive
      customVim.vim-pgsql
      customVim.vim-tla
      customVim.pigeon
      customVim.AfterColors

      customVim.vim-nord
      customVim.nvim-lspconfig
      customVim.nvim-treesitter
      customVim.nvim-treesitter-playground
      customVim.nvim-treesitter-textobjects

      vimPlugins.ctrlp
      vimPlugins.vim-airline
      vimPlugins.vim-airline-themes
      vimPlugins.vim-eunuch
      vimPlugins.vim-gitgutter

      vimPlugins.vim-markdown
      vimPlugins.vim-nix
      vimPlugins.typescript-vim
    ];

    extraConfig = (import ./vim-config.nix) { inherit sources; };
  };

  services.gpg-agent = {
    enable = true;
    pinentryFlavor = "tty";

    # cache the keys forever so we don't get asked for a password
    defaultCacheTtl = 31536000;
    maxCacheTtl = 31536000;
  };

  xresources.extraConfig = builtins.readFile ./config/Xresources;

  # make cursor not tiny on HiDPI screens
  home.pointerCursor = {
    name = "Vanilla-DMZ";
    package = pkgs.vanilla-dmz;
    size = 128;
    x11.enable = true;
  };
}

