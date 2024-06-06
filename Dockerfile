FROM fischerscode/flutter:latest as Frontend
USER root
COPY ./frontend .
RUN git config --global --add safe.directory /home/flutter/flutter-sdk
RUN flutter build web

FROM node:alpine
WORKDIR /app
COPY ./backend ./
RUN npm install
RUN npm run build
COPY --from=Frontend /home/flutter/build/web public
ENTRYPOINT npm start
