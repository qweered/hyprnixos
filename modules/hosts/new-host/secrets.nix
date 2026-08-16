{
  # TODO: enroll this host, before installing it -- hyprnixos-install refuses to
  # run otherwise, and a host installed unenrolled cannot decrypt its own
  # password:
  #   1. nix run .#hostkey new-host   # mints the key, drops the .pub here
  #   2. git add modules/hosts/new-host/ssh_host_ed25519_key.pub
  #   3. nix run .#sops-sync
  #
  # Host-only secrets (this file is private to this host's config):
  # sops.secrets.some-secret.sopsFile = ../../../secrets/hosts/new-host.yaml;
}
