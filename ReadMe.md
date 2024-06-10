# Vessel Map

A web application created with Flutter and node.js to show the locations of leased vehicles, with real time updates.

The latest version of this app can be seen at https://vesselmap.fly.dev/.

## Features
- Interactive Google Map display.
- Search and sort functionality of listed vessels.
- Create, read, update and delete vessels from the database from the brower.
- Real-time updates to all users via Websockets.
- Dynamic web design which accommodates both desktop and mobile browsers.
- Both dark and light theming.

## Building

The most reliable method of building the app is with Docker, however this can be slow since Docker needs to download the Flutter SDK. If the Flutter SDK and Node.js is already installed on your system the manual build may be faster. All these commands will serve the app at `http://localhost:3000`.

### Docker Build Instructions

Use `docker compose up --build` to build and run the project.

If this doesn't work try to set up the docker image manually with:

```
$ docker build -t app --secret id=apikey,env=APIKEY . 
$ docker run -it -v app_database:/app/db -p 3000:3000 app
```

### Manual Build Instructions

If you have the Flutter SDK and Node.js installed locally then run the following commands from the base `app` directory. Replace `$APIKEY` with your Google Maps API key.

```
$ cd frontend
$ flutter build web --dart-define apikey=$APIKEY
$ cd ../backend
$ mkdir public
$ cp -r -f ../frontend/build/web/* public
$ npm install
$ npm build
$ npm run server
```