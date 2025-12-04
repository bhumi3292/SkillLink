# Network Setup for Real Devices

This guide will help you configure the SkillLink mobile app to work with real devices (physical phones) instead of just emulators.

## 🚨 Problem

The chat features and other network-dependent features don't work on real devices because they're configured to use `10.0.2.2:3001`, which only works for Android emulators.

## ✅ Solution

### Step 1: Find Your Computer's IP Address

**Windows:**
1. Open Command Prompt
2. Type: `ipconfig`
3. Look for "IPv4 Address" (usually starts with 192.168.x.x)

**Mac/Linux:**
1. Open Terminal
2. Type: `ifconfig` (Mac) or `ip addr` (Linux)
3. Look for "inet" followed by your IP address

### Step 2: Update the Configuration

1. Open `lib/app/constant/api_endpoints.dart`
2. Find this line:
   ```dart
   static const String realDeviceAddress = "http://192.168.1.100:3001"; // Update this IP
   ```
3. Replace `192.168.1.100` with your computer's actual IP address
4. Save the file

### Step 3: Ensure Same Network

1. Make sure your phone and computer are connected to the same WiFi network
2. Test the connection by opening `http://YOUR_IP:3001` in your phone's browser

### Step 4: Start Your Backend Server

1. Start your Node.js backend server on your computer
2. Make sure it's running on port 3001
3. Verify it's accessible from your phone

### Step 5: Test the App

1. Rebuild and install the app on your device
2. Try accessing the chat features
3. Use the Network Debug screen to test connectivity

## 🔧 Network Debug Screen

The app includes a debug screen to help you troubleshoot network issues:

1. Navigate to the debug screen in the app
2. Check your current network configuration
3. Test the connection to your server
4. View setup instructions

## 📱 Platform-Specific Notes

### Android
- The app is configured to allow cleartext traffic for development
- Network security config allows connections to development servers
- Make sure your phone allows installation from unknown sources

### iOS
- iOS simulator uses `localhost:3001`
- Real iOS devices need your computer's IP address
- Make sure your iOS device trusts your development certificate

## 🛠️ Troubleshooting

### Connection Failed
1. Check if your computer's IP address is correct
2. Ensure both devices are on the same network
3. Verify your backend server is running
4. Check if your firewall is blocking the connection

### App Crashes
1. Check the console logs for network errors
2. Verify the IP address format is correct
3. Make sure the backend server is accessible

### Chat Features Not Working
1. Test the basic network connection first
2. Check if the socket connection is established
3. Verify the authentication token is valid
4. Check backend logs for any errors

## 🔒 Security Notes

- The current configuration allows cleartext traffic for development
- For production, use HTTPS and proper SSL certificates
- The network security config should be updated for production builds

## 📋 Checklist

- [ ] Found your computer's IP address
- [ ] Updated `realDeviceAddress` in `api_endpoints.dart`
- [ ] Both devices on same WiFi network
- [ ] Backend server running on port 3001
- [ ] Tested connection in phone browser
- [ ] Rebuilt and installed app on device
- [ ] Tested chat features
- [ ] Used debug screen to verify configuration

## 🆘 Still Having Issues?

1. Check the debug screen in the app for detailed information
2. Look at the console logs for error messages
3. Test the connection manually using your phone's browser
4. Verify your backend server is properly configured for external connections 