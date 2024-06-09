import { Database } from 'sqlite3'

export interface IVessel {
  id?: number
  name: string
  latitude: number,
  longitude: number,
  updated_at?: string
}

export const initDatabase = async (filename: string) => {
  const db = new Database(filename)

  const tableCreateStatement = `CREATE TABLE IF NOT EXISTS vessels (
    id INTEGER PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    latitude DOUBLE NOT NULL,
    longitude DOUBLE NOT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
  );`

  // Create 'vessels' table on initialisation if doesn't already exist
  await new Promise<void>((resolve, reject) => {
    db.run(tableCreateStatement, error => error ? reject(error) : resolve())
  });

  return db;
}