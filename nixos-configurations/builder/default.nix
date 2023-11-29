{ nixpkgs, fzfProject, fzfVim, home-manager, tfenv, nixos-generators, ... }:
let
  system = "x86_64-linux";
in nixpkgs.lib.nixosSystem {
  inherit system;
  modules = [
    ({ pkgs, ... }: {
      imports = [
        nixos-generators.nixosModules.all-formats
      ];

      formatConfigs.proxmox = { config, ... }: {
        proxmox.qemuConf = {
          name = "nixos-builder";
          virtio0 = "montero-vm-storage-lvm:20";
          net0 = "virtio=00:00:00:00:00:00,bridge=vmbr1,firewall=1";
        };
      };
    })
    (import ./configuration.nix { inherit nixpkgs fzfProject fzfVim tfenv; })
    home-manager.nixosModules.home-manager {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.users.cjlarose = import ../../home;
      home-manager.extraSpecialArgs = {
        inherit system;
        server = true;
      };
    }
  ];
}
