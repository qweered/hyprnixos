# Excluded from the upstream flake ("fails to build due to node-gyp"):
# dbus-next's optional usocket dependency is a native addon that cannot be
# built (its pinned node-gyp 7 chokes on current node/python) or bundled
# (it requires the undeclared `debug` package). It's also unnecessary:
# dbus-next only wants usocket for unix-fd passing — which BlueZ device
# control never uses — and falls back to node's net module when the
# require fails (lib/connection.js). So skip install scripts to get past
# node-gyp, then drop usocket before bundling; its require sits in a
# try/catch, which makes esbuild defer the missing module to run time.
{ mkExtension }:
mkExtension "bluetooth" {
  npmFlags = [
    "--legacy-peer-deps"
    "--ignore-scripts"
  ];
  preBuild = ''
    rm -r node_modules/usocket
  '';
}
