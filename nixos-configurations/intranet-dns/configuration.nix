{ pkgs, sharedOverlays, stateVersion, system, additionalPackages, ... }:

let
  cjlaroseHosts = pkgs.runCommand "cjlarose-intranet-hosts" { } ''
    ${pkgs.gawk}/bin/awk '
      $1 !~ /^#/ {
        for (i = 2; i <= NF; i++) {
          if ($i ~ /\.cjlarose\.dev$/) print $1, $i;
        }
      }
    ' ${additionalPackages.${system}.intranetHosts}/hosts > "$out"
  '';
in
{
  networking = {
    hostName = "intranet-dns";
    useNetworkd = true;
    firewall = {
      enable = true;
      interfaces.tailscale0 = {
        allowedTCPPorts = [ 53 ];
        allowedUDPPorts = [ 53 ];
      };
    };
  };

  systemd.network = {
    enable = true;
    networks."20-lan" = {
      matchConfig.MACAddress = "02:00:00:00:00:05";
      networkConfig = {
        Address = [ "10.0.0.6/24" ];
        Gateway = "10.0.0.1";
      };
    };
  };

  system.stateVersion = stateVersion;
  nixpkgs.overlays = sharedOverlays;

  services.tailscale = {
    enable = true;
    authKeyFile = "/persistence/secrets/tailscale-auth-key";
    extraUpFlags = [ "--accept-dns=false" ];
    openFirewall = true;
  };

  services.dnsmasq = {
    enable = true;
    resolveLocalQueries = false;
    settings = {
      addn-hosts = "${cjlaroseHosts}";
      bind-dynamic = true;
      interface = [ "tailscale0" ];
      local = [ "/cjlarose.dev/" ];
      no-resolv = true;
      server = [ ];
    };
  };

  systemd.services.dnsmasq = {
    after = [ "tailscaled-autoconnect.service" ];
    requires = [ "tailscaled-autoconnect.service" ];
  };
}
