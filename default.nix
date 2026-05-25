{
  pkgs ? import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/ac5c47a.tar.gz") {},
}:
with pkgs;
mkShell {
  packages = [
    godot
    netcat # facilitates godot lsp
  ];

  shellHook =  ''
    export TMPSCRIPTS=$(mktemp -d)
    export PATH="$PWD/scripts:$TMPSCRIPTS:$PATH"
    trap "rm -rf $TMPSCRIPTS" EXIT
  '';
}    
