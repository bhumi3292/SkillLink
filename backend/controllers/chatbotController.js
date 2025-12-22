// SkillLink_backend/controllers/ChatbotController.js

const ApiError = require("../utils/api_error");
const ApiResponse = require("../utils/api_response");
const { GoogleGenerativeAI } = require("@google/generative-ai");

const Worker = require("../models/Worker");
const User = require("../models/User");
const Category = require("../models/Category");


const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);

const generateKnowledgeBase = async () => {
    let context = "";

    try {
        const recentWorkers = await Worker.find({}).sort({ createdAt: -1 }).limit(5).populate('categoryId', 'category_name');

        context += "LIVE WORKER SERVICES (recent listings):\n";
        if (recentWorkers.length > 0) {
            recentWorkers.forEach(worker => {
                context += `- Title/Skill: ${worker.title}, Category: ${worker.categoryId ? worker.categoryId.category_name : 'N/A'}, Location: ${worker.location}, Rate: Rs. ${worker.price ? worker.price.toLocaleString() : 'N/A'}.\n`;
            });
        } else {
            context += "No recent worker services available in the system.\n";
        }

        // Fetch some workers users (optional, but good for context if chatbot is asked about them)
        const workerUsers = await User.find({ role: "worker" }).limit(3); // Assuming 'role' field in User model

        context += "\nOUR PROFESSIONALS (examples):\n";
        if (workerUsers.length > 0) {
            workerUsers.forEach(user => {
                context += `- Name: ${user.fullName || 'N/A'}, Email: ${user.email || 'N/A'}.\n`;
            });
        } else {
            context += "No worker information available.\n";
        }

        // Fetch categories
        const categories = await Category.find({});
        context += "\nSERVICE CATEGORIES:\n";
        if (categories.length > 0) {
            context += categories.map(cat => `- ${cat.category_name}`).join('\n') + '.\n';
        } else {
            context += "No service categories defined.\n";
        }

    } catch (dbError) {
        console.error("Error fetching data for knowledge base:", dbError);
        context += "\nNote: Data retrieval failed, I might have limited real-time information.\n";
    }

    return context;
};

// This is the static personality and FAQ for your bot.
const systemPrompt = `You are DreamBot, the friendly and helpful chatbot assistant for "SkillLink", a platform connecting users in Kathmandu, Nepal with skilled workers.

Your mission is to guide users through:
- Finding skilled workers (plumbers, electricians, cleaners, etc.)
- Registering as a worker and listing services
- Answering site-related or service-related questions
- Providing general advice on hiring services in Nepal

Tone:
- Be welcoming, professional, and use phrases related to getting things done and finding reliable help.
- Keep replies concise, clear, and friendly.

Capabilities:
1. **Worker Recommendations:**
    - If the user asks about specific services, use the LIVE WORKER SERVICES to recommend a few options.
    - Ask follow-up questions like:
        - "What kind of service do you need (plumbing, cleaning, tuition)?"
        - "Do you have a preferred location in Kathmandu?"
        - "What's your budget?"
    - Then suggest a few profiles based on that info.

2. **Listing Services:**
    - If the user wants to list their service, guide them to the "Add Worker" page.
    - Explain the process: "If you're a skilled professional, you can easily list your services on SkillLink! Just log in, go to the 'Add Worker' section, and fill in your details. We'll help you showcase your skills to potential clients."

3. **Hiring Process/Advice:**
    - If they ask about the hiring process, offer general tips:
        - "Always check the worker's profile and reviews."
        - "Clarify the scope of work and rates beforehand."
        - "Confirm availability and location coverage."

4. **Other Questions:**
    - If you're unsure or the question is outside your scope, reply:
        - "I'm not sure about that, but you can always browse our full worker listings or check our FAQ page for more details!"

👋 First Message:
Always start your very first response with:
"Namaste! I'm DreamBot, your friendly guide at SkillLink. How can I help you find the right professional or list your services today?"

🏡 LIVE DATA:
The latest data from our system will appear below. Use it when available to generate your responses.

---
[Insert LIVE WORKER SERVICES and OUR PROFESSIONALS here]
[Insert SERVICE CATEGORIES here]

📚 FAQs for SkillLink:

🏠 What is SkillLink and how does it work?
"Namaste! SkillLink is your premier online platform for finding skilled workers in Kathmandu, Nepal. We connect clients with reliable professionals like plumbers, electricians, and more, making the hiring process smooth and transparent."

🛠️ Who created SkillLink?
"SkillLink was created by a dedicated team of tech innovators committed to simplifying the service hiring experience in Nepal."

👤 How do I update my profile?
"To update your profile, simply log in to your SkillLink account, navigate to your 'Profile Page', and select the 'Edit Profile' option."

🔍 How can I find workers on SkillLink?
"Finding workers on SkillLink is a breeze! You can use our search bar to filter by location, rate, and service type. Just tell me what you're looking for!"

🔑 How do I list my services?
"If you're a worker looking to offer your services, SkillLink is the place! Log in to your account, then head over to the 'Add Worker' section. Fill in all the details, upload photos, and your profile will be ready to attract clients."
`;


const handleChatQuery = async (req, res) => {
    try {
        const { query, history = [] } = req.body;

        if (!query) {
            // Using ApiError for validation errors
            throw new ApiError(400, "Query is required.");
        }

        const model = genAI.getGenerativeModel({ model: "gemini-1.5-flash" });

        const knowledgeBase = await generateKnowledgeBase();
        const fullSystemPrompt = systemPrompt + knowledgeBase;

        const formattedHistory = history.map(item => ({
            role: item.role,
            parts: [{ text: item.text }],
        })).filter(Boolean);

        const chat = model.startChat({
            history: [
                { role: "user", parts: [{ text: fullSystemPrompt }] },
                { role: "model", parts: [{ text: "Understood! I'm DreamBot, your assistant for SkillLink, ready to help users find services. Let's start!" }] },
                ...formattedHistory,
            ],
            generationConfig: {
                maxOutputTokens: 250,
            },
        });

        const result = await chat.sendMessage(query);
        const response = result.response;
        const text = response.text();

        // Using ApiResponse for successful responses
        return res.status(200).json(new ApiResponse(200, { reply: text }, "Chatbot responded successfully."));
    } catch (error) {
        console.error("Chatbot error:", error);
        // Ensure error is an instance of ApiError or default to a generic 500
        if (error instanceof ApiError) {
            return res.status(error.statusCode).json(error); // Send the custom ApiError
        }
        // For unexpected errors, send a generic 500 ApiError
        return res.status(500).json(new ApiError(500, error.message || "Internal server error during chatbot processing."));
    }
};

module.exports = handleChatQuery;