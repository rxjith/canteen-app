# Campus Crunch 🍔🕒
#### Video Demo:  <[Project Demo](https://youtu.be/pvb9rkoh_qI)>

#### Description:
**Campus Crunch** is a real-time canteen ordering web application built to solve a major problem we face in Indian colleges: massive rush-hour lines, and ordering food only to find out it *just* ran out at the counter.

This app connects students directly to the kitchen inventory in real time. It ensures that students can only buy what is actually available, and it locks down the stock automatically the moment an order is started so nobody else can steal your food while you pay.

---

## The Real-World Problems This Solves

1. **The Phantom Stock Crash:** In standard apps, if two people click "Buy" on the very last plate of food at the exact same millisecond, the app accidentally takes money from both. Campus Crunch fixes this by instantly freezing the food item in the database during checkout, holding it for 5 minutes while the student pays.
2. **The Counter Bottleneck:** Instead of making canteen workers scroll through their personal banking alerts or soundboxes during a rush, our system introduces a smart "visual handshake." The staff console explicitly tells the worker to check for payment, and once they confirm it, the student's phone instantly turns green to show their food token is verified.

---

## File-by-File Breakdown

The project is built split cleanly into three main files:

### 1. `main.py` (The Backend Brain)
Written in **FastAPI** (Python), this script acts as the traffic controller for the entire system. It connects directly to our database using **Asyncpg** to ensure it can handle hundreds of hungry students placing orders at the exact same time. It handles checking the stock, freezing items, updating order statuses, and serving data to both the student and admin panels.

### 2. `index.html` (The Student App)
This is the interface the student uses on their phone, designed beautifully with **HTML5** and **Tailwind CSS**. Built with simple, clean **Vanilla JavaScript**, it displays today's live menu, handles the shopping cart, and updates the checkout screen. It uses a small background checking loop (short-polling) to ask the server every 2.5 seconds if the order has been approved yet.

### 3. `admin.html` (The Staff Panel)
This is the dashboard running on the canteen counter screen. It allows the workers to quickly type in a student's Order ID to pull up their plate details. It also features live inventory controls, meaning the canteen manager can update food prices, add new dishes, or change stock levels on the fly, instantly changing what students see on their phones.

---

## Why I Made These Design Choices

### Database Locking vs. App Coding
When handling food stock, we had to decide how to block double-orders. We chose **PostgreSQL Row-Level Locking** (`FOR UPDATE`) instead of managing it inside our Python code. By letting the database isolate and lock the exact row of the food item being purchased, the system is 100% accurate. Even if the backend expands or handles thousands of transactions at once, the database ensures a completely safe queue.

### Short-Polling vs. WebSockets
To make the student's screen turn green instantly when the admin clicks approve, we needed real-time communication. We chose **HTTP Short-Polling** (checking the server every 2.5 seconds) over persistent WebSockets. Since students are constantly walking around campus, moving between mobile data and college Wi-Fi, WebSockets would constantly drop and crash. Short-polling is incredibly lightweight, handles bad network signals easily, and never breaks the user experience on mobile browsers.

<h5>This project was engineered with Gemini as a partner to help fix some bugs, but most of the code was written by me.<h5/>
