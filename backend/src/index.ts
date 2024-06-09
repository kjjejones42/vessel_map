import VesselRepository from './repository'
import initialiseApp from './app'
import { initDatabase as initSqliteDatabase } from './db'
import initializeWebsocket from './websocket';

initSqliteDatabase('db/vessels.db').then(db => {

  const repository = new VesselRepository(db)

  const PORT = process.env.port ? parseInt(process.env.port) : 3000

  const app = initialiseApp(repository);

  const server = app.listen(PORT, () => {
    console.log(`Server running at http://localhost:${PORT}`)
  })

  initializeWebsocket(server, repository)

  process.on('SIGTERM', () => {
    console.debug('SIGTERM signal received: closing HTTP server')
    server.close(() => {
      console.debug('HTTP server closed')
      repository.closeDatabase()
    })
  })
});