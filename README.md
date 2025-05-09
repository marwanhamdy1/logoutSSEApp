# 🔄 Flutter SSE (Server-Sent Events) LogOut SSE App

This is a **LogOut SSE project** demonstrating how to integrate **Server-Sent Events (SSE)** in a Flutter app using **Cubit (Bloc)** for state management.

> ⚠️ **Note:** This project is not intended for production use. It is a demonstration of SSE usage and session handling. Security, error handling, reconnection logic, and authentication should be improved before using it in real applications.

---

## 📌 Project Overview

The app has two screens:

1. **LoginScreen**: Accepts a `User ID` and establishes an SSE connection.
2. **SSEScreen**: Displays the connection status and incoming messages from the server. It includes a "Disconnect" button.

### 🎯 Purpose

- Demonstrate basic **SSE integration** in Flutter.
- Show how to listen for a server event to **automatically logout** the user when the session ends.
- Learn how to manage live communication from the server with minimal overhead.
- Illustrate a **multi-device session logout** pattern:
  > If User A logs in on Device 1, then logs in again on Device 2, the server sends a `session_ended` event to Device 1, logging them out in real time.


---

## 🔍 What is SSE?

**Server-Sent Events (SSE)** is a server push technology enabling a server to push real-time updates to the client over **HTTP**.

- Lightweight compared to WebSockets.
- Ideal for one-way streaming of events.
- Standardized and supported natively by browsers and backend frameworks.

In Flutter, we simulate listening to an SSE stream via an `http` client (or a stream controller).

---

## 🚀 How It Works

1. The user enters a `User ID` and taps **Connect**.
2. The app connects to the backend via an SSE stream.
3. The server sends real-time messages (e.g., updates, session signals).
4. If the server sends a specific event (e.g. `"session_ended"`), the app:
   - Automatically **disconnects**
   - Navigates the user back to the login screen
   - Displays a snackbar message: `"Session ended"`.

---

## 🧪 Test Session Handling

To simulate a session end:

- The server sends a message like:
  ```json
  {
    "event": "session_ended",
    "message": "Your session has expired"
  }
### 💻 Development Notes

- **Localhost setup:**  
  For Android emulator use `http://10.0.2.2:3000`, for others use `http://127.0.0.1:3000`.

- **No token/auth handling:**  
  This project doesn't implement authentication or token validation. You should **never rely on plain user IDs** in production.

- **Error and reconnect strategy:**  
  On connection failure, the app will retry after 5 seconds.

---

lib/
├── cubits/
│   └── sse_cubit.dart      # Manages SSE connection and state
├── screens/
│   ├── login_screen.dart   # User inputs ID and connects
│   └── sse_screen.dart     # Displays live connection/messages
