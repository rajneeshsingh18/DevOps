# Docker + AWS Learning Journey 🚀

This repository documents my step-by-step progress in mastering **Docker** and **AWS**, starting from frontend setup to full-scale deployment.

---

## 🛠 Step 1: Setting up React + Tailwind CSS (Vite)

As a beginner, the first step was setting up a modern frontend environment using Vite and Tailwind CSS.

### 1. Create the React Project
If you haven't already, create a new Vite project:
```bash
npm create vite@latest frontend -- --template react
cd frontend
npm install
```

### 2. Install Tailwind CSS
Install Tailwind and its peer dependencies via npm:
```bash
npm install -D tailwindcss postcss autoprefixer
npx tailwindcss init -p
```
This creates `tailwind.config.js` and `postcss.config.js`.

### 3. Configure Template Paths
Update `tailwind.config.js` to include all your component files:
```javascript
/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {},
  },
  plugins: [],
}
```

### 4. Add Tailwind Directives to CSS
Open `./src/index.css` (or `App.css`) and replace its content with:
```css
@tailwind base;
@tailwind components;
@tailwind utilities;
```

### 5. Verify Installation
Use a Tailwind class in `App.jsx` to test:
```jsx
function App() {
  return (
    <h1 className="text-3xl font-bold underline text-blue-600">
      Hello Tailwind!
    </h1>
  )
}
```

### 6. Run the Development Server
```bash
npm run dev
```

---

## 📅 Roadmap
- [x] Step 1: React + Tailwind CSS Setup
- [ ] Step 2: Dockerizing the Frontend
- [ ] Step 3: Introduction to AWS (S3, EC2)
- [ ] Step 4: CI/CD with GitHub Actions
- [ ] Step 5: Orchestration with Docker Compose
