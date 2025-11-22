FROM node:18-alpine

WORKDIR /app

# copy package files first for caching
COPY package.json package-lock.json* ./

RUN npm install --production || true

# copy application source
COPY . .

ENV PORT=3001
EXPOSE 3001

CMD ["npm", "start"]
