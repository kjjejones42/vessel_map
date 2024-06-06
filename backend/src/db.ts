
import mysql from 'mysql2'
import { RowDataPacket } from "mysql2"

export const connection = mysql.createConnection({
  host: 'db',
  user: 'user',
  password: 'password',
  database: 'my-db'
})

export interface IVessel extends RowDataPacket {
  id?: number
  name: string
  latitude: number,
  longitude: number,
  updated_at: Date
}

const CREATE = `CREATE TABLE IF NOT EXISTS vessels (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  latitude DOUBLE NOT NULL,
  longitude DOUBLE NOT NULL,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);`

connection.query(CREATE)