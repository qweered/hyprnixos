{
  pkgs,
  inputs,
  config,
  specialArgs,
  ...
}:

let
  # TODO: use specialArgs instead of vars or something else
  vars = rec {
    inherit (config.system) stateVersion;
    username = "qweered";
    homeDirectory = "/home/${username}";
    description = "The only and the greatest admin";
    browser = "vivaldi";
    editor = "nvim";
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
    users."${vars.username}".imports = inputs.self.moduleTree.home { };
  };

  users = {
    mutableUsers = true; # need agenix password for false
    extraUsers = {
      "${vars.username}" = {
        isNormalUser = true;
        initialPassword = "password";
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
