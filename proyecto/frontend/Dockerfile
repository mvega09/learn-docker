# Stage 1: build with Node
FROM node:22-alpine AS build
WORKDIR /app

# no copiar node_modules - .dockerignore lo evita
COPY package*.json ./
# install deps (use npm ci for reproducibilidad)
RUN npm ci

# copy all source
COPY . .

# build (Vite)
ARG VITE_API_URL
ENV VITE_API_URL=${VITE_API_URL:-https://learn-docker-zxf3.onrender.com}
RUN npm run build

# Stage 2: serve with nginx
FROM nginx:stable-alpine
# remove default config
RUN rm /etc/nginx/conf.d/default.conf

# copy custom nginx config
COPY nginx.conf /etc/nginx/conf.d/default.conf

# copy built files (Vite outputs to /app/dist)
COPY --from=build /app/dist /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
