# Campus Crunch 🍔🕒

Hey! This is **Campus Crunch**, a real-time, independent canteen ordering ecosystem I built to fix the chaotic rush-hour mess we see in college canteens every single day. 

If you've ever stood in a massive college line, ordered food, paid for it, and then got told at the counter that it *just* ran out—you know exactly why I built this. This app syncs live stock counts with a fast, atomic backend so overselling is physically impossible.

---

## The Real-World Problems This Solves

1. **The Phantom Stock Crash:** If two students try to click "Buy" on the very last plate of food at the exact same millisecond, standard apps mess up and take money from both. Campus Crunch instantly **freezes the stock** the moment you initiate checkout, reserving it safely for 5 minutes while you handle the payment.
2. **The Counter Bottleneck:** Instead of forcing the canteen staff to constantly stare at a physical soundbox or a personal phone ledger during a rush, the admin panel handles validation with a secure, human-in-the-loop handshake that safely pushes real-time "Green Screen" completion tokens back to the student's phone.

---

## Tech Stack I Used

I wanted something fast, lightweight, and highly concurrent to handle hundreds of hungry students hammering the server at the exact same time.

### Frontend (The UI)
* **HTML5 & Vanilla JavaScript (ES6+):** Handles the absolute core mechanics—cart states, dynamic countdown timers, and the real-time background short-polling engine.
* **Tailwind CSS:** Used via CDN to keep the entire user interface highly responsive, mobile-first, and completely dark-themed so it looks like a native application on Android or iOS.

### Backend (The Brains)
* **FastAPI (Python):** An incredibly fast, asynchronous web framework built for handling concurrent API routing without breaking a sweat.
* **Uvicorn:** The high-performance ASGI server used to run and serve the FastAPI application.

### Database Layer (The Storage)
* **PostgreSQL:** The core relational database management system. I chose Postgres specifically because it allows me to implement **Row-Level Database Locking** to freeze stock counts instantly.
* **Asyncpg:** A blazing-fast, non-blocking asynchronous database interface library that lets Python communicate with Postgres simultaneously under heavy loads.

---

## Core System Architecture

* **The Checkout Lock:** When a student hits checkout, the FastAPI backend hits Postgres with a `FOR UPDATE` query on that item's row. The row locks, the stock checks out, and it's securely deducted before a payment screen is even generated. 
* **The Real-Time Handshake:** While the user handles payment, their phone screen shows a yellow countdown clock. The second the canteen worker fetches the Order ID on `admin.html` and completes the check, the student's background polling script catches the database change. Within 2.5 seconds, the student's screen automatically snaps into a bright green verification token.