import { Database } from 'sqlite3'

export const db = new Database('db/vessels.db');

export interface IVessel {
  id?: number
  name: string
  latitude: number,
  longitude: number,
  updated_at?: Date
}

const CREATE = `CREATE TABLE IF NOT EXISTS vessels (
  id INTEGER PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  latitude DOUBLE NOT NULL,
  longitude DOUBLE NOT NULL,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);`

db.run(CREATE)