import assert, { AssertionError } from 'assert';
import { Database } from 'sqlite3'

export interface IVessel {
  id?: number
  name: string
  latitude: number,
  longitude: number,
  updated_at?: string
}

/**
 * Assert that the passed object implements the IVessel interface.
 */
export function validateVessel(vessel: any) {
  try {
    assert('name' in vessel && typeof vessel.name == "string");
    assert('latitude' in vessel && typeof vessel.latitude == "number");
    assert('longitude' in vessel && typeof vessel.latitude == "number");
    assert('id' in vessel ? typeof vessel.id == 'number' : true)
    assert('updated_at' in vessel ? typeof vessel.updated_at == 'string' : true)
  } catch (e) {
    throw new TypeError(`${JSON.stringify(vessel)} is not a valid vessel type.`)
  }
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