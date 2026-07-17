{
  lib,
  cfg,
  config,
  inputs,
  ...
}:
let
  enabledUsers = lib.filterAttrs (_: user: user.enable) cfg.users;
in
{
  imports = [ inputs.home-manager.nixosModules.home-manager ];

  users = {
    mutableUsers = false;
    users = lib.mapAttrs (
      name: user:
      let
        hashedPasswordFile = config.sops.secrets."password-${name}".path or null;
      in
      {
        isNormalUser = true;
        initialPassword = if hashedPasswordFile == null then "password" else null;
        inherit hashedPasswordFile;
        inherit (user) shell description;
        extraGroups = [
          "networkmanager"
          "wheel"
          "libvirtd"
          "audio"
          "video"
          "input"
          "podman"
          "adbusers"
          "keys" # read group-gated sops secrets (nix-access-tokens, context7-api-key)
        ]
        ++ user.groups;
      }
    ) enabledUsers;
  };

  home-manager = {
    verbose = true; # its a systemd unit so no spam in console
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";
    extraSpecialArgs = { inherit inputs; };
    users = lib.mapAttrs (_: user: {
      # TODO: customize imports by user
      _module.args = { inherit user cfg; };
      inherit (inputs.import-tree.matchNot ".*/hacking/.*" ../home) imports;
    }) enabledUsers;
  };
}
