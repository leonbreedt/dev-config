# dev-config

Configuration and helpers for building a NixOS VM
running on Apple Silicon Macs as a single purpose,
pre-configured, predictable development environment.

Shamelessly copied and altered from 
[nixos-config](https://github.com/mitchellh/nixos-config)
created by Mitchell Hashimoto.

For some demos and the thinking behind it, watch the 
[Dev Tool Time with Mitchell Hashimoto](https://www.youtube.com/watch?v=LA8KF9Fs2sk)
podcast episode.

## Using

### Pre-requisites

- Apple Silicon Mac (M1 or newer)
- VMWare Fusion Public Tech Preview (22H2 or later)
- Blank ARM64 VM created with following settings
  - *Sharing*, *Enable Shared Folders* **on**
  - *Processors & Memory*
    - At least 4 cores
    - At least 16GB RAM
  - *Display*
    - *Accelerate 3D Graphics* **on**
    - *Shared Graphics Memory*, at least **8192MB**
    - *Use full resolution for Retina display* **on**
  - *Hard Disk*
    - *Advanced Options*, *Bus type* NVMe
      - NVMe is **required**, scripts assume block device is `nvme0n1`
    - At least **256GB** in size
  - *CD/DVD*
    - Latest **22.05** ISO image attached, later versions have 
      not been tested and may not work.
- Boot up the VM, change the root password to `root`:
  ```shell
  sudo su
  passwd
  # change password to 'root'
  ```

### Installation

Clone this repository. Check the modifiable parameters in the `makefile`. Run
`make bootstrap` with the blank VM up and running. Wait ~30 minutes (at least)
while you watch the system being installed and configured.

The scripts reference files in the `private` folder that may not exist for you
since `private` is a submodule to a private repository as it contains
sensitive information/credentials. You may want to create the referenced files
by hand, like `private/password-hash` (hash for user in `/etc/shadow`).
