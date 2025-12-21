// SkillLink_backend/controllers/ChatbotController.js

const ApiError = require("../utils/api_error");
const ApiResponse = require("../utils/api_response");
const { GoogleGenerativeAI } = require("@google/generative-ai");

const Property = require("../models/Property");
const User = require("../models/User");
const Category = require("../models/Category");


const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);

const generateKnowledgeBase = async () => {
    let context = "";

    try {
        const recentProperties = await Property.find({}).sort({ createdAt: -1 }).limit(5).populate('categoryId', 'category_name');

        context += "LIVE PROPERTY INFORMATION (recent listings):\n";
        if (recentProperties.length > 0) {
            recentProperties.forEach(prop => {
                context += `- Title: ${prop.title}, Type: ${prop.categoryId ? prop.categoryId.category_name : 'N/A'}, Location: ${prop.location}, Price: Rs. ${prop.price ? prop.price.toLocaleString() : 'N/A'}, Bedrooms: ${prop.bedrooms || 'N/A'}, Bathrooms: ${prop.bathrooms || 'N/A'}.\n`;
            });
        } else {
            context += "No recent properties available in the system.\n";
        }

        // Fetch some workers (optional, but good for context if chatbot is asked about them)
        const workers = await User.find({ role: "worker" }).limit(3); // Assuming 'role' field in User model

        context += "\nOUR workerS (examples):\n";
        if (workers.length > 0) {
            workers.forEach(worker => {
                context += `- Name: ${worker.fullName || 'N/A'}, Email: ${worker.email || 'N/A'}.\n`;
            });
        } else {
            context += "No worker information available.\n";
        }

        // Fetch property categories
        const categories = await Category.find({});
        context += "\nPROPERTY CATEGORIES:\n";
        if (categories.length > 0) {
            context += categories.map(cat => `- ${cat.category_name}`).join('\n') + '.\n';
        } else {
            context += "No property categories defined.\n";
        }

    } catch (dbError) {
        console.error("Error fetching data for knowledge base:", dbError);
        context += "\nNote: Data retrieval failed, I might have limited real-time information.\n";
    }

    return context;
};

// This is the static personality and FAQ for your bot.
const systemPrompt = `You are DreamBot, the friendly and helpful chatbot assistant for "SkillLink", a property rental website based in Kathmandu, Nepal.

Your mission is to guide users through:
- Finding properties for rent
- Listing their own properties
- Answering site-related or property-related questions
- Providing general rental advice in Nepal

Tone:
- Be welcoming, professional, and use phrases related to homes and finding perfect spaces (e.g., "Let's find your dream home!", "Happy house-hunting!").
- Keep replies concise, clear, and friendly.

Capabilities:
1. **Property Recommendations:**
    - If the user asks about properties, use the LIVE PROPERTY INFORMATION to recommend a few options.
    - Ask follow-up questions like:
        - "What kind of property are you looking for (apartment, house, commercial space)?"
        - "Do you have a preferred location in Kathmandu (e.g., Lazimpat, Baneshwor, Thamel)?"
        - "What's your budget range?"
        - "How many bedrooms or bathrooms do you need?"
    - Then suggest a few properties based on that info.

2. **Listing Properties:**
    - If the user wants to list a property, guide them to the "Add Property" page.
    - Explain the process: "If you're a worker, you can easily list your property on SkillLink! Just log in, go to the 'Add Property' section, and fill in the details. We'll help you showcase your space to potential renters."

3. **Rental Process/Advice:**
    - If they ask about the rental process, offer general tips relevant to Nepal:
        - "Always view the property in person."
        - "Read your rental agreement carefully before signing."
        - "Understand utility costs and worker responsibilities."
        - "Confirm payment terms and security deposit details."

4. **Other Questions:**
    - If you're unsure or the question is outside your scope, reply:
        - "I'm not sure about that, but you can always browse our full property listings or check our FAQ page for more details!"

👋 First Message:
Always start your very first response with:
"Namaste! I'm DreamBot, your friendly guide at SkillLink. How can I help you find your perfect space or assist with your property today?"

🏡 LIVE DATA:
The latest data from our system will appear below. Use it when available to generate your responses.

---
[Insert LIVE PROPERTY INFORMATION and OUR workerS here]
[Insert PROPERTY CATEGORIES here]

📚 FAQs for SkillLink:

🏠 What is SkillLink and how does it work?
"Namaste! SkillLink is your premier online platform for property rentals in Kathmandu, Nepal. We connect renters with their ideal homes and workers with reliable Hirers, making the process smooth and transparent. Let's find your dream home together!"

🛠️ Who created SkillLink?
"SkillLink was created by a dedicated team of real estate enthusiasts and tech innovators committed to simplifying the property rental experience in Nepal. We're here to help you find your perfect space!"

👤 How do I update my profile?
"To update your profile, simply log in to your SkillLink account, navigate to your 'Profile Page' (usually by clicking on your name or avatar), and select the 'Edit Profile' option. You can update your contact information, preferences, and more!"

🔍 How can I find properties on SkillLink?
"Finding properties on SkillLink is a breeze! You can use our search bar to filter by location, price range, number of bedrooms, and property type. Just tell me what you're looking for, and I'll help you explore your options!"

🔑 How do I list my property for rent?
"If you're a worker looking to rent out your property, SkillLink is the place! Log in to your account, then head over to the 'Add Property' section. Fill in all the details, upload photos, and your listing will be ready to attract Hirers. It's super easy!"

🔐 I forgot my password. What do I do?
"No worries at all! If you've forgotten your password, just click on the 'Forgot Password' link on the login page. We'll send you an email with instructions to reset it and get you back into your SkillLink account in no time."

📜 What are some important rental tips in Nepal?
"Here are a few essential tips for renting in Nepal:
- Always visit the property in person before finalizing.
- Carefully read and understand your rental agreement.
- Clarify all utility bills and maintenance responsibilities.
- Ensure the security deposit terms are clear.
Happy house-hunting!"
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
                { role: "model", parts: [{ text: "Understood! I'm DreamBot, your assistant for SkillLink, ready to help users find properties or manage their listings. Let's start!" }] },
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