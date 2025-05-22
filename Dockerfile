#### Step 1 ####
FROM node:23.11.1-alpine3.21 as linter

WORKDIR /home/node/app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm test
RUN npm run lint

#### Step 2 ####
FROM node:23.11.1-alpine3.21 as production-builder

WORKDIR /home/node/app
COPY package*.json ./
RUN npm install --production

#### Step 3 ####
FROM node:23.11.1-alpine3.21 as app

ENV GOOGLE_HOME_KODI_CONFIG="/config/kodi-hosts.config.js"
ENV NODE_ENV=production
ENV PORT=8099

VOLUME /config
WORKDIR /home/node/app

RUN apk add --no-cache tini
COPY --from=production-builder /home/node/app/node_modules ./node_modules
COPY . .

USER node
EXPOSE 8099
ENTRYPOINT ["/sbin/tini", "--"]
CMD ["node", "server.js"]
