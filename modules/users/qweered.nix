{ cfg, lib, ... }:
{
  # TODO: determine name based on filename
  hyprnixos.users.qweered = {
    description = "The only and the greatest admin";
    browser = "vivaldi";
    keyboardLayouts = "canary,rus_canary";
  };

  # qweered's secrets: the sops file is encrypted only to hosts that enable
  # this profile (see .sops.yaml), so the gate matches what the host can
  # actually decrypt — declaring them elsewhere would fail at activation
  # TODO: hosts should import only used users, remove mkIf
  sops.secrets = lib.mkIf cfg.users.qweered.enable {
    password-qweered = {
      sopsFile = ../../secrets/users/qweered.yaml;
      neededForUsers = true; # provided before user creation
    };
  };
}
