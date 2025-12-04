#!/usr/bin/env python3
"""
Simple script to find your computer's IP address for SkillLink mobile app configuration.
"""

import socket
import subprocess
import sys
import platform

def get_ip_address():
    """Get the local IP address of the computer."""
    try:
        # Connect to a remote address to determine local IP
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        s.connect(("8.8.8.8", 80))
        ip = s.getsockname()[0]
        s.close()
        return ip
    except Exception:
        return None

def get_ip_from_system():
    """Get IP address using system commands."""
    system = platform.system().lower()
    
    try:
        if system == "windows":
            result = subprocess.run(["ipconfig"], capture_output=True, text=True)
            lines = result.stdout.split('\n')
            for line in lines:
                if "IPv4 Address" in line and "192.168" in line:
                    return line.split(":")[-1].strip()
        elif system == "darwin":  # macOS
            result = subprocess.run(["ifconfig"], capture_output=True, text=True)
            lines = result.stdout.split('\n')
            for line in lines:
                if "inet " in line and "192.168" in line:
                    return line.split("inet ")[1].split(" ")[0]
        else:  # Linux
            result = subprocess.run(["hostname", "-I"], capture_output=True, text=True)
            ips = result.stdout.strip().split()
            for ip in ips:
                if ip.startswith("192.168"):
                    return ip
    except Exception:
        pass
    
    return None

def main():
    print("🌐 SkillLink Network Configuration Helper")
    print("=" * 50)
    
    # Try different methods to get IP
    ip = get_ip_address() or get_ip_from_system()
    
    if ip:
        print(f"✅ Your computer's IP address is: {ip}")
        print(f"📱 Update your app configuration with: http://{ip}:3001")
        print()
        print("📋 Next steps:")
        print("1. Open lib/app/constant/api_endpoints.dart")
        print("2. Find the line: static const String realDeviceAddress = \"http://192.168.1.100:3001\";")
        print(f"3. Replace 192.168.1.100 with {ip}")
        print("4. Save the file and rebuild your app")
        print("5. Make sure your phone and computer are on the same WiFi network")
        print("6. Start your backend server on port 3001")
        print("7. Test the connection by visiting http://{ip}:3001 in your phone's browser")
    else:
        print("❌ Could not determine your IP address automatically.")
        print()
        print("🔧 Manual steps:")
        print("1. Open Command Prompt (Windows) or Terminal (Mac/Linux)")
        print("2. Type 'ipconfig' (Windows) or 'ifconfig' (Mac/Linux)")
        print("3. Look for an IP address starting with 192.168.x.x")
        print("4. Use that IP address in your app configuration")

if __name__ == "__main__":
    main() 