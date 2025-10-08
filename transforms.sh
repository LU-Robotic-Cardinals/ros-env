# Example: LiDAR is at (0.1, 0, 0.2) meters relative to base_link, with no rotation
# ros2 run tf2_ros static_transform_publisher --x 0.1 --y 0 --z 0.2 --yaw 0 --pitch 0 --roll 0 --frame-id base_link --child-frame-id laser_frame
ros2 run tf2_ros static_transform_publisher 0.1 0 0.2 0 0 0 base_link laser
ros2 run tf2_ros static_transform_publisher 0.1 0 0.2 0 0 0 base_link base_footprint
# ros2 run tf2_ros static_transform_publisher --x 0 --y 0 --z 0 --yaw 0 --pitch 0 --roll 0 --frame-id odom --child-frame-id base_link
ros2 run tf2_ros static_transform_publisher 0 0 0 0 0 0 odom base_link
# ros2 launch rf2o_laser_odometry rf2o_laser_odometry_launch.py
