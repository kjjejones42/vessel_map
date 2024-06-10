FROM fischerscode/flutter:master as Frontend
USER root
COPY ./frontend .
RUN git config --global --add safe.directory /home/flutter/flutter-sdk
RUN --mount=type=secret,id=apikey,required=true flutter build web --release --dart-define apikey=$(cat /run/secrets/apikey)

FROM node:alpine
WORKDIR /app
COPY ./backend .
RUN npm install
RUN npm run build
COPY --from=Frontend /home/flutter/build/web public
ENTRYPOINT npm run serve
