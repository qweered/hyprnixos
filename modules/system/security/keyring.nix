{
  # store secrets
  services.gnome.gnome-keyring.enable = true;
  services.gnome.gcr-ssh-agent.enable = false; # managed by gpg-agent instead
}
