import WebSocket from 'ws';
import { Server } from 'http';
import { AddressInfo } from 'net';
import { Application } from 'express';

import initWebsocketServer from '../websocket';
import { expectVesselsMatch } from './testHelpers';
import VesselRepository from '../repository';
import { initDatabase, IVessel } from '../db';
import initialiseApp from '../app';


const initialVessels: IVessel[] = [
  { name: 'Enterprise', latitude: 1, longitude: 2 },
  { name: 'Belfast', latitude: 3, longitude: 4 }
]
const newVessel: IVessel = { name: "Voyager", latitude: 5, longitude: 6 }

let app: Application
let repository: VesselRepository

beforeAll(async () => {
  const db = await initDatabase(':memory:')
  repository = new VesselRepository(db)
  app = initialiseApp(repository)
})

beforeEach(async () => {
  for (const vessel of initialVessels) {
    await repository.create(vessel)
  }
})

afterEach(async () => await repository.deleteAll())

afterAll(() => repository.closeDatabase())

describe('websocket tests', () => {

  let server: Server;
  let port = 0

  function initWebSocket() {
    return new WebSocket(`ws://localhost:${port}/api`)
  }

  /**
   * Return the next message string sent to the supplied websocket.
   */
  function getNextMessage(client: WebSocket) {
    return new Promise<string>(async res =>
      client.addEventListener(
        'message',
        msg => res(msg.data.toString()),
        { once: true }
      )
    )
  }

  /**
   * Utility function which sets up 10 websocket clients, then runs the supplied function and
   * expects the clients to receive a message with the current database state. Will then test
   * this actual state against the supplied expected state.   
   */
  async function testBroadcast(promiseFunction: () => Promise<any>, expectedTableState: IVessel[],) {
    const clients = [...Array(10).keys()].map(() => initWebSocket())
    await Promise.all(clients.map(getNextMessage))
    const results = await Promise.all([promiseFunction(), ...clients.map(getNextMessage)])
    const messages = results.slice(1)
    messages.forEach(msg => {
      expectVesselsMatch(JSON.parse(msg), expectedTableState)
    })
    clients.forEach(client => {
      client.close()
    })
  }

  beforeAll(() => {
    server = app.listen(port)
    port = (server.address() as AddressInfo).port;
    initWebsocketServer(server, repository)
  })

  // Create a websocket, connect to the server, expect the current database state to be sent as an initial response.
  test('websocket connect', async () => {
    const client = initWebSocket()
    const msg = await getNextMessage(client)
    const allData = await repository.findAll()
    expectVesselsMatch(JSON.parse(msg), allData)
    client.close()
  })

  // Expect the websocket server to send a broadcast whenever the database is updated.

  test('websocket create broadcast', async () => {
    const expectedMsg = [...initialVessels, newVessel]
    await testBroadcast(() => repository.create(newVessel), expectedMsg)
  })

  test('websocket delete broadcast', async () => {
    const expectedMsg = initialVessels.slice(1)
    await testBroadcast(() => repository.remove(1), expectedMsg)
  })

  test('websocket edit broadcast', async () => {
    const expectedMsg = [newVessel, ...initialVessels.slice(1)]
    await testBroadcast(() => repository.update({ ...newVessel, id: 1 }), expectedMsg)
  })

  afterAll(() => server.close())

})