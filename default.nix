{
  pkgs ? import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/b4e8c68.tar.gz") {},
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
