{ inputs, ... }:
{
  # NOTE: Have to be in system for now https://github.com/nix-community/home-manager/issues/4621
  imports = [ inputs.declarative-flatpak.nixosModules.default ];

  # over nix-flatpak (actually declarative)
  services.flatpak = {
    enable = false;
    remotes = {
      "flathub" = "https://dl.flathub.org/repo/flathub.flatpakrepo";
      "flathub-beta" = "https://dl.flathub.org/beta-repo/flathub-beta.flatpakrepo";
    };
    # Format: remote:app/org.example.App//branch
    packages = [ ];
  };
}
