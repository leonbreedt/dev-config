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
    pkgs.rofi
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

  xdg.configFile."rofi/config.rasi".text = builtins.readFile ./config/rofi;

  xdg.configFile."bspwm/bspwmrc".text = builtins.readFile ./config/bspwmrc;
  xdg.configFile."bspwm/bspwmrc".executable = true;
  xdg.configFile."bspwm/sxhkdrc".text = builtins.readFile ./config/sxhkdrc;
  xdg.configFile."bspwm/rules".text = builtins.readFile ./config/bspwm/rules;

  xdg.configFile."picom/picom.conf".text = builtins.readFile ./config/picom;

  xdg.configFile."nvim/parser/proto.so".source = "${pkgs.tree-sitter-proto}/parser";
  xdg.configFile."nvim/queries/proto/folds.scm".source = "${sources.tree-sitter-proto}/queries/folds.scm";
  xdg.configFile."nvim/queries/proto/highlights.scm".source = "${sources.tree-sitter-proto}/queries/highlights.scm";
  xdg.configFile."nvim/queries/proto/textobjects.scm".source = ./config/textobjects.scm;

  # services.picom.enable = true;
  services.polybar = {
    enable = true;
    extraConfig = builtins.readFile ./config/polybar;
    script = ''
      polybar desktop &
      polybar status &
      polybar title &
    '';
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

  programs.i3status = {
    enable = true;

    general = {
      colors = true;
      color_good = "#8C9440";
      color_bad = "#A54242";
      color_degraded = "#DE935F";
    };

    modules = {
      ipv6.enable = false;
      "wireless _first_".enable = false;
      "battery all".enable = false;
    };
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

