FROM fischerscode/flutter:latest as Frontend
USER root
COPY ./frontend .
RUN git config --global --add safe.directory /home/flutter/flutter-sdk
ARG APIKEY
RUN flutter build web --dart-define APIKEY=${APIKEY}

FROM node:alpine
WORKDIR /app
COPY ./backend .
COPY --from=Frontend /home/flutter/build/web public
RUN npm install
RUN npm run build
ENTRYPOINT npm start
