# Secret Society Hub

Hello and welcome ✨

This seemed pretty straightforward until I realized I didn't even know what I was building, so I decided to make it a hub for members of a secret society. No one knows what kind of secret society, what their agenda is, or why some of them are apparently located in the middle of the ocean, but hey, at least they are registered.

---

# 🏛️ The Overview


## 1. **MVVM + Services**

The project follows a very simple MVVM, nothing over-engineered, just easy to follow.
I must admit that it had a strong contender that seems reasonable for smaller projects, which is [VOODO](https://swiftuivoodo.com). Even though I'm not entirely convinced by it.

---

## 2. **Session Management**

Authentication state lives in a tiny global store:

* `SessionStore`
* holds the `authToken`
* persists it in `Keychain`
* injected via `@EnvironmentObject`

Which satisfies the requirement:

> *“If the user was logged in last time, skip the login screen on next launch.”*

---

## 3. **The Networking Layer**

Since the backend is as fictional as the secret society itself, services read from JSON files:

### **AuthService**

* `POST /api/login` is simulated by decoding `login.json`
* returns a token to mimic actual backend behavior
* throws errors when username/password are missing
* includes an API-ready implementation

📌 **TODO:** Hardcode a valid username/password, add failure scenarios, trim whitespace, and handle bad input properly.

### **UserService**

* `GET /api/users` is simulated by decoding `users.json`
* checks the token (to mimic `x-auth-token` header)
* returns parsed users
* also includes an API-ready implementation

All calls are async/await and sleep for 0.3s to feel “realistic”.

📌 **TODO:** Each service currently handles its own networking. Works for now, but duplicates logic. Extracting a small `NetworkClient` would clean this up nicely.

---

## 4. **SwiftData for Favorites**

Favorites are stored **locally** using SwiftData.  
Ideally, the backend would expose an `isFavourite` property in the payload, so toggling it would trigger a request to update the value on the server. Since that doesn’t exist, the app keeps track of this state on its own.

* `FavoriteMember` is the single SwiftData model
* only stores `id` + `fullName`
* doesn’t duplicate entire user objects

📌 **TODO:** Move this responsibility to the backend once supported, and remove the need for SwiftData/local caching.

---

## 5. **TODOs and Improvements (in addition to those already mentioned)**
*(Not listed in order of priority, just grouped by type)*

### Code Quality & Maintainability
- Move helpers and modifiers into separate files (date, phone number, coordinate formatters…)  
- Clean up hardcoded values across the entire project (æsj, sorry)
- Introduce a proper unique user identifier
- Add tests

---

### Architecture & Structure
- Improve error handling
- Consider adding coordinator-based navigation + action handling (nice-to-have, but would be overengineering for the current scope)

---

### Performance & Data Handling
- Cache the data to improve performance and reduce unnecessary work

---

###  User Experience
- Add accessibility support (labels, Dynamic Type, VoiceOver, check the contrast)
- Add missing SwiftUI previews to speed up development

---

All in all, I wanted to do more, but had to stop somewhere.

Five stars, had fun ⭐️

Thanks for stopping by the archives 👋

