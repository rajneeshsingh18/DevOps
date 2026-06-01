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

## 🛠 Step 4: Multi-User Awareness (Presence Tracking)

In this step, I added **Presence Tracking** to show who else is in the room and see their cursors in real-time.

### 1. The Concept of "Awareness"
Yjs provides an **Awareness** protocol that allows users to share transient state (like mouse position, cursor selection, or usernames) without persisting it to the document.

### 2. Implementing User State
I used the `provider.awareness` object to set a local "user" state and listen for changes from other clients.

```javascript
// Set local user info
provider.awareness.setLocalStateField("user", { username: "John Doe" });

// Listen for updates from others
provider.awareness.on("change", () => {
  const states = Array.from(provider.awareness.getStates().values());
  const activeUsers = states
    .filter(state => state.user)
    .map(state => state.user);
  
  setUsers(activeUsers); // Update React state to show user list
});
```

### 3. Integrated implementation in `App.jsx`
The updated `App.jsx` now includes a "Join" screen and a sidebar to list active collaborators:

```jsx
function App() {
  const [username, setUsername] = useState("");
  const [users, setUsers] = useState([]);
  const providerRef = useRef(null);

  useEffect(() => {
    if (username) {
      const provider = new SocketIOProvider("http://localhost:3000", "monaco", ydoc);
      providerRef.current = provider;

      // Broadcast username to others
      provider.awareness.setLocalStateField("user", { username });

      // Sync user list on change
      provider.awareness.on("change", () => {
        const states = Array.from(provider.awareness.getStates().values());
        setUsers(states.filter(s => s.user).map(s => s.user));
      });

      return () => provider.disconnect();
    }
  }, [username]);

  // handleMount then uses providerRef.current.awareness for MonacoBinding...
}
```

### 4. Key UI Features Added:
- **Join Screen**: A simple form to collect the user's name before entering the editor.
- **Active User Sidebar**: A dynamic list that updates in real-time whenever a user joins or leaves.
- **Remote Cursors**: Because `provider.awareness` is passed to `MonacoBinding`, users can now see each other's color-coded cursors.

---

## 🛠 Step 5: Introduction to Docker

In this step, I transitioned from local development to **Containerization**.

### ❓ Why use Docker?
Docker solves the "It works on my machine" problem by packaging code, runtime, system tools, and libraries into a single **container**.
- **Consistency**: The exact same environment runs on your laptop, your teammate's PC, and the AWS cloud.
- **Isolation**: Prevent dependency conflicts between different projects (e.g., Project A needs Node 14, Project B needs Node 20).
- **Scalability**: Containers can be spun up or down in seconds, making it easy to handle high traffic.

### 🪟 Installing Docker on Windows
1. **System Requirements**: Ensure you have Windows 10/11 Pro, Enterprise, or Home with **WSL2** enabled.
2. **Download**: Go to [Docker Desktop for Windows](https://www.docker.com/products/docker-desktop/) and download the installer.
3. **Install**: Run the `.exe` and ensure "Use WSL 2 instead of Hyper-V" is checked.
4. **Restart**: Your computer will likely need a restart to finalize WSL2 components.
5. **Verify**: Open PowerShell and type:
   ```bash
   docker --version
   docker run hello-world
   ```

### 🚢 Next Up: Creating Dockerfiles
To containerize our application, we need to create a instructions file for Docker:
- `frontend/Dockerfile`: For our React + Vite app.
- `backend/Dockerfile`: For our Node.js + Socket.io app.
- `.dockerignore`: To prevent heavy `node_modules` from being copied into the image.

---

## 🛠 Step 6: Multi-Stage Dockerization

In this step, I created a **Multi-Stage Dockerfile** to build the frontend and serve it via the backend in a single, optimized container.

### 1. The Multi-Stage Concept
Instead of having two separate containers, we use one Dockerfile with two `FROM` instructions:
- **Stage 1 (Build)**: Compiles the React frontend into static files (the `dist` folder).
- **Stage 2 (Runtime)**: Sets up the Node.js backend and copies the `dist` files into the backend's `public` folder.

### 2. The Optimized `Dockerfile`
```dockerfile
# --- Stage 1: Frontend Build ---
FROM node:20-alpine AS frontend-builder
WORKDIR /app
COPY ./frontend/package*.json ./
RUN npm install
COPY ./frontend .
RUN npm run build

# --- Stage 2: Backend Runtime ---
FROM node:20-alpine
WORKDIR /app
COPY ./backend/package*.json ./
RUN npm install
COPY ./backend .
# Copy built frontend assets from the builder stage
COPY --from=frontend-builder /app/dist /app/public

CMD ["node", "server.js"]
```

### 💡 Troubleshooting: Circular Dependencies
During this step, I learned that every `COPY --from=stage-name` requires that stage to be finished. If you forget the second `FROM` statement, Docker gets confused and thinks you are trying to copy from the current stage into itself, causing a **Circular Dependency Error**.

### 3. Build and Run Commands
To build the image:
```bash
docker build -t collaborative-editor .
```

To run the container:
```bash
docker run -p 3000:3000 collaborative-editor
```

---

## 📅 Roadmap
- [x] Step 1: React + Tailwind CSS v4 + Monaco Editor Setup
- [x] Step 2: Collaborative Backend (Socket.io + Yjs)
- [x] Step 3: Frontend Yjs Integration
- [x] Step 4: Multi-User Awareness & Presence
- [x] Step 5: Introduction to Docker & Installation
- [x] Step 6: Multi-Stage Dockerization
- [ ] Step 7: Introduction to AWS (S3, EC2)
- [ ] Step 8: CI/CD with GitHub Actions
- [ ] Step 9: Orchestration with Docker Compose
