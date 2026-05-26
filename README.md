# 🍎 Switch-On Diet

A fully offline-first 28-day structured diet tracking mobile application built with Flutter (iOS + Android).

This app is designed to help users follow a strict 28-day diet program with daily meal tracking, automated reminders, and progress visualization — all without any backend server.

---

## 📱 Overview

**Switch-On Diet** is a minimal yet structured habit-tracking app focused on consistency and discipline over 28 days.

The app runs completely offline and stores all user data locally on the device.

### Key Concept

> "Start once, stay consistent for 28 days."

---

## ✨ Features

### 📆 28-Day Program System

* Automatically calculates current day (Day N)
* Based on user-defined start date
* Fixed 28-day cycle

---

### 🚀 Onboarding Flow

* Welcome screen on first launch
* "Start" button initializes program
* Saves `startDate` locally
* Skips onboarding on future launches

---

### 🍽️ Daily Meal Tracking

Each day includes:

* Breakfast
* Lunch
* Snack
* Dinner

Users can check off meals as completed.

---

### 📊 Diet Rules System

Dynamic weekly diet rules:

* Days 1–3: vegetables, tofu, yogurt only
* Day 4+: expanded diet (eggs, fish, meat, etc.)

---

### 🔔 Smart Local Notifications

* When a meal is checked:

  * Reminder notification after 5h 45m
  * Follow-up reminder after 6h 30m if incomplete

> Fully implemented using local notification system only (no backend)

---

### 🎉 Daily Completion Reward

* Confetti / fireworks animation when all meals are completed
* Positive reinforcement for consistency

---

### ⚙️ Settings

* Simple notification toggle (ON / OFF only)
* Minimal configuration by design

---

### 📦 Offline Data Management

* Fully offline-first architecture
* Export user data as JSON file
* Import data to restore or transfer to another device

---

## 🏗️ Architecture

The app follows a clean, scalable Flutter architecture:

```text
lib/
 ├── core/          # utilities, constants, helpers
 ├── data/          # local storage, models
 ├── domain/        # business logic
 ├── presentation/  # UI screens
```

### Design Principles

* Offline-first
* Separation of concerns
* Feature-based modular structure

---

## 🧠 State Management

* Recommended: Riverpod / Provider / Bloc
* Local state persists using SQLite / Hive

---

## 🔔 Notification Strategy

* Uses `flutter_local_notifications`
* Schedule-based reminder system:

  * Trigger 1: +5h 45m after check
  * Trigger 2: +6h 30m fallback reminder

⚠️ Designed with iOS background limitations in mind.

---

## 🛠 Tech Stack

* Flutter
* Dart
* Hive / SQLite
* `flutter_local_notifications`
* Lottie / Confetti
* File system API (JSON export/import)

---

## 📂 Data Model (Simplified)

```json
{
  "startDate": "2026-01-01",
  "days": [
    {
      "day": 1,
      "meals": {
        "breakfast": true,
        "lunch": false,
        "snack": true,
        "dinner": true
      }
    }
  ]
}
```

---

## ⚠️ Edge Cases & Considerations

* App reinstall resets local data unless exported
* iOS may delay scheduled notifications
* Timezone changes may affect Day calculation
* 28-day overflow must be handled safely
* Background execution is limited on mobile OS

---

## 🎯 Why This Project Matters

This project demonstrates:

* Offline-first mobile architecture
* Local persistence strategy
* Time-based scheduling logic
* Clean Flutter project structuring
* Real-world product thinking

---

## 🚀 Future Improvements

* Apple Health / Google Fit integration
* Cloud sync (optional)
* Habit streak system
* Dark mode
* AI diet suggestions

---

## 👨‍💻 Author

Portfolio project showcasing Flutter architecture and offline-first mobile system design.

---

## 📌 License

For educational and portfolio use.
