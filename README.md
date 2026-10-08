# Professional Web Project Setup

This workspace has been configured with an industry-standard modern web development stack.

---

## 🛠️ Installed Tools & Toolchain

| Tool              | Version    | Purpose                                                |
| :---------------- | :--------- | :----------------------------------------------------- |
| **Node.js (LTS)** | `v24.20.0` | JavaScript runtime powering all modern tooling         |
| **npm**           | `11.19.0`  | Node Package Manager for dependencies                  |
| **Git**           | `2.48.1`   | Version control for tracking revisions & collaboration |
| **Vite**          | `8.3.4`    | Ultra-fast development server & production bundler     |
| **Prettier**      | `3.9.9`    | Automated code formatting engine                       |

---

## 🚀 Available Commands

Run these commands in your terminal:

```bash
# Start local live development server with Hot Module Replacement (instant preview)
npm run dev

# Build and optimize the site for production into the /dist folder
npm run build

# Preview the production build locally
npm run preview

# Automatically format all code (HTML, CSS, JS, JSON)
npm run format
```

---

## 📁 Project Structure

```text
├── .git/               # Git version control repository
├── .gitignore          # Ignores node_modules, dist, secrets, etc.
├── .prettierrc         # Code style & formatting rules
├── index.html          # Main application / website page
├── package.json        # Project metadata and npm scripts
├── package-lock.json   # Exact dependency locks
└── dist/               # Production build output (generated via npm run build)
```

---

## 🌐 Deploying Your Website

Your project is ready to deploy on any modern hosting platform:

- **Vercel**: Import repository or run `npx vercel`
- **Netlify**: Drag-and-drop the `dist` folder or connect Git
- **GitHub Pages**: Push your code to GitHub and publish
