{
  inputs = {
    nix-ros-overlay.url = "github:lopsided98/nix-ros-overlay/ab3c1b3b7c3eca52614b4fe9d7c05ddded5b94b1";
    nixpkgs.url = "github:lopsided98/nixpkgs?ref=nix-ros";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, flake-utils, nix-ros-overlay }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ nix-ros-overlay.overlays.default ];
          config.permittedInsecurePackages = [
            "freeimage-unstable-2021-11-01"
          ];
        };
        jazzyPackages = with pkgs; with pkgs.rosPackages.jazzy; [
          colcon
          ros-core
          ament-cmake-core
          python-cmake-module
	        robot-state-publisher
	        rviz2
	        xacro
          slam-toolbox
        ];
        jazzyGazeboPackages = with pkgs; with pkgs.rosPackages.jazzy; [
          gz-cmake-vendor
          gz-common-vendor
          gz-dartsim-vendor
          gz-fuel-tools-vendor
          gz-gui-vendor
          gz-launch-vendor
          gz-math-vendor
          gz-msgs-vendor
          gz-ogre-next-vendor
          gz-physics-vendor
          gz-plugin-vendor
          gz-rendering-vendor
          gz-sensors-vendor
          gz-sim-vendor
          gz-tools-vendor
          gz-transport-vendor
          gz-utils-vendor
        ];
        shellHook = ''
          unset QT_QPA_PLATFORM
          # Setup ROS 2 and colcon autocomplete
          eval "$(register-python-argcomplete ros2)"
          eval "$(register-python-argcomplete colcon)"
          eval "$(register-python-argcomplete rosidl)"
        '';
      in {
        devShells.default = pkgs.mkShell {
          name = "ros2-jazzy-basic-env";
          packages = jazzyPackages;
          inherit shellHook;
        };
        devShells.all = pkgs.mkShell {
          name = "ros2-jazzy-all-packages";
          packages = jazzyPackages ++ jazzyGazeboPackages;
          inherit shellHook;
        };
        legacyPackages = pkgs; # This line is correct and necessary
      }) // {
        nixConfig = {
          extra-substituters = [ "https://ros.cachix.org" ];
          extra-trusted-public-keys = [ "ros.cachix.org-1:dSyZxI8geDCJrwgvCOHDoAfOm5sV1wCPjBkKL+38Rvo=" ];
        };
      };
}
