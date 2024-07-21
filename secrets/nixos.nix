{
  lib,
  config,
  pkgs,
  agenix,
  mysecrets,
  myvars,
  ...
}:
with lib; let
  cfg = config.modules.secrets;

  noaccess = {
    mode = "0000";
    owner = "root";
  };
  high_security = {
    mode = "0500";
    owner = "root";
  };
  user_readable = {
    mode = "0500";
    owner = myvars.username;
  };
in {
  imports = [
    agenix.nixosModules.default
  ];

  options.modules.secrets = {
    desktop.enable = mkEnableOption "NixOS Secrets for Desktops";

    server.network.enable = mkEnableOption "NixOS Secrets for Network Servers";
    server.application.enable = mkEnableOption "NixOS Secrets for Application Servers";
    server.operation.enable = mkEnableOption "NixOS Secrets for Operation Servers(Backup, Monitoring, etc)";
    server.kubernetes.enable = mkEnableOption "NixOS Secrets for Kubernetes";
    server.webserver.enable = mkEnableOption "NixOS Secrets for Web Servers(contains tls cert keys)";

    impermanence.enable = mkEnableOption "whether use impermanence and ephemeral root file system";
  };

  config =
    mkIf (
      cfg.desktop.enable
      || cfg.server.application.enable
      || cfg.server.network.enable
      || cfg.server.operation.enable
      || cfg.server.kubernetes.enable
    ) (mkMerge [
      {
        environment.systemPackages = [
          agenix.packages."${pkgs.system}".default
        ];

        # if you changed this key, you need to regenerate all encrypt files from the decrypt contents!
        age.identityPaths =
          if cfg.impermanence.enable
          then [
            # To decrypt secrets on boot, this key should exists when the system is booting,
            # so we should use the real key file path(prefixed by `/persistent/`) here, instead of the path mounted by impermanence.
            "/persistent/etc/ssh/ssh_host_ed25519_key" # Linux
          ]
          else [
            "/etc/ssh/ssh_host_ed25519_key"
          ];

        assertions = [
          {
            # This expression should be true to pass the assertion
            assertion =
              !(cfg.desktop.enable
                && (
                  cfg.server.application.enable
                  || cfg.server.network.enable
                  || cfg.server.operation.enable
                  || cfg.server.kubernetes.enable
                ));
            message = "Enable either desktop or server's secrets, not both!";
          }
        ];
      }

    (mkIf cfg.desktop.enable {
        age.secrets = {

          "ssh-key-remote" =
            {
              file = "${mysecrets}"; ##AFTER MYSECRETS}your/directory/ssh-key-remote.age"
            }
            // user_readable;

            };

            environment.etc = {
                      
            "agenix/ssh-key-remote" = {
            source = config.age.secrets."ssh-key-remote".path;
            mode = "0600";
            user = myvars.username;

            };

                              };

                ##(mkIf cfg.server.webserver.enable {
        ##age.secrets = {
          ##"certs/ecc-server.key" = {
            ##file = "${mysecrets}/certs/ecc-server.key.age";
            ##mode = "0400";
            ##owner = "caddy"; # used by caddy only
          ##};
        ##};
      ##})


                              })

      ]);
}
