import request from 'supertest'
import { Application } from 'express';

import { expectVesselMatches, expectVesselsMatch } from './testHelpers';
import { initDatabase, IVessel } from '../db';
import VesselRepository from '../repository';
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

// Populate database before each test
beforeEach(async () => {
  for (const vessel of initialVessels) {
    await repository.create(vessel)
  }
})

// Clear database before each test
afterEach(async () => await repository.deleteAll())

afterAll(() => repository.closeDatabase())


describe('http api tests', () => {

  // Expects api GET request to return all vessels in database
  test('get api', async () => {
    const res = await request(app).get('/api').expect(200)
    const data: IVessel[] = JSON.parse(res.text)
    expectVesselsMatch(initialVessels, data)
  })

  // Expects api POST request to add vessel to database
  test('post api', async () => {
    const origVessels = await repository.findAll();
    await request(app)
      .post('/api')
      .send(newVessel)
      .expect(201);
    const allData = await repository.findAll();
    expectVesselsMatch(allData, [...origVessels, newVessel])
  })

  // Expects api PATCH request to edit existing vessel with supplied id
  test('patch api', async () => {
    const res = await request(app).patch('/api')
      .send({ id: 1, ...newVessel })
      .expect(200)

    // Expects PATCH request to return the edited vessel details
    expectVesselMatches(newVessel, JSON.parse(res.text))
    const allData = await repository.findAll();
    expectVesselsMatch(allData, [newVessel, ...initialVessels.slice(1)])
  })

  // Expects api DELETE request to remove vessel with supplied id
  test('delete api', async () => {
    await repository.create(newVessel)
    await request(app).delete('/api').send({ id: 3 }).expect(200)
    const allData = await repository.findAll()
    expectVesselsMatch(allData, initialVessels)
  })

})
