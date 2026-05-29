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

## 🛠 Step 3: Setting up Yjs in React Frontend

In this step, I connected the React frontend to the collaborative backend using **Yjs**, **y-socket.io**, and **y-monaco**.

### 1. Install Frontend Dependencies
```bash
npm install yjs y-socket.io y-monaco
```

### 2. Implementation in `App.jsx`
The frontend needs to initialize a Y.Doc, connect to the socket provider, and bind the Yjs text type to the Monaco Editor instance.

```jsx
import { Editor } from "@monaco-editor/react"
import { MonacoBinding } from "y-monaco"
import { useRef, useMemo } from "react"
import * as Y from "yjs"
import { SocketIOProvider } from "y-socket.io"

function App() {
  const editorRef = useRef(null)
  
  // 1. Initialize Y.Doc (persisted across renders)
  const ydoc = useMemo(() => new Y.Doc(), [])
  
  // 2. Define the shared text type
  const yText = useMemo(() => ydoc.getText("monaco"), [ydoc])

  const handleMount = (editor) => {
    editorRef.current = editor

    // 3. Initialize Socket.io Provider
    const provider = new SocketIOProvider("http://localhost:3000", "monaco", ydoc, {
      autoConnect: true,
    })

    // 4. Bind Yjs to Monaco Editor
    const monacoBinding = new MonacoBinding(
      yText,
      editorRef.current.getModel(),
      new Set([editor]),
      provider.awareness
    )
  }

  return (
    <main className="h-screen w-full bg-gray-950 flex gap-4">
      <section className="w-full bg-neutral-700 overflow-hidden">
        <Editor
          height="100%"
          defaultLanguage="javascript"
          theme="vs-dark"
          onMount={handleMount} // Critical: Connects Yjs on editor load
        />
      </section>
    </main>
  )
}
```

### 💡 Key Learning: `onMount` Connection
The synchronization logic must be placed inside the `onMount` handler of the `@monaco-editor/react` component. This ensures that the editor instance and its model are fully loaded before Yjs attempts to bind to them.

---

## 📅 Roadmap
- [x] Step 1: React + Tailwind CSS v4 + Monaco Editor Setup
- [x] Step 2: Collaborative Backend (Socket.io + Yjs)
- [x] Step 3: Frontend Yjs Integration
- [ ] Step 4: Dockerizing the Application (Frontend & Backend)
- [ ] Step 5: Introduction to AWS (S3, EC2)
- [ ] Step 6: CI/CD with GitHub Actions
- [ ] Step 7: Orchestration with Docker Compose
