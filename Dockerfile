FROM node:8

WORKDIR /

USER root

COPY package*.json ./

RUN npm install

COPY . .

CMD [ "node", "index.js" ]

EXPOSE 8080
