const User = require("../models/User");
const bcrypt = require("bcrypt"); // Make sure bcrypt is imported
const jwt = require("jsonwebtoken");
const { sendEmail } = require("../utils/sendEmail"); // Assuming this utility exists

// Register User (existing)
exports.registerUser = async (req, res) => {
    const { fullName, email, phoneNumber, stakeholder, password, confirmPassword } = req.body;

    if (!fullName || !email || !phoneNumber || !stakeholder || !password || !confirmPassword) {
        return res.status(400).json({ success: false, message: "Please fill all the fields" });
    }

    if (password !== confirmPassword) {
        return res.status(400).json({ success: false, message: "Passwords do not match" });
    }

    // Normalize stakeholder/role to lowercase for consistent handling
    const normalizedRole = stakeholder ? String(stakeholder).toLowerCase() : null;
    if (!["worker", "hirer"].includes(normalizedRole)) {
        return res.status(400).json({ success: false, message: "Stakeholder must be 'worker' or 'hirer'" });
    }

    try {
        const existingUser = await User.findOne({ email });
        if (existingUser) {
            return res.status(400).json({ success: false, message: "Email already in use" });
        }

        const newUser = new User({
            fullName,
            email,
            phoneNumber,
            role: normalizedRole,
            password // User model pre-save hook should handle hashing
        });

        await newUser.save();

        return res.status(201).json({ success: true, message: "User registered successfully" });
    } catch (err) {
        console.error("Registration Error:", err);
        // More specific error handling for database issues if needed
        return res.status(500).json({ success: false, message: "Server error during registration." });
    }
};

// Login User (existing)
exports.loginUser = async (req, res) => {
    const { email, password } = req.body;
    console.log(req.body)

    if (!email || !password) {
        return res.status(400).json({ success: false, message: "Email and password are required" });
    }

    try {
        const user = await User.findOne({ email });
        if (!user) {
            return res.status(404).json({ success: false, message: "User not found" });
        }

        const passwordMatch = await user.comparePassword(password); // Assuming comparePassword method on User model
        if (!passwordMatch) {
            return res.status(401).json({ success: false, message: "Invalid credentials" });
        }

        const payload = {
            _id: user._id,
            email: user.email,
            role: user.role
        };

        const token = jwt.sign(payload, process.env.JWT_SECRET, { expiresIn: "7d" });

        const { password: _, ...userWithoutPassword } = user.toObject();

        return res.status(200).json({
            success: true,
            message: "Login successful",
            token,
            user: userWithoutPassword
        });
    } catch (err) {
        console.error("Login Error:", err);
        return res.status(500).json({ success: false, message: "Server error during login." });
    }
};

// Find User ID by Credentials (existing)
exports.findUserIdByCredentials = async (req, res) => {
    const { email, password, stakeholder } = req.body;

    if (!email || !password || !stakeholder) {
        return res.status(400).json({ success: false, message: "All fields are required" });
    }

    try {
        const normalizedRole = stakeholder ? String(stakeholder).toLowerCase() : null;
        const user = await User.findOne({ email, role: normalizedRole });
        if (!user) {
            return res.status(404).json({ success: false, message: "User not found with provided credentials" });
        }

        const isPasswordValid = await user.comparePassword(password);
        if (!isPasswordValid) {
            return res.status(401).json({ success: false, message: "Incorrect password" });
        }

        return res.status(200).json({ success: true, userId: user._id });
    } catch (err) {
        console.error("User ID Fetch Error:", err);
        return res.status(500).json({ success: false, message: "Server error." });
    }
};

// Get Current Authenticated User (existing)
exports.getMe = async (req, res) => {
    if (!req.user) {
        return res.status(401).json({ success: false, message: "User data not available after authentication." });
    }
    return res.status(200).json({
        success: true,
        user: req.user,
    });
};

// Send Password Reset Link (existing)
exports.sendPasswordResetLink = async (req, res) => {
    const { email } = req.body;

    if (!email) {
        return res.status(400).json({ success: false, message: 'Email is required.' });
    }

    try {
        const user = await User.findOne({ email });

        if (!user) {
            console.log(`Password reset requested for non-existent email: ${email}`);
            // Send a generic success message to prevent email enumeration
            return res.status(200).json({ success: true, message: 'If an account with that email exists, a password reset link has been sent.' });
        }

        const resetToken = jwt.sign(
            { userId: user._id },
            process.env.JWT_SECRET,
            { expiresIn: '1h' }
        );

        // Ensure FRONTEND_URL is set in your .env
        const resetUrl = `${process.env.CLIENT_URL}/reset-password/${resetToken}`;

        const subject = 'SkillLink Password Reset Request';
        const text = `You requested a password reset. Use this link to reset your password: ${resetUrl}`;
        const html = `
            <p>Hello ${user.fullName},</p>
            <p>You recently requested to reset your password for your SkillLink account.</p>
            <p>Click the link below to reset your password:</p>
            <p><a href="${resetUrl}" style="background-color: #002B5B; color: white; padding: 10px 20px; text-decoration: none; border-radius: 5px;">Reset Your Password</a></p>
            <p>This link is valid for <b>1 hour</b>.</p>
            <p>If you did not request this, please ignore this email.</p>
            <p>Thank you,<br/>The SkillLink Team</p>
        `;

        await sendEmail(user.email, subject, text, html);

        return res.status(200).json({ success: true, message: 'If an account with that email exists, a password reset link has been sent.' });
    } catch (error) {
        console.error('Error in sendPasswordResetLink:', error);
        return res.status(500).json({ success: false, message: 'Failed to send password reset link. Please try again later.' });
    }
};

// Reset Password Handler (existing)
exports.resetPassword = async (req, res) => {
    const { token } = req.params;
    const { newPassword, confirmPassword } = req.body;

    if (!newPassword || !confirmPassword) {
        return res.status(400).json({ success: false, message: 'Both password fields are required.' });
    }

    if (newPassword !== confirmPassword) {
        return res.status(400).json({ success: false, message: 'Passwords do not match.' });
    }

    if (newPassword.length < 8) {
        return res.status(400).json({ success: false, message: 'Password must be at least 8 characters.' });
    }

    try {
        const decoded = jwt.verify(token, process.env.JWT_SECRET);
        const user = await User.findById(decoded.userId);

        if (!user) {
            return res.status(404).json({ success: false, message: 'User not found or token is invalid.' });
        }

        user.password = newPassword; // Mongoose pre-save hook should hash this
        await user.save();

        return res.status(200).json({ success: true, message: 'Password has been reset successfully.' });
    } catch (error) {
        if (error.name === 'TokenExpiredError') {
            return res.status(400).json({ success: false, message: 'Reset link expired. Please request a new one.' });
        }
        if (error.name === 'JsonWebTokenError') {
            return res.status(400).json({ success: false, message: 'Invalid reset token. Please request a new one.' });
        }

        console.error('Error in resetPassword:', error);
        return res.status(500).json({ success: false, message: 'Failed to reset password. Please try again later.' });
    }
};


exports.changePassword = async (req, res) => {
    const { currentPassword, newPassword, confirmNewPassword } = req.body;

    // `req.user` is populated by the `authenticateUser` middleware
    const userId = req.user._id;

    if (!currentPassword || !newPassword || !confirmNewPassword) {
        return res.status(400).json({ success: false, message: "All password fields are required." });
    }

    if (newPassword !== confirmNewPassword) {
        return res.status(400).json({ success: false, message: "New password and confirm password do not match." });
    }

    if (newPassword.length < 8) {
        return res.status(400).json({ success: false, message: "New password must be at least 8 characters long." });
    }

    try {
        const user = await User.findById(userId);
        if (!user) {
            // This case should ideally not happen if authenticateUser works correctly
            return res.status(404).json({ success: false, message: "User not found." });
        }

        // Verify current password against the hashed password in DB
        const isMatch = await user.comparePassword(currentPassword); // Assuming comparePassword method
        if (!isMatch) {
            return res.status(401).json({ success: false, message: "Incorrect current password." });
        }

        // Update password (Mongoose pre-save hook should handle hashing the new password)
        user.password = newPassword;
        await user.save();

        return res.status(200).json({ success: true, message: "Password changed successfully!" });

    } catch (error) {
        console.error("Error in changePassword:", error);
        // Specific error handling for database issues, validation, etc.
        return res.status(500).json({ success: false, message: "Server error during password change." });
    }
};

// ⭐ NEW: Update User Profile (for logged-in users) ⭐
exports.updateProfile = async (req, res) => {
    // `req.user` is populated by the `authenticateUser` middleware
    const userId = req.user._id;
    const { fullName, email, phoneNumber } = req.body;
    console.log(req.body)

    try {
        const user = await User.findById(userId);
        if (!user) {
            return res.status(404).json({ success: false, message: "User not found." });
        }

        // --- Important: Handle email change to prevent duplicate emails ---
        if (email && email !== user.email) {
            const existingUserWithEmail = await User.findOne({ email });
            // If another user already has this email (and it's not the current user's ID)
            if (existingUserWithEmail && String(existingUserWithEmail._id) !== String(userId)) {
                return res.status(400).json({ success: false, message: "Email already in use by another account." });
            }
        }

        // Update fields if they are provided in the request body (and are different)
        if (fullName !== undefined && fullName !== user.fullName) user.fullName = fullName;
        if (email !== undefined && email !== user.email) user.email = email;
        if (phoneNumber !== undefined && phoneNumber !== user.phoneNumber) user.phoneNumber = phoneNumber;
        await user.save();

        // Only save if there were actual changes to avoid unnecessary writes
        //



        // Return the updated user object, excluding the password
        const { password: _, ...userWithoutPassword } = user.toObject();

        return res.status(200).json({
            success: true,
            message: "Profile updated successfully!",
            user: userWithoutPassword
        });

    } catch (error) {
        console.error("Error in updateProfile:", error);
        // Handle Mongoose validation errors or other server errors
        if (error.name === 'ValidationError') {
            const messages = Object.values(error.errors).map(val => val.message);
            return res.status(400).json({ success: false, message: messages.join(', ') });
        }
        return res.status(500).json({ success: false, message: "Server error during profile update." });
    }
};