NIXPKGS_ALLOW_INSECURE=1 nix develop --extra-experimental-features nix-command --extra-experimental-features flakes --no-pure-eval .#all
# nix build .#packages.x86_64-linux.devenv-up --store ssh-ng://nixuser@laptop-pdq3s7 --extra-experimental-features nix-command --extra-experimental-features flakes --no-pure-eval
