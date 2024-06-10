# Building

The most reliable method of building the app is with Docker, however this can be slow since Docker needs to download the Flutter SDK. If the Flutter SDK is already installed on your system the manual build may be faster.

## Docker Build Instructions

Use `docker compose up --build` to build and run the project.

If this doesn't work try:

```
$ docker build -t app --secret id=apikey,env=APIKEY . 
$ docker run -it -v app_database:/app/db -p 3000:3000 app
```
These will build the app docker image, and serve it at `http://localhost:3000`.

## Manual Build Instructions

If you have the Flutter SDL installed locally then run the following commands from the base `app` directory. Replace `$APIKEY` with your Google Maps API key.

```
$ cd frontend
$ flutter build web --dart-define apikey=$APIKEY
$ cd ../backend
$ mkdir public
$ cp -r -f ../frontend/build/web/* public
$ npm install
$ npm start
```