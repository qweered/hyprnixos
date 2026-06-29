{ inputs, ... }:
{
  imports = [
    inputs.agenix.nixosModules.default
    inputs.agenix-rekey.nixosModules.default
  ];

  age = {
    identityPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

    rekey = {
      masterIdentities = [
        {
          identity = "/home/kavazar/.ssh/id_ed25519";
          pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFeEvCxMKrDSozD3XsTcB+7OYhNrHxm0jl3uMffqyATh";
        }
      ];
    };

    secrets = {
      git-token.rekeyFile = ../../../secrets/git-token.age;
      context7-api-key = {
        rekeyFile = ../../../secrets/context7-api-key.age;
        owner = "kavazar";
      };
      password-kavazar = {
        rekeyFile = ../../../secrets/password-kavazar.age;
        mode = "0400";
      };
    };
  };
}
