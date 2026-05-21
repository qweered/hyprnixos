{ lib, ... }:

{
  # https://blog.nsrun.io/2026/01/15/systemd-vsock-openssh-server
  systemd = {
    generators.systemd-ssh-generator = "/dev/null";
    sockets = {
      sshd-unix-local.enable = lib.mkForce false;
      sshd-vsock.enable = lib.mkForce false;
    };
  };
}
