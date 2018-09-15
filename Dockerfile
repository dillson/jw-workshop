FROM node:8

WORKDIR /app

USER root

COPY package*.json /app

RUN npm install

COPY . /app

CMD [ "node", "index.js" ]

EXPOSE 8080
