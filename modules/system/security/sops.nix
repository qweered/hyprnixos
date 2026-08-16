{
  inputs,
  pkgs,
  config,
  ...
}:
let
  # This host's identity: an ed25519 SSH key whose age form (ssh-to-age) is the
  # recipient every secrets/*.yaml is encrypted to. Minted by `nix run .#hostkey`;
  # the .pub is committed as modules/hosts/<name>/ssh_host_ed25519_key.pub.
  #
  # Not under /etc: system.etc.overlay masks the mutable /etc with a
  # config-generated lower layer, and a key there disappears with it.
  hostKeyPath = "/var/lib/ssh/ssh_host_ed25519_key";
in
{
  imports = [ inputs.sops-nix.nixosModules.sops ];

  environment.systemPackages = with pkgs; [
    sops
  ];

  sops = {
    # Secrets every host is trusted with. Narrower scopes set sopsFile
    # explicitly: modules/users/<name>.nix -> secrets/users/<name>.yaml,
    # modules/hosts/<name>/ -> secrets/hosts/<name>.yaml.
    defaultSopsFile = ../../../secrets/common.yaml;

    # Host decrypts with an age key derived from its SSH host key.
    # Editing secrets uses the GPG admin identity from .sops.yaml instead.
    age.sshKeyPaths = [ hostKeyPath ];
    gnupg.sshKeyPaths = [ ];

    secrets = {
      nix-access-tokens = {
        mode = "0440";
        group = config.users.groups.keys.name;
      };
      # No user needs to read it.
      cachix-auth-token = { };
    };
  };
}
