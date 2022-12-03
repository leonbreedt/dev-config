{
  description = "NixOS system configuration";

  inputs = {
    # Pin primary nixpkgs repository. Don't change without good reason.
    nixpkgs.url = "github:nixos/nixpkgs/release-22.11";

    # Unstable nixpkgs repository used for select packages (e.g. NeoVIM).
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-22.11";

      # Use same nixpkgs repository as system.
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Use mitchellh's NeoVIM overlay.
    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs: let
    buildSystem = import ./system/builder.nix;

    # List of overlays we want to apply from flake inputs.
    overlays = [
      inputs.neovim-nightly-overlay.overlay

      (final: prev: {
        # Use rounded corners version of BSPWM
        bspwm = prev.bspwm.overrideAttrs (old: {
          pname = "bspwm";
          version = "0.9.10";
          src = prev.fetchFromGitHub {
            owner = "phuhl";
            repo = "bspwm-rounded";
            rev = "a510c368595cd530713cc9d850842ba096051d12";
            sha256 = "sha256-VyQoLiQ4yT43scFcCfBejr+SfGuJEZ6RI9Gf1kRGFV0=";
          };
        });
      })
    ];
  in {
    nixosConfigurations.vm-aarch64 = buildSystem "vm-aarch64" {
      inherit nixpkgs home-manager;
      system = "aarch64-linux";
      user = "leon";

      overlays = overlays ++ [(final: prev: {
        # Example of bringing in an unstable package:
        # open-vm-tools = inputs.nixpkgs-unstable.legacyPackages.${prev.system}.open-vm-tools;
      })];
    };

    nixosConfigurations.hw-x64 = buildSystem "hw-x64" {
      inherit nixpkgs home-manager overlays;
      system = "x86_64-linux";
      user = "leon";
    };
  };
}
