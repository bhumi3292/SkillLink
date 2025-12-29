# SkillLink: A Professional Service Marketplace Platform

SkillLink is a robust, full-stack platform designed to bridge the gap between skilled professionals (Workers) and individuals seeking services (Hirers). The platform provides a seamless ecosystem for discovering talent, managing bookings, secure payments, and real-time communication.

## 🚀 Project Overview

The project consists of two main components:
1.  **Backend**: A high-performance Node.js/Express API with MongoDB.
2.  **Mobile App**: A cross-platform Flutter application for iOS and Android.

---

## 🏗️ System Architecture

SkillLink follows a modern architectural pattern to ensure scalability, maintainability, and security.

### 🔙 Backend (Node.js & Express)
Located in the `/backend` directory, the server handles business logic, data persistence, and real-time events.
- **Framework**: Express.js
- **Database**: MongoDB with Mongoose ODM
- **Real-time**: Socket.IO for instant messaging and notifications
- **Authentication**: JWT (JSON Web Tokens) with Secure Password Hashing (Bcrypt)
- **AI Integration**: Google Gemini AI for an intelligent support chatbot
- **File Storage**: Multer for handling professional portfolios and media
- **Testing**: Comprehensive test suite using Jest and Supertest

### 📱 Frontend (Flutter Mobile App)
Located in the `/skill_link` directory, the mobile app provides a premium user experience.
- **State Management**: BLoC Pattern (Business Logic Component) for predictable state
- **Clean Architecture**: Domain-driven design with separate layers for Data, Domain, and Presentation
- **Dependency Injection**: GetIt for decoupling components
- **Navigation**: Sophisticated routing with bottom navigation bar and deep linking
- **Payment Gateways**: Integrated with eSewa, Khalti, and PayPal
- **Maps**: Interactive discovery using Google Maps and OpenStreetMap (OSM)

---

## ✨ Core Features

### 👤 User Management
- **Multi-Role Support**: Distinct workflows for Workers and Hirers.
- **Secure Auth**: OTP-based verification and JWT-secured sessions.
- **Profile Customization**: Detailed professional profiles including skills, background, and media portfolios.

### 🔍 Discovery & Booking
- **Smart Explore**: Filter workers by categories, ratings, and proximity.
- **Booking Engine**: Dynamic scheduling with calendar integration and availability management.
- **Status Tracking**: Real-time updates on booking progress (Pending, Approved, Completed).

### 💬 Communication & Support
- **Live Chat**: Real-time P2P messaging between workers and hirers.
- **AI Assistant**: A floating Gemini-powered chatbot to guide users and answer queries.
- **Push Notifications**: Instant alerts for messages, bookings, and payment confirmations.

### 💳 Financial Ecosystem
- **Secure Payments**: Unified payment interface supporting multiple local and international providers.
- **Transaction History**: Transparent logs for all financial activities.
- **Reviews & Ratings**: Trust-building system through verified user feedback.

---

## 🛠️ Tech Stack Details

| Layer | Technologies |
| :--- | :--- |
| **Frontend** | Flutter, BLoC, Dio, Get_it, Google Maps, Lottie |
| **Backend** | Node.js, Express, MongoDB, Socket.io, Multer |
| **AI/ML** | Google Gemini API (Generative AI) |
| **Payments** | eSewa, Khalti, PayPal |
| **DevOps** | Docker, Jest, Nodemon, Git |

---

## 🚀 Getting Started

### Backend Setup
1. Navigate to `/backend`
2. Run `npm install`
3. Configure `.env` (Database URI, JWT Secret, Gemini API Key)
4. Run `npm run dev` for development or `npm start` for production.

### Mobile App Setup
1. Navigate to `/skill_link`
2. Run `flutter pub get`
3. Configure API endpoints in `lib/app/constant/api_endpoints.dart`
4. Run `flutter run`

---

## 🔒 Security & Performance
- **Data Protection**: Encrypted sensitive data and secure local storage.
- **Optimized Media**: Advanced caching for images and efficient video rendering.
- **Lazy Loading**: High-performance lists and smooth scrolling across all views.

---

**SkillLink** - *Empowering Professionals, Simplifying Services.* 🛠️
