{ pkgs, ... }:

{
  # https://github.com/nix-community/home-manager/pull/2408
  environment.pathsToLink = [ "/share/fish" ];

  users.users.leon = {
    isNormalUser = true;
    home = "/home/leon";
    extraGroups = [ "docker" "wheel" ];
    shell = pkgs.fish;
    hashedPassword = builtins.readFile ../../private/password-hash;
    openssh.authorizedKeys.keys = [
      builtins.readFile ../../private/ssh-authorized-key
    ];
  };

  nixpkgs.overlays = import ../../lib/overlays.nix ++ [
    (import ./vim.nix)
  ];
}
