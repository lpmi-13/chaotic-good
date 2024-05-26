FROM node:20.13.1-bookworm-slim

WORKDIR /app

COPY package.json .

RUN npm install

COPY tsconfig.json src .

RUN npm run build

EXPOSE 8001

ENV PORT=8001
ENV ENVIRONMENT=production

CMD ["node", "index.js"]
