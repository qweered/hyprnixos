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
          identity = "/home/qweered/.ssh/id_ed25519";
          pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPHJLW23Vnv5K/tka6F0Cdc8Ghk/BdF2E8n7lL+vvqBf";
        }
      ];
    };

    secrets = {
      git-token.rekeyFile = ../../../secrets/git-token.age;
      context7-api-key = {
        rekeyFile = ../../../secrets/context7-api-key.age;
        owner = "qweered";
      };
      password-qweered = {
        rekeyFile = ../../../secrets/password-qweered.age;
        mode = "0400";
      };
    };
  };
}
