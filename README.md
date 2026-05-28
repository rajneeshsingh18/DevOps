# Docker + AWS Learning Journey 🚀

This repository documents my step-by-step progress in mastering **Docker** and **AWS**, starting from frontend setup to full-scale deployment.

---

## 🛠 Step 1: Setting up React + Tailwind CSS v4 (Vite)

In this step, I set up a modern frontend environment using Vite, **Tailwind CSS v4**, and integrated the **Monaco Editor**.

### 1. Create the React Project
```bash
npm create vite@latest frontend -- --template react
cd frontend
npm install
```

### 2. Install Tailwind CSS v4 & Monaco Editor
Tailwind v4 uses a dedicated Vite plugin for better performance and simpler configuration.
```bash
npm install tailwindcss @tailwindcss/vite @monaco-editor/react monaco-editor
```

### 3. Configure Vite Plugin
Unlike v3, Tailwind v4 is integrated directly into `vite.config.js`:
```javascript
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import tailwindcss from "@tailwindcss/vite"

export default defineConfig({
  plugins: [
    react(),
    tailwindcss()
  ],
})
```

### 4. Add Tailwind Import
In Tailwind v4, you only need one import in your main CSS file (e.g., `src/App.css`):
```css
@import "tailwindcss";
```

### 5. Implementing Monaco Editor
I integrated the Monaco Editor into `App.jsx` for a code-editing experience:
```jsx
import "./App.css"
import { Editor } from "@monaco-editor/react"

function App() {
  return (
    <main className="h-screen w-full bg-gray-950 flex gap-4">
      <aside className="h-full w-1/4 bg-amber-50 rounded-lg">
        {/* Sidebar content */}
      </aside>
      <section className="w-3/4 bg-neutral-700 rounded-lg">
        <Editor
          height="100%"
          defaultLanguage="javascript"
          defaultValue="// Start coding here..."
          theme="vs-dark"
        />
      </section>
    </main>
  )
}

export default App
```

### 6. Run the Development Server
```bash
npm run dev
```

---

## 🛠 Step 2: Creating Backend with Socket.io & Yjs

In this step, I built the collaborative backend using **Express**, **Socket.io**, and **Yjs** (via `y-socket.io`) to handle real-time code synchronization.

### 1. Initialize the Backend
```bash
mkdir backend
cd backend
npm init -y
```

### 2. Install Dependencies
```bash
npm install express socket.io y-socket.io
npm install -D nodemon
```

### 3. Configure `package.json`
Set the type to "module" to use ESM imports:
```json
{
  "type": "module",
  "scripts": {
    "dev": "nodemon server.js",
    "start": "node server.js"
  }
}
```

### 4. Create the Server (`server.js`)
The server initializes Socket.io and attaches the Yjs provider:
```javascript
import express from "express";
import { createServer } from "http";
import { Server } from "socket.io";
import { YSocketIO } from "y-socket.io/dist/server";

const app = express();
const httpServer = createServer(app);

const io = new Server(httpServer, {
    cors: {
        origin: "*",
        methods: ["GET", "POST"]
    }
});

// Initialize Yjs Socket.io provider
const ySocketIO = new YSocketIO(io);
ySocketIO.initialize();

app.get("/health", (req, res) => {
    res.status(200).json({ message: "ok", success: true });
});

httpServer.listen(3000, () => {
    console.log("Server is running on port 3000");
});
```

### 5. Running the Backend
```bash
npm run dev
```

---

## 📅 Roadmap
- [x] Step 1: React + Tailwind CSS v4 + Monaco Editor Setup
- [x] Step 2: Collaborative Backend (Socket.io + Yjs)
- [ ] Step 3: Dockerizing the Application (Frontend & Backend)
- [ ] Step 4: Introduction to AWS (S3, EC2)
- [ ] Step 5: CI/CD with GitHub Actions
- [ ] Step 6: Orchestration with Docker Compose
