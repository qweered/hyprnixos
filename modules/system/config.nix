{
  lib,
  cfg,
  config,
  inputs,
  ...
}:
{
  imports = [ inputs.home-manager.nixosModules.home-manager ];

  users = {
    mutableUsers = false;
    users = lib.mapAttrs (name: user: {
      isNormalUser = true;
      hashedPasswordFile = config.age.secrets."password-${name}".path;
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
      ]
      ++ user.groups;
    }) cfg.users;
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";
    extraSpecialArgs = { inherit inputs; };
    users = lib.mapAttrs (_: user: {
      # TODO: customize imports by user
      _module.args = { inherit user cfg; };
      inherit (inputs.import-tree.matchNot ".*/hacking/.*" ../home) imports;
    }) cfg.users;
  };
}
