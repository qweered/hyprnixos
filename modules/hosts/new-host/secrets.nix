{
  # TODO: enroll this host:
  #   1. cp its /etc/ssh/ssh_host_ed25519_key.pub into this directory
  #      (or `ssh-keyscan -t ed25519 <host> | cut -d" " -f2-`), then git add it
  #   2. nix run .#sops-sync
  #
  # Host-only secrets (this file is private to this host's config):
  # sops.secrets.some-secret.sopsFile = ../../../secrets/hosts/new-host.yaml;
}
