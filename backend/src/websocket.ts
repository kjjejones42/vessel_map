import http from "http"
import { Server } from "ws"

import VesselRepository from "./repository"

export default function initializeWebsocket(server: http.Server, repository: VesselRepository) {

  const websocketServer = new Server({ server: server, path: '/api' })

  // On websocket connection, send details of all vessels.
  websocketServer.on('connection', async ws => {
    const data = await repository.findAll();
    ws.send(JSON.stringify(data))
  })

  // When the database changes, rebroadcast all vessel details to all connected clients
  repository.addListener(vessels => {
    websocketServer.clients.forEach(client => {
      client.send(JSON.stringify(vessels))
    })
  })
}