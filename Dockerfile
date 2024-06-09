FROM fischerscode/flutter:master as Frontend
USER root
COPY ./frontend .
RUN git config --global --add safe.directory /home/flutter/flutter-sdk
RUN --mount=type=secret,id=apikey apikey=$(cat /run/secrets/apikey) && flutter build web --release --dart-define APIKEY=$apikey

FROM node:alpine
WORKDIR /app
COPY ./backend .
COPY --from=Frontend /home/flutter/build/web public
RUN npm install
RUN npm run build
ENTRYPOINT npm start
