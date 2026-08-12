{
  inputs,
  pkgs,
  config,
  ...
}:
{
  imports = [ inputs.sops-nix.nixosModules.sops ];

  environment.systemPackages = with pkgs; [
    sops
    ssh-to-age
  ];

  sops = {
    # Secrets every host is trusted with. Narrower scopes set sopsFile
    # explicitly: modules/users/<name>.nix -> secrets/users/<name>.yaml,
    # modules/hosts/<name>/ -> secrets/hosts/<name>.yaml.
    defaultSopsFile = ../../../secrets/common.yaml;

    # Host decrypts with an age key derived from its SSH host key.
    # Editing secrets uses the GPG admin identity from .sops.yaml instead.
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    gnupg.sshKeyPaths = [ ];

    secrets = {
      nix-access-tokens = {
        mode = "0440";
        group = config.users.groups.keys.name;
      };
      context7-api-key = {
        mode = "0440";
        group = config.users.groups.keys.name;
      };
      # Loaded as a systemd credential by cachix-daemon (see programs/cachix.nix),
      # so the value is the bare token — no `CACHIX_AUTH_TOKEN=` prefix.
      # Root-only by sops-nix default — no user needs to read it.
      cachix-auth-token = { };
    };
  };
}
