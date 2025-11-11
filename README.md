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

[Trello Board – NoLeftovers ] - https://trello.com/invite/b/68da7a96be707d9083ab14e5/ATTIff80e80cac80645c70550b8b252511ea3834C975/software-development-team-project

**Initial Epics / User Stories:**
- **Authentication Epic** – As a user, I want to register/login so that I can access the app.  
- **Offer Management Epic** – As a restaurant, I want to create and manage offers so that customers can see my food.  
- **Offer Browsing Epic** – As a customer, I want to browse offers (list/map) so I can find cheap meals.  
- **Reservation Epic** – As a customer, I want to reserve food so that I can pick it up later.  
- **Localization Epic** – As a user, I want to switch the app language (EN, ET, RU) so I can use it comfortably.  

---


## Building APK

### Prerequisites
- Flutter SDK installed (3.0+)
- Android Studio or Android SDK tools
- Java Development Kit (JDK) 11 or later

### Build Release APK

1. **Clean the project:**
   
   flutter clean
   ```

2. **Get dependencies:**
   
   flutter pub get
   ```

3. **Build APK:**
   
   flutter build apk --release
   ```

   The APK will be generated at: `build/app/outputs/flutter-apk/app-release.apk`


## Firebase Setup

This project uses Firebase. To run it locally:

1. Install Firebase CLI:

   npm install -g firebase-tools
   dart pub global activate flutterfire_cli
   
2. Configure Firebase for your project:

     flutterfire configure

3. This will automatically create:

    lib/firebase_options.dart
    android/app/google-services.json

4. Run the app

    flutter run 
    
