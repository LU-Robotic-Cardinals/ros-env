{
  inputs = {
    # 1. Standard devenv inputs (keep these following the 'rolling' branch for simplicity)
    nixpkgs.url = "github:cachix/devenv-nixpkgs/rolling";
    systems.url = "github:nix-systems/default";
    devenv.url = "github:cachix/devenv";
    devenv.inputs.nixpkgs.follows = "nixpkgs"; # Devenv follows the standard input

    # 2. ROS-specific inputs
    nix-ros-overlay.url = "github:lopsided98/nix-ros-overlay/ab3c1b3b7c3eca52614b4fe9d7c05ddded5b94b1";
    nixpkgs-ros.url = "github:lopsided98/nixpkgs/nix-ros";
  };

  # Your custom ROS Cachix settings
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

  outputs = { self, nixpkgs, devenv, systems, nix-ros-overlay, nixpkgs-ros, ... } @ inputs:
    let
      # Use the 'lib' from the standard nixpkgs input
      forEachSystem = nixpkgs.lib.genAttrs (import systems);
    in
    {
      # Keep the devenv-up/test exports as requested
      packages = forEachSystem (system: {
        devenv-up = self.devShells.${system}.default.config.procfileScript;
        devenv-test = self.devShells.${system}.default.config.test;
      });

      # Create the devshell(s)
      devShells = forEachSystem (system:
        let
          # CRITICAL: Instantiate the custom ROS-specific pkgs set here, 
          # which includes the overlay and insecure packages config.
          pkgs = import nixpkgs-ros {
            inherit system;
            overlays = [ nix-ros-overlay.overlays.default ];
            config.permittedInsecurePackages = [
              "freeimage-unstable-2021-11-01"
            ];
          };
        in
        {
          # The default shell now uses the custom 'pkgs' set, but still uses 
          # the standard 'devenv' input.
          default = import ./shell.nix {
            inherit pkgs devenv inputs;
            withGazebo = false;
          };
          
          # The 'all' shell includes ROS packages plus Gazebo
          all = import ./shell.nix {
            inherit pkgs devenv inputs;
            withGazebo = true;
          };
        });
    };
}