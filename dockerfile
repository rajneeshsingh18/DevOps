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