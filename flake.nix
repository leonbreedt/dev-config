{
  description = "NixOS system configuration";

  inputs = {
    # Pin primary nixpkgs repository. Don't change without good reason.
    nixpkgs.url = "github:nixos/nixpkgs/release-22.05";

    # Unstable nixpkgs repository used for select packages (e.g. NeoVIM).
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-22.05";

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
        # Go we always want the latest version
        go = inputs.nixpkgs-unstable.legacyPackages.${prev.system}.go_1_19;

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
    nixosConfigurations.system-aarch64 = buildSystem "system-aarch64" {
      inherit nixpkgs home-manager;
      system = "aarch64-linux";
      user = "leon";

      overlays = overlays ++ [(final: prev: {
        # TODO: remove the next line after NixOS release following NixOS 22.05
        open-vm-tools = inputs.nixpkgs-unstable.legacyPackages.${prev.system}.open-vm-tools;

        # We need Mesa on aarch64 to be built with "svga". The default Mesa
        # build does not include this: https://github.com/Mesa3D/mesa/blob/49efa73ba11c4cacaed0052b984e1fb884cf7600/meson.build#L192
        mesa = prev.callPackage "${inputs.nixpkgs-unstable}/pkgs/development/libraries/mesa" {
          llvmPackages = final.llvmPackages_latest;
          inherit (final.darwin.apple_sdk.frameworks) OpenGL;
          inherit (final.darwin.apple_sdk.libs) Xplugin;

          galliumDrivers = [
            # From meson.build
            "v3d" "vc4" "freedreno" "etnaviv" "nouveau"
            "tegra" "virgl" "lima" "panfrost" "swrast"

            # We add this so we get the vmwgfx module
            "svga"
          ];
        };
      })];
    };
  };
}
