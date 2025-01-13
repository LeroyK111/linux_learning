#!/usr/bin/python
# -*- coding: utf-8 -*-


import serial.tools.list_ports


def list_ports():
    """
    列出所有可用的串口及其识别码
    """
    ports = serial.tools.list_ports.comports()
    devices = []

    for port in ports:
        device_info = {
            "device": port.device,  # COM 端口名称
            "description": port.description,  # 描述
            "hwid": port.hwid,  # 硬件 ID
            "vid": None,
            "pid": None,
            "serial_number": None,
        }

        # 解析硬件 ID (如包含 VID 和 PID)
        if port.hwid and "VID" in port.hwid:
            parts = port.hwid.split(" ")
            for part in parts:
                if "VID_" in part:
                    device_info["vid"] = part.split("VID_")[1][:4]
                if "PID_" in part:
                    device_info["pid"] = part.split("PID_")[1][:4]
                if "SN_" in part:
                    device_info["serial_number"] = part.split("SN_")[1]

        devices.append(device_info)

    return devices


def bind_device_to_com(target_vid, target_pid, target_serial=None):
    """
    根据 VID 和 PID 绑定设备到 COM 端口
    """
    devices = list_ports()
    for device in devices:
        if device["vid"] == target_vid and device["pid"] == target_pid:
            if target_serial is None or device["serial_number"] == target_serial:
                print(
                    f"Found device on {device['device']} (VID={device['vid']}, PID={device['pid']})"
                )
                return device["device"]
    print("No matching device found.")
    return None


# 示例用法
if __name__ == "__main__":
    # 列出所有设备
    devices = list_ports()
    print("Available devices:")
    for dev in devices:
        print(dev)

    # 根据 VID 和 PID 绑定设备
    # target_vid = "0403"  # 替换为你的设备的 VID
    # target_pid = "6001"  # 替换为你的设备的 PID
    # target_serial = None  # 可选：设备的序列号
    # com_port = bind_device_to_com(target_vid, target_pid, target_serial)

    # if com_port:
    #     print(f"Device is available on {com_port}")
    # else:
    #     print("Device not found.")
