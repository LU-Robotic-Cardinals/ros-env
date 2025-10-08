{
  inputs = {
    nix-ros-overlay.url = "github:lopsided98/nix-ros-overlay/ab3c1b3b7c3eca52614b4fe9d7c05ddded5b94b1";
    nixpkgs.url = "github:lopsided98/nixpkgs/nix-ros";
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
          # rplidar-ros 
          rviz2
          xacro
          slam-toolbox
          bondcpp
          # rqt-tf-tree
          # rqt-gui-py
          rclcpp
          std-msgs 
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
        libraryPackages = with pkgs; [
          # glibc
          # stdenv.cc.libc
          # zlib
          # spdlog
          # fontconfig
          # libkrb5
        ];

        # Fetch the repo from github and put in the store
        # sllidarSource = pkgs.fetchFromGitHub {
        #   owner = "Slamtec";
        #   repo = "sllidar_ros2";
        #   rev = "main";
        #   sha256 = "sha256-WcpysEplBMzXAzB9jCRuHsb1GD/iN41gT3/y2FdhQCI=";
        # };

        # # Build the github repo
        # sllidarSetup = pkgs.runCommand "sllidar-setup" {
        #   buildInputs = jazzyPackages ++ [ pkgs.stdenv pkgs.libusb1 ]; # stdenv is now an input

        #   # PASS THE STDENV SETUP PATH
        #   stdenvSetupPath = "${pkgs.stdenv}/setup"; # Pass the path to the setup script

        #   source = sllidarSource;
          
        #   # Pass the build script and template as inputs to the derivation
        #   buildScript = ./scripts/sllidar-build.sh;
        #   templateScript = ./scripts/run-sllidar-template.sh;
          
        #   # Pass the ROS Core path so the script can correctly hardcode it
        #   rosCorePath = pkgs.rosPackages.jazzy.ros-core;

        #   # The actual build script to execute is the external file
        #   shell = "${pkgs.bash}/bin/bash"; # Explicitly use bash
        # } (pkgs.lib.readFile ./scripts/sllidar-build.sh); # Read the external script into the command

        shellHook = ''
          unset QT_QPA_PLATFORM
          # Setup ROS 2 and colcon autocomplete
          eval "$(register-python-argcomplete ros2)"
          eval "$(register-python-argcomplete colcon)"
          eval "$(register-python-argcomplete rosidl)"

          # echo "Lidar setup complete. You can run the lidar with: run-sllidar.sh"
        '';
      in {
        devShells.default = pkgs.mkShell {
          name = "ros2-jazzy-basic-env";
          packages = jazzyPackages ++ libraryPackages;
          #  ++ [ sllidarSetup ]
          inherit shellHook;
        };
        devShells.all = pkgs.mkShell {
          name = "ros2-jazzy-all-packages";
          packages = jazzyPackages ++ jazzyGazeboPackages ++ libraryPackages;
          inherit shellHook;
        };
        # legacyPackages = pkgs;
      }) // {
        nixConfig = {
          extra-substituters = [ "https://ros.cachix.org" ];
          extra-trusted-public-keys = [ "ros.cachix.org-1:dSyZxI8geDCJrwgvCOHDoAfOm5sV1wCPjBkKL+38Rvo=" ];
        };
      };
}