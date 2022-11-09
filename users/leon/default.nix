{ pkgs, lib, ... }:

{
  # https://github.com/nix-community/home-manager/pull/2408
  environment.pathsToLink = [ "/share/fish" ];

  users.users.leon = {
    isNormalUser = true;
    home = "/home/leon";
    extraGroups = [ "docker" "wheel" ];
    shell = pkgs.fish;
    hashedPassword = lib.removeSuffix "\n" (builtins.readFile ../../private/password-hash);
    openssh.authorizedKeys.keys = [
      (lib.removeSuffix "\n" (builtins.readFile ../../private/ssh-authorized-key))
    ];
  };

  nixpkgs.overlays = [
    (import ./overlays/vim.nix)
  ];
}
