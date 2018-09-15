FROM node:8

RUN mkdir /app

WORKDIR /app

USER root

COPY package*.json /app/

RUN npm install --silent

COPY . /app

CMD [ "node", "index.js" ]

EXPOSE 8080
