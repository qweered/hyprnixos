{
  # TODO: enroll this host:
  #   1. set hyprnixos.hostAgeKey in options.nix
  #      (ssh-keyscan <host> | ssh-to-age, or on the host:
  #       ssh-to-age < /etc/ssh/ssh_host_ed25519_key.pub)
  #   2. nix run .#sops-sync
  #
  # Host-only secrets (this file is private to this host's config):
  # sops.secrets.some-secret.sopsFile = ../../../secrets/hosts/new-host.yaml;
}
