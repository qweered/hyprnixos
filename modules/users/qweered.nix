{
  pkgs,
  inputs,
  config,
  specialArgs,
  ...
}:

let
  # TODO: use specialArgs instead of vars or something else
  # TODO: username should come from args, inherited from name of this file
  vars = rec {
    inherit (config.system) stateVersion;
    username = "qweered";
    homeDirectory = "/home/${username}";
    flakeDirectory = "/home/${username}/hyprnixos";
    description = "The only and the greatest admin";
    browser = "vivaldi";
  };
in

{
  imports = [ inputs.home-manager.nixosModules.home-manager ];

  home-manager = {
    extraSpecialArgs = specialArgs // {
      inherit vars;
    };
    verbose = true;
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";
    users."${vars.username}".imports = (inputs.import-tree.matchNot ".*/hacking/.*" ../home).imports;
  };

  users = {
    mutableUsers = false;
    extraUsers = {
      "${vars.username}" = {
        isNormalUser = true;
        hashedPasswordFile = config.age.secrets.password-qweered.path;
        shell = pkgs.fish;
        inherit (vars) description;
        extraGroups = [
          "networkmanager"
          "wheel"
          "libvirtd"
          "audio"
          "video"
          "input"
          "podman"
          "adbusers"
        ];
      };
    };
  };
}
