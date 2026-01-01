{ inputs, ... }:
{
  imports = [ inputs.declarative-flatpak.nixosModules.default ];

  services.flatpak = {
    enable = true;
    remotes = {
      "flathub" = "https://dl.flathub.org/repo/flathub.flatpakrepo";
      "flathub-beta" = "https://dl.flathub.org/beta-repo/flathub-beta.flatpakrepo";
    };
    packages = [ "flathub:app/ru.linux_gaming.PortProton//stable" ];
  };
}
