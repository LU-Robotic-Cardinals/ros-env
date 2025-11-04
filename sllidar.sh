#!/bin/bash

# Define the primary commands
COLCON_CMD="colcon build --symlink-install"
# Use setup.bash as it's the default for ROS 2 on Linux
SOURCE_FILE="install/setup.bash" 
LAUNCH_CMD="ros2 launch sllidar_ros2 view_sllidar_a2m12_launch.py"

# Function to perform the build
# All non-error output (stdout) is redirected to /dev/null, 
# while errors (stderr) are still printed to the console.
perform_build() {
    echo "Starting colcon build..."
    
    # Run colcon. If it succeeds (exit code 0), print success.
    # If it fails, print a specific error message and exit the script.
    if ${COLCON_CMD} > /dev/null; then
        echo "Build completed successfully!"
    else
        echo "================================================================" >&2
        echo "ERROR: colcon build failed. Check the error messages above." >&2
        echo "================================================================" >&2
        exit 1
    fi
}

# --- Step 1: Conditional Build Check ---
if [ -d "build" ]; then
    echo "A 'build' directory already exists in this workspace."
    
    while true; do
        read -r -p "Do you want to rebuild the workspace? (y/N): " response
        case "$response" in
            [Yy]* ) 
                perform_build
                break
                ;;
            [Nn]* | "" ) 
                echo "Skipping build."
                break
                ;;
            * ) 
                echo "Invalid input. Please answer y or n."
                ;;
        esac
    done
else
    echo "No 'build' directory found. Starting initial build."
    perform_build
fi

# --- Step 2: Source the environment ---
if [ -f "$SOURCE_FILE" ]; then
    echo "Sourcing the ROS 2 workspace setup: $SOURCE_FILE"
    # Use '.' for sourcing to ensure environment variables are set in the current shell context
    . "$SOURCE_FILE"
else
    echo "================================================================" >&2
    echo "ERROR: Setup file ($SOURCE_FILE) not found. Cannot proceed." >&2
    echo "================================================================" >&2
    exit 1
fi

# --- Step 3: Launch the application ---
echo ""
echo "================================================================"
echo "Running the SLLIDAR launch file: $LAUNCH_CMD"
echo "================================================================"
# Execute the launch command. 'exec' replaces the current shell script process
# with the launch process, which is generally cleaner.
exec ${LAUNCH_CMD}
