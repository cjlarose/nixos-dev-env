{ microvm, ... }: {
  imports = [
    microvm.nixosModules.microvm
    ./configuration.nix
  ];

  microvm.hypervisor = "qemu";
  microvm.vcpu = 1;
  microvm.mem = 256;

  microvm.interfaces = [{
    type = "tap";
    id = "vm-intranet-dns";
    mac = "02:00:00:00:00:05";
  }];

  microvm.storeOnDisk = false;
  microvm.writableStoreOverlay = "/nix/.rw-store";

  microvm.shares = [
    {
      tag = "ro-store";
      source = "/nix/store";
      mountPoint = "/nix/.ro-store";
      proto = "virtiofs";
    }
    {
      tag = "persist-nix-rw-store";
      source = "nix-rw-store";
      mountPoint = "/nix/.rw-store";
      proto = "virtiofs";
    }
    {
      tag = "persist-tailscale";
      source = "tailscale";
      mountPoint = "/var/lib/tailscale";
      proto = "virtiofs";
    }
    {
      tag = "persist-secrets";
      source = "secrets";
      mountPoint = "/persistence/secrets";
      proto = "virtiofs";
    }
  ];
}
