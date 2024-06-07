FROM fischerscode/flutter:latest as Frontend
USER root
COPY ./frontend .
RUN git config --global --add safe.directory /home/flutter/flutter-sdk
ARG APIKEY
ARG PORT
RUN flutter build web --dart-define PORT=${PORT} --dart-define APIKEY=${APIKEY}

FROM node:alpine
WORKDIR /app
COPY ./backend ./
ARG MYSQL_DATABASE
ARG MYSQL_USER
ARG MYSQL_PASSWORD
ENV MYSQL_DATABASE=${MYSQL_DATABASE}
ENV MYSQL_USER=${MYSQL_USER}
ENV MYSQL_PASSWORD=${MYSQL_PASSWORD}
RUN npm install
RUN npm run build
COPY --from=Frontend /home/flutter/build/web public
ENTRYPOINT npm start
