{ pkgs, currentSystemName, ... }:

{
  xdg.enable = true;

  # global environment
  home.stateVersion = "18.09";
  home.sessionVariables = {
    LANG = "en_US.UTF-8";
    LC_CTYPE = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
    EDITOR = "nvim";
    PAGER = "bat -p";
    MANPAGER = "bat -p";
    NIXNAME = currentSystemName;
    FLEETBACKEND_JDK = "${pkgs.jdk}";
  };

  # user-specific packages.
  # programming environments are done per-project with direnv.
  home.packages = with pkgs; [
    bat
    du-dust
    exa
    fd
    feh
    fzf
    htop
    jq
    jdk
    neofetch
    oh-my-fish
    pwgen
    ripgrep
    scrot
    tree
    watch
    wrk
    xsv
    ucs-fonts
  ];

  # managed config files
  home.file.".inputrc".source = ./config/inputrc;
  home.file.".git-credentials".source = ../../private/git-credentials;
  home.file.".wallpaper".source = ./wallpapers/denali.jpg;

  # window manager
  xsession.windowManager.bspwm = {
    enable = true;
    monitors = {
      "Virtual-1" = [ "1" "2" "3" "4" "5" "6" "7" "8" "9" ];
      "DP-0" = [ "1" "2" "3" "4" "5" "6" "7" "8" "9" ];
      "DP-4" = [ "1" "2" "3" "4" "5" "6" "7" "8" "9" ];
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
    extraConfig = ''
      feh --bg-scale ~/.wallpaper
    '';
  };

  # keyboard shortcuts
  services.sxhkd = {
    enable = true;
    keybindings = {
      "super + Return" = "alacritty";
      "super + @space" = "rofi -show run";
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

  # compositor
  services.picom = {
    enable = true;
    shadow = true;

    settings = {
      "shadow-radius" = 20;
      "corner-radius" = 10;
      "rounded-corners-exclude" = ["! class_g = 'Polybar' && ! class_g = 'Rofi'"];
    };
  };

  # utility toolbars
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

  # global X11 configuration
  xresources.extraConfig = ''
    ${builtins.readFile ./config/Xresources}

    ! monitor names used in configuration
    *monitor1: ${if currentSystemName == "hw-x64" then "DP-4" else "Virtual-1"}
    *monitor2: ${if currentSystemName == "hw-x64" then "DP-0" else ""}
  '';

  # make cursor not tiny on HiDPI screens
  home.pointerCursor = {
    name = "Vanilla-DMZ";
    package = pkgs.vanilla-dmz;
    size = 128;
    x11.enable = true;
  };

  # program launcher
  programs.rofi = {
    enable = true;
    font = "IosevkaJB 12";
    theme = "paper-float";
  };

  # per-project environment manager
  programs.direnv = {
    enable = true;
  };

  # shell
  programs.fish = {
    enable = true;
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
      pbcopy = "xclip";
      pbpaste = "xclip -o";
    };
    plugins = [
      {
        name = "theme-bobthefish";
        src = pkgs.fetchFromGitHub {
          owner = "oh-my-fish";
          repo = "theme-bobthefish";
          rev = "2dcfcab653ae69ae95ab57217fe64c97ae05d8de";
          sha256 = "sha256-jBbm0wTNZ7jSoGFxRkTz96QHpc5ViAw9RGsRBkCQEIU=";
        };
      }
    ];
  };
  programs.kitty = {
    enable = true;
    extraConfig = builtins.readFile ./config/kitty;
  };
  programs.alacritty = {
    enable = true;
    settings = {
      env.TERM = "xterm-256color";
      window = {
        padding = {
          x = 4;
          y = 4;
        };
        decorations = "none";
      };
      font = {
        normal = {
          family = "IosevkaJB";
          style = "Semibold";
        };
        italic = {
          family = "IosevkaJB";
          style = "Semibold Italic";
        };
        bold = {
          family = "IosevkaJB";
          style = "Bold";
        };
        bold_italic = {
          family = "IosevkaJB";
          style = "Bold Italic";
        };
        size = 11;
      };
      cursor = {
        style = "Beam";
        unfocused_hollow = true;
      };
      colors = {
        primary = {
          background = "0x282c34";
          foreground = "0xdcdfe4";
        };
        normal = {
          black = "0x000000";
          red = "0xe06c75";
          green = "0xe5c07b";
          yellow = "0xebcb8b";
          blue = "0x61afef";
          magenta = "0xc678dd";
          cyan = "0x56b6c2";
          white = "0xdcdfe4";
        };
        bright = {
          black = "0xa9aaab";
          red = "0xe06c75";
          green = "0xe5c07b";
          yellow = "0xebcb8b";
          blue = "0x61afef";
          magenta = "0xc678dd";
          cyan = "0x56b6c2";
          white = "0xdcdfe4";
        };
      };
    };
  };

  # git
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

  # editor
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    package = pkgs.neovim-nightly;
    plugins = with pkgs; [
      # theme + powerline
      localVimPlugins.catppuccin-nvim
      vimPlugins.lightline-vim

      # LSP
      vimPlugins.nvim-lspconfig

      # Languages
      vimPlugins.rust-vim
      vimPlugins.vim-nix

      # completion
      vimPlugins.cmp-nvim-lsp
      vimPlugins.cmp-buffer
      vimPlugins.cmp-path
      vimPlugins.cmp-cmdline
      vimPlugins.nvim-cmp
      vimPlugins.cmp-vsnip
      vimPlugins.vim-vsnip

      # popups
      vimPlugins.popfix
      localVimPlugins.popui-nvim

      # tree sitter
      (vimPlugins.nvim-treesitter.withPlugins (plugins: with plugins; [
        tree-sitter-c
        tree-sitter-cpp
        tree-sitter-go
        tree-sitter-nix
        tree-sitter-rust
      ]))
    ];
    extraConfig = builtins.readFile ./config/nvim;

    # Language servers
    extraPackages = with pkgs; [
      rust-analyzer
      gopls
    ];
  };

  # gnupg
  programs.gpg.enable = true;
  services.gpg-agent = {
    enable = true;
    pinentryFlavor = "tty";

    # cache the keys forever so we don't get asked for a password
    defaultCacheTtl = 31536000;
    maxCacheTtl = 31536000;
  };
}
