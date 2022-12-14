{ pkgs ? import <nixpkgs> {}
, blockDevice ? "nvme0n1"
, systemName ? "aarch64"
}:

pkgs.mkShell {
  buildInputs = [
    pkgs.nixUnstable
    pkgs.parted
  ];
  shellHook = ''
    set -e -u -o pipefail

    # https://nixos.org/manual/nixos/stable/#sec-installation
    echo "installing NixOS system for "${systemName}" on /dev/${blockDevice}"
    parted /dev/${blockDevice} -- mklabel gpt
    parted /dev/${blockDevice} -- mkpart primary 512MiB -8GiB
    parted /dev/${blockDevice} -- mkpart primary linux-swap -8GiB 100%
    parted /dev/${blockDevice} -- mkpart ESP fat32 1MiB 512MiB
    parted /dev/${blockDevice} -- set 3 esp on
    sleep 1
    mkfs.ext4 -L nixos /dev/${blockDevice}p1
    mkswap -L swap /dev/${blockDevice}p2
    mkfs.fat -F 32 -n boot /dev/${blockDevice}p3
    sleep 1
    mount /dev/disk/by-label/nixos /mnt
    mkdir -p /mnt/boot
    mount /dev/disk/by-label/boot /mnt/boot
    nixos-generate-config --root /mnt
    sed --in-place '/system\.stateVersion = .*/a \
\
  # Added by dev-config\
  nix.package = pkgs.nixUnstable;\
  nix.extraOptions = "experimental-features = nix-command flakes";\
  services.openssh.enable = true;\
  services.openssh.passwordAuthentication = true;\
  services.openssh.permitRootLogin = "yes";\
  users.users.root.initialPassword = "root";\
' /mnt/etc/nixos/configuration.nix; 
    NIXPKGS_ALLOW_UNSUPPORTED_SYSTEM=1 nixos-install --flake "/nix-config#${systemName}" --no-root-passwd -v
  '';
}
