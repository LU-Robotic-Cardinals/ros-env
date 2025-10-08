#!/bin/sh

source $stdenvSetupPath

# Set temporary HOME for purity
export HOME=$(mktemp -d)

# CRITICAL STEP: Clear AMENT_PREFIX_PATH.
unset AMENT_PREFIX_PATH

# Source the ROS core setup script to make dependencies available.
source "${rosCorePath}/share/ros_core/local_setup.bash"

# Create workspace structure
mkdir src
# FIX: Copy the source instead of symlinking. This allows us to modify 
# (patch) files like CMakeLists.txt, which was causing the "Permission denied" error.
cp -r $source src/sllidar_ros2

# =========================================================================
# PATCHING PREPARATION: Ensure the copied source is writable.
# =========================================================================

# FIX: Explicitly grant recursive write permissions to the copied source 
# directory and its contents to prevent the "Permission denied" error from sed -i.
chmod -R +w src/sllidar_ros2

# =========================================================================
# PATCHING STEP: Modify CMakeLists.txt to fix the typesupport dependency chain.
# This injects the necessary find_package calls immediately after rclcpp.
# We must use the source file in the build workspace: src/sllidar_ros2/CMakeLists.txt
# =========================================================================

sed -i '/find_package(rclcpp REQUIRED)/a\find_package(builtin_interfaces REQUIRED)\nfind_package(rosidl_default_runtime REQUIRED)' src/sllidar_ros2/CMakeLists.txt

echo "Patched CMakeLists.txt successfully with typesupport dependencies."
# =========================================================================

# Build the package
colcon build --symlink-install --base-paths src --packages-skip-in-order sllidar_ros2

# Create the /bin directory in the output
mkdir -p $out/bin

# 1. Substitute the Nix store paths into the template script and save it to the output /bin
NIX_ROS_SETUP="${rosCorePath}/share/ros_core/local_setup.bash"
NIX_WORKSPACE_SETUP="$out/workspace/install/setup.bash"

sed \
    -e "s|@ROS_CORE_SETUP@|$NIX_ROS_SETUP|g" \
    -e "s|@WORKSPACE_SETUP@|$NIX_WORKSPACE_SETUP|g" \
    "$templateScript" > "$out/bin/run-sllidar.sh"

chmod +x $out/bin/run-sllidar.sh

# Move the entire built workspace to $out/workspace
mv build install log src $out/workspace
