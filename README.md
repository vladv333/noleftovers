# NoLeftovers
SOFTWARE DEVELOPMENT TEAM PROJECT : NoLeftovers


# NoLeftovers

## Team Members
- Vlad – Backend & Integration (Firebase Auth, CRUD, API)
- Ilya – Database (Firestore schema, queries, validation)
- Egor – Frontend/UI (Flutter UI, i18n, map integration)

---

## Project Description
**NoLeftovers** is a mobile application that helps reduce food waste in Estonia by connecting restaurants, cafés, and bakeries with customers.  
Restaurants can post surplus food at a discount, and customers can easily find and reserve affordable meals nearby.  

The app contributes to sustainability, helps businesses minimize losses, and provides affordable food options for people in times of rising prices.  

**Core Features:**
- Firebase Authentication for users and restaurants
- CRUD operations for offers (create, read, update, delete)
- Offer browsing (list + map via OpenMap API)
- Reservations and confirmations
- Image upload (Firebase Storage)
- Multilingual support (EN, ET, RU)
- Push notifications for new offers (Firebase Cloud Messaging)

---

## Tech Stack
- **Frontend:** Flutter + FLUI
- **Backend / DB:** Firebase (Auth, Firestore, Storage, Cloud Messaging)
- **External API:** OpenMap API (geolocation + maps)
- **Project Management:** Trello (link below)

---

## Main Milestones
1. **M1 (22.09):** Requirements & mockups complete, DB schema approved  
2. **M2 (06.10):** Firebase Auth + CRUD ready  
3. **M3 (20.10):** Flutter prototype with i18n complete  
4. **M4 (27.10):** Integrated MVP (CRUD + Map + Reservations)  
5. **M5 (04.11):** Stable demo-ready build + presentation slides  

---

## Project Management (to be updated later)
We use **Trello** to manage tasks and track user stories.  

[Trello Board – NoLeftovers *  

**Initial Epics / User Stories:**
- **Authentication Epic** – As a user, I want to register/login so that I can access the app.  
- **Offer Management Epic** – As a restaurant, I want to create and manage offers so that customers can see my food.  
- **Offer Browsing Epic** – As a customer, I want to browse offers (list/map) so I can find cheap meals.  
- **Reservation Epic** – As a customer, I want to reserve food so that I can pick it up later.  
- **Localization Epic** – As a user, I want to switch the app language (EN, ET, RU) so I can use it comfortably.  

---

## How to Run (to be updated later)
- Clone repository  
- Configure Firebase project and add `.env` file  
- Run Flutter app: `flutter run`  
