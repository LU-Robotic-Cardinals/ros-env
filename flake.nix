{
  inputs = {
    nix-ros-overlay.url = "github:lopsided98/nix-ros-overlay";
    nixpkgs.follows = "nix-ros-overlay/nixpkgs";
    systems.url = "github:nix-systems/default";
    devenv.url = "github:cachix/devenv";
    devenv.inputs.nixpkgs.follows = "nixpkgs";
  };

  nixConfig = {
    extra-substituters = [ 
      "https://devenv.cachix.org" 
      "https://ros.cachix.org" 
    ];
    extra-trusted-public-keys = [ 
      "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
      "ros.cachix.org-1:dSyZxI8geDCJrwgvCOHDoAfOm5sV1wCPjBkKL+38Rvo=" 
    ];
  };

  outputs = { self, nixpkgs, devenv, systems, nix-ros-overlay, ... } @ inputs:
    let
      forEachSystem = nixpkgs.lib.genAttrs (import systems);
    in
    {
      packages = forEachSystem (system: {
        devenv-up = self.devShells.${system}.default.config.procfileScript;
        devenv-test = self.devShells.${system}.default.config.test;
      });

      devShells = forEachSystem (system:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [ nix-ros-overlay.overlays.default ];
            config.permittedInsecurePackages = [
              "freeimage-unstable-2021-11-01"
            ];
          };
        in
        {
          default = import ./shell.nix {
            inherit pkgs devenv inputs;
            withGazebo = false;
          };
          
          all = import ./shell.nix {
            inherit pkgs devenv inputs;
            withGazebo = true;
          };
        });
    };
}