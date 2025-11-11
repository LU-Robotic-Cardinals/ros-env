{pkgs, devenv, inputs, withGazebo, ...} :
let
  # Get the ROS 2 Jazzy package set
  ros = pkgs.rosPackages.jazzy;
  
  # Packages common to both shells. 
  # The 'with ros;' statement allows us to use package names directly.
  jazzyPackages = with pkgs; with ros; [
    # pkgs.libserialport
    serial-driver
    colcon
    ros-core
    ros-environment
    rplidar-ros
    ament-cmake-core
    python-cmake-module
    robot-state-publisher
    rviz2
    rmw-fastrtps-cpp
    xacro
    slam-toolbox
    bondcpp
    rclcpp
    std-msgs

    ros2-control            # Core ros2_control framework
    ros2-control-cmake
    ros2-controllers        # Standard controllers (diff_drive_controller, etc.)
    controller-manager      # Node for managing controllers
    joint-state-publisher   # Publishes joint states
    teleop-twist-keyboard   # For teleoperation
    geometry-msgs           # Standard messages like Twist
    launch-xml              # If launch files use XML format
    twist-mux

    hardware-interface      # <--- Important for custom hardware plugin development
    transmission-interface  # <--- Important for defining joint/actuator relationships
    diff-drive-controller
    joint-state-broadcaster # <--- Ensures sensor data gets published to /joint_states
    forward-command-controller
    control-toolbox
  ];

  # Gazebo packages, only included if withGazebo is true
  jazzyGazeboPackages = with ros; [
    gz-cmake-vendor
    gz-common-vendor
    gz-dartsim-vendor
    gz-fuel-tools-vendor
    gz-gui-vendor
    gz-launch-vendor
    gz-math-vendor
    # gz-msgs-vendor
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

  # Define the custom script/command
  compile-ros-package = pkgs.writeScriptBin "cr" ''
    #!${pkgs.bash}/bin/bash
    
    colcon build --symlink-install
    source install/setup.bash

    echo "Package Built"
  '';

   
  # extraPackages = if withGazebo then jazzyGazeboPackages else [];
  extraPackages = [ compile-ros-package ];


in 
devenv.lib.mkShell { # <-- This is the final expression returned by the function
  inherit inputs pkgs;

  # This is the attribute set being passed to mkShell
  modules = [
    {
      # Define all packages needed in the shell environment
      packages = jazzyPackages ++ extraPackages ++ 
      (if withGazebo then jazzyGazeboPackages else []);

      # The enterShell block replaces your original shellHook
      enterShell = ''
        # unset QT_QPA_PLATFORM
        # unset QT_PLUGIN_PATH
        # unset LD_LIBRARY_PATH
        # unset QT_STYLE_OVERRIDE
        
        # export COLCON_IGNORE_CMAKE_PREFIX_PATH_INC=1
        # export RMW_IMPLEMENTATION="rmw_fastrtps_cpp"
        # source ${ros.ros-environment}/share/ros_environment/local_setup.bash
        
        # Setup ROS 2 and colcon autocomplete
        eval "$(register-python-argcomplete ros2)"
        eval "$(register-python-argcomplete colcon)"
        eval "$(register-python-argcomplete rosidl)"
      '';
    }
  ];
}