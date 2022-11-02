# Overridable options

NIXUSER ?= leon
NIXADDR ?= 192.168.36.128
NIXNAME ?= system-aarch64

# Static options

MAKEFILE_DIR := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))
NIXOS_REBUILD_OPTS=NIXPKGS_ALLOW_UNSUPPORTED_SYSTEM=1
SSH_OPTS=-o PubkeyAuthentication=no -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no
BLOCK_DEVICE=nvme0n1

# Rebuild from configuration, and switch to it.
switch:
	sudo ${NIXOS_REBUILD_OPTS} nixos-rebuild switch --flake ".#${NIXNAME}"

# Test the configuration, but don't actually change anything.
test:
	sudo ${NIXOS_REBUILD_OPTS} nixos-rebuild test --flake ".#${NIXNAME}"

# Bootstrap a new VM. The VM should have NixOS ISO attached as the CD drive,
# with a root password of "root" (after successful installation, root will be 
# locked). After this target is complete, NixOS will be installed but user
# will not be setup, need to reboot first.
bootstrap:
	@if [ -d /nix ]; then echo "Don't bootstrap on a running Nix system!"; exit 1; fi
	NIXUSER=root ${MAKE} bootstrap/copy-config
	NIXUSER=root ${MAKE} bootstrap/install
	@echo "Now run 'make finish' after the VM finishes rebooting."
	ssh ${SSH_OPTS} root@${NIXADDR} " \
		sudo reboot; \
	"

finish:
	# Do a switch to ensure SSHD is set up amongst other things
	${MAKE} bootstrap/copy-secrets

# Copy the current directory and all the configuration files 
# to the VM.
bootstrap/copy-config:
	rsync -av -e 'ssh ${SSH_OPTS}' \
		--exclude='.git/' \
		--rsync-path='sudo rsync' \
		${MAKEFILE_DIR}/ ${NIXUSER}@${NIXADDR}:/nix-config

# Install NixOS, then rebuild and switch.
bootstrap/install:
	ssh ${SSH_OPTS} ${NIXUSER}@${NIXADDR} "\
		sudo nix-shell \
			--argstr blockDevice ${BLOCK_DEVICE} \
			--argstr systemName ${NIXNAME} \
			/nix-config/install \
	"

# Copy secrets from the host to the VM.
bootstrap/copy-secrets:
	# GPG keyring
	rsync -av -e 'ssh ${SSH_OPTS}' \
		--exclude='.#*' \
		--exclude='S.*' \
		--exclude='*.conf' \
		${HOME}/.gnupg/ ${NIXUSER}@${NIXADDR}:~/.gnupg
	# SSH keys
	rsync -av -e 'ssh ${SSH_OPTS}' \
		--exclude='environment' \
		${HOME}/.ssh/ ${NIXUSER}@${NIXADDR}:~/.ssh

# Run switch on newly booted system
bootstrap/switch:
	ssh ${SSH_OPTS} ${NIXUSER}@${NIXADDR} " \
  sudo NIXPKGS_ALLOW_UNSUPPORTED_SYSTEM=1 nixos-rebuild switch --flake \"/nix-config#${NIXNAME}\"; \
	sudo reboot; \
	"
