import express from 'express'
import expressWs from 'express-ws'
import cors from 'cors'

import { UserRepository } from './repository'
import { type IVessel, pool } from './db'

const repo = new UserRepository()

const PORT = 3000

const appWs = expressWs(express())
const app = appWs.app

app.ws('/api', (ws) => {
  repo.findAll().then(data => { ws.send(JSON.stringify(data)) })
})

repo.addListener(vessels => {
  appWs.getWss().clients.forEach(client => { client.send(JSON.stringify(vessels)) })
})

app.use(cors())
app.use(express.static('public'))
app.use(express.json())
app.use(express.urlencoded({ extended: true }))

app.get('/api', async (_, res) => {
  const data = await repo.findAll()
  res.json(data)
})

app.patch('/api', async (req, res) => {
  try {
    const status = await repo.update(req.body as IVessel)
    res.json(status)
  } catch (error) {
    res.status(400).json(error)
  }
})

app.post('/api', async (req, res) => {
  try {
    const status = await repo.create(req.body as IVessel)
    res.json(status)
  } catch (error) {
    res.status(400).json(error)
  }
})

app.delete('/api', async (req, res) => {
  try {
    const params = req.body as { id: number }
    const status = await repo.remove(params.id)
    res.json(status)
  } catch (error) {
    res.status(400).json(error)
  }
})

const server = app.listen(PORT, () => {
  console.log(`Server running at http://localhost:${PORT}`)
})

process.on('SIGTERM', () => {
  console.debug('SIGTERM signal received: closing HTTP server')
  server.close(() => {
    console.debug('HTTP server closed')
    pool.end()
  })
})
