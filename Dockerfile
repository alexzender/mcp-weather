FROM node:22.12-alpine AS builder

RUN npm install -g typescript

RUN mkdir /app
RUN mkdir /app/build
COPY . /app/

RUN set -x && echo "=== Listing contents of /app ===" && ls -al /app


WORKDIR /app

RUN --mount=type=cache,target=/root/.npm npm install

RUN --mount=type=cache,target=/root/.npm npm run build

FROM node:22-alpine AS release

WORKDIR /app

COPY --from=builder /app/build /app/build
COPY --from=builder /app/package.json /app/package.json
COPY --from=builder /app/package-lock.json /app/package-lock.json

ENV NODE_ENV=production

RUN npm ci --ignore-scripts --omit-dev

CMD ["node", "/app/build/index.js"]