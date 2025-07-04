#!/bin/bash

# 设置sudo密码
sudo_password="apollo"

# 获取设备编号
device_number=$(ros2 topic list | grep -oE '/tita[0-9]+' | grep -oE '[0-9]+' | sort -u)

# 检查是否获取到设备编号
if [ -z "$device_number" ]; then
    echo "Error: Could not find device number from ROS topics"
    exit 1
fi

# 设置环境变量
export ROBOT_NAMESPACE="tita${device_number}"
echo "Setting ROBOT_NAMESPACE to: $ROBOT_NAMESPACE"

# 切换到工作目录
cd ~/person_ws || {
    echo "Error: Failed to change to directory ~/person_ws"
    exit 1
}

# 修改USB设备权限
echo "$sudo_password" | sudo -S chmod 666 /dev/ttyUSB0 || {
    echo "Error: Failed to change permissions for /dev/ttyUSB0"
    exit 1
}

# 加载ROS2环境
if [ -f "install/setup.bash" ]; then
    source install/setup.bash || {
        echo "Error: Failed to source ROS2 setup.bash"
        exit 1
    }
else
    echo "Error: ROS2 setup.bash not found in install directory"
    exit 1
fi

# 后台启动ROS2节点，并记录日志
nohup ros2 launch local_planner local_planner.launch.py > ~/local_planner.log 2>&1 &

echo "Local Planner has been started in the background."
echo "Logs are being written to: ~/local_planner.log"
echo "You can safely close this terminal."
