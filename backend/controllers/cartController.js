// SkillLink_backend/controllers/cartController.js
const Cart = require('../models/Cart'); // Assuming the model is named Cart.js
const Worker = require('../models/Worker');
const { asyncHandler } = require('../utils/asyncHandler'); // Assuming you have this utility

exports.getCart = asyncHandler(async (req, res) => {
    const userId = req.user._id; // User ID from authenticated request

    const cart = await Cart.findOne({ user: userId }).populate('items.worker');

    if (!cart) {
        // If a user doesn't have a cart yet, return an empty cart
        return res.status(200).json({ success: true, message: "Cart is empty or not yet created.", data: { user: userId, items: [] } });
    }

    res.status(200).json({ success: true, message: "Cart retrieved successfully.", data: cart });
});

exports.addToCart = asyncHandler(async (req, res) => {
    const userId = req.user._id;
    const { workerId } = req.body;

    // Use workerId from body if workerId is missing, for backward compatibility
    const targetWorkerId = workerId || req.body.workerId;


    if (!targetWorkerId) {
        return res.status(400).json({ success: false, message: "Worker ID is required to add to cart." });
    }

    // Validate if the worker exists
    const workerExists = await Worker.findById(targetWorkerId);
    if (!workerExists) {
        return res.status(404).json({ success: false, message: "Worker not found." });
    }

    let cart = await Cart.findOne({ user: userId });

    if (!cart) {
        // If no cart exists for the user, create a new one
        cart = await Cart.create({
            user: userId,
            items: [{ worker: targetWorkerId }]
        });
        return res.status(201).json({ success: true, message: "Cart created and worker added.", data: cart });
    }

    // Check if the worker is already in the cart
    const itemExists = cart.items.some(item => item.worker.toString() === targetWorkerId);

    if (itemExists) {
        return res.status(409).json({ success: false, message: "Worker already in cart." });
    } else {
        // Add the new worker to the existing cart
        cart.items.push({ worker: targetWorkerId });
        await cart.save();
        return res.status(200).json({ success: true, message: "Worker added to cart.", data: cart });
    }
});
exports.removeFromCart = asyncHandler(async (req, res) => {
    const userId = req.user._id;
    // Allow removing by workerId in params for now, but treat it as workerId
    const { workerId } = req.params;

    // Ideally we should use workerId, but let's stick to what routes provide if they use :workerId
    const targetId = workerId;

    let cart = await Cart.findOne({ user: userId });

    if (!cart) {
        return res.status(404).json({ success: false, message: "Cart not found." });
    }

    // Filter out the item to be removed
    const initialItemCount = cart.items.length;
    cart.items = cart.items.filter(item => item.worker.toString() !== targetId);

    if (cart.items.length === initialItemCount) {
        // If no item was removed, it means the ID was not in the cart
        return res.status(404).json({ success: false, message: "Worker not found in cart." });
    }

    await cart.save();
    res.status(200).json({ success: true, message: "Worker removed from cart.", data: cart });
});
exports.clearCart = asyncHandler(async (req, res) => {
    const userId = req.user._id;

    const result = await Cart.deleteOne({ user: userId });

    if (result.deletedCount === 0) {
        return res.status(404).json({ success: false, message: "Cart not found to clear." });
    }


    res.status(200).json({ success: true, message: "Cart cleared successfully." });
});