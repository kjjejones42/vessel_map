import express from 'express';
import expressWs  from "express-ws";
import cors from 'cors';

import { UserRepository } from './repository';
import { IVessel } from './db';

const repo = new UserRepository()

const PORT = 3000

const app = expressWs(express()).app

app.ws('/api', (ws, _) => {
  const listener = (vessels: IVessel[]) => ws.send(JSON.stringify(vessels))
  repo.addListener(listener);
  repo.readAll().then(data => listener(data))
  ws.on('message', () => {})
  ws.on('close', () => repo.removeListener(listener));
})

app.use(cors())
app.use(express.static("public"))
app.use(express.json())
app.use(express.urlencoded({extended: true}))

app.get('/api', async (_, res) => {
  const data = await repo.readAll()
  res.json(data)
})

app.patch('/api', async (req, res) => {
  try {
    const status = await repo.update(req.body as IVessel)
    res.json(status)
  } catch (error) {
    res.status(400).json(error);
  }
})

app.post('/api', async (req, res) => {
  try {
    const status = await repo.create(req.body as IVessel)
    res.json(status)
  } catch (error) {
    res.status(400).json(error);
  }
})

app.delete('/api', async (req, res) => {
  try {
    const params = req.body as {id: number};
    const status = await repo.remove(params.id)
    res.json(status)
  } catch (error) {
    res.status(400).json(error);
  }  
})

app.listen(PORT, () => {
  console.log(`Server running at http://localhost:${PORT}`);
});