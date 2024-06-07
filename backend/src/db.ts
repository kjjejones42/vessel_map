
import mysql from 'mysql2'
import { RowDataPacket } from "mysql2"

export const pool = mysql.createPool({
  host: 'db',
  user: process.env.MYSQL_USER,
  password: process.env.MYSQL_PASSWORD,
  database: process.env.MYSQL_DATABASE  
})

export interface IVessel extends RowDataPacket {
  id: number
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

pool.query(CREATE)