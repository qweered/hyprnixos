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
      # every user's shell exports this (modules/home/programs/ai/mcp.nix),
      # so it stays root-owned but readable by all
      context7-api-key.mode = "0444";
    };
  };
}
