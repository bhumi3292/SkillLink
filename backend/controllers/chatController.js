// SkillLink_backend/controllers/chat.controller.js
const Chat = require('../models/chat');
const User = require('../models/User');
const Worker = require('../models/Worker');
const { asyncHandler } = require('../utils/asyncHandler');


exports.createOrGetChat = asyncHandler(async (req, res) => {
    const currentUserId = req.user._id;
    // workerId passed from client is now referring to a Worker listing ID
    const { otherUserId, workerListingId } = req.body;
    // Backward compatibility if client still sends workerId
    const targetListingId = workerListingId || req.body.workerId;

    if (!otherUserId) {
        return res.status(400).json({ success: false, message: "Other user ID is required." });
    }
    if (currentUserId.toString() === otherUserId.toString()) {
        return res.status(400).json({ success: false, message: "Cannot chat with yourself." });
    }

    const [currentUser, otherUser] = await Promise.all([
        User.findById(currentUserId),
        User.findById(otherUserId)
    ]);
    if (!currentUser || !otherUser) {
        return res.status(404).json({ success: false, message: "One or both users not found." });
    }

    let query;
    let chatName = `Chat between ${currentUser.fullName} and ${otherUser.fullName}`;

    if (targetListingId) {
        const listing = await Worker.findById(targetListingId);
        if (!listing) {
            return res.status(404).json({ success: false, message: "Worker listing not found." });
        }
        // Query for chat with specific participants AND specific workerListing
        query = {
            $and: [
                { participants: { $all: [currentUserId, otherUserId] } },
                { workerListing: targetListingId }
            ]
        };
        chatName = `Chat for ${listing.title}: ${currentUser.fullName} - ${otherUser.fullName}`;
    } else {
        // Query for chat with specific participants AND no workerListing
        query = {
            $and: [
                { participants: { $all: [currentUserId, otherUserId] } },
                {
                    $or: [
                        { workerListing: { $exists: false } },
                        { workerListing: null }
                    ]
                }
            ]
        };
    }

    console.log('[DEBUG] Chat query:', JSON.stringify(query));
    let chat = await Chat.findOne(query).populate('participants', 'fullName profilePicture');

    if (!chat) {
        // Build payload without setting workerListing when not present so the field is not added as null
        const chatPayload = {
            name: chatName,
            participants: [currentUserId, otherUserId],
            messages: [] // Initialize messages array
        };
        if (targetListingId) chatPayload.workerListing = targetListingId;

        chat = await Chat.create(chatPayload);
        // Populate participants for the newly created chat
        chat = await Chat.findById(chat._id).populate('participants', 'fullName profilePicture');
        return res.status(201).json({ success: true, message: "New chat created.", data: chat });
    }

    return res.status(200).json({ success: true, message: "Existing chat retrieved.", data: chat });
});


exports.getMyChats = asyncHandler(async (req, res) => {
    const userId = req.user._id;

    const chats = await Chat.find({ participants: userId })
        .populate('participants', 'fullName profilePicture')
        .populate('workerListing', 'title images') // Populate workerListing instead of worker
        .sort({ lastMessageAt: -1 });

    return res.status(200).json({ success: true, data: chats });
});

exports.getChatById = asyncHandler(async (req, res) => {
    const chatId = req.params.chatId;
    const userId = req.user._id;

    // Populate participants and workerListing
    const chat = await Chat.findById(chatId)
        .populate('participants', 'fullName profilePicture')
        .populate('workerListing', 'title images')
        .populate('messages.sender', 'fullName profilePicture') // Populate sender
        .sort({ "messages.createdAt": 1 });

    if (!chat) {
        return res.status(404).json({ success: false, message: "Chat not found." });
    }

    // Authorize: Ensure the authenticated user is one of the participants
    if (!chat.participants.some(p => p._id.toString() === userId.toString())) {
        return res.status(403).json({ success: false, message: "Not authorized to access this chat." });
    }

    return res.status(200).json({ success: true, data: chat });
});


// @desc    Get messages for a specific chat
// @route   GET /api/chats/:chatId/messages
// @access  Protected (user must be a participant)
exports.getMessagesForChat = asyncHandler(async (req, res) => {
    const chatId = req.params.chatId;
    const userId = req.user._id;

    const chat = await Chat.findById(chatId)
        .populate('messages.sender', 'fullName profilePicture') // Populate sender of each message
        .sort({ "messages.createdAt": 1 }); // Ensure messages are sorted by time

    if (!chat) {
        return res.status(404).json({ success: false, message: "Chat not found." });
    }

    // Authorize: Ensure the authenticated user is one of the participants
    if (!chat.participants.some(p => p._id.toString() === userId.toString())) {
        return res.status(403).json({ success: false, message: "Not authorized to access messages in this chat." });
    }

    // Return just the messages array
    return res.status(200).json({ success: true, data: chat.messages });
});