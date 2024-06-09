import cors from "cors"
import express from "express"

import VesselRepository from "./repository"
import { IVessel } from "./db"

export default function initialiseApp(repo: VesselRepository) {

  const app = express()
    .use(express.json())
    .use(express.urlencoded({ extended: true }))
    .use(cors())
    .use(express.static('public'))

  // Retrieve all vessel details on GET request
  app.get('/api', async (_, res) => {
    const data = await repo.findAll()
    res.json(data)
  })

  // Add new vessel details on POST request
  app.post('/api', async (req, res) => {
    try {
      const status = await repo.create(req.body as IVessel)
      res.status(201).json(status)
    } catch (error) {
      res.status(400).json(error)
    }
  })


  // Update vessel details on PATCH request
  app.patch('/api', async (req, res) => {
    try {
      const status = await repo.update(req.body as IVessel)
      res.json(status)
    } catch (error) {
      res.status(400).json(error)
    }
  })

  // Delete vessel on DELETE request
  app.delete('/api', async (req, res) => {
    try {
      const params = req.body as { id: number }
      const status = await repo.remove(params.id)
      res.json(status)
    } catch (error) {
      res.status(400).json(error)
    }
  })

  return app;

}
