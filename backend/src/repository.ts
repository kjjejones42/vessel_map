import { Database } from "sqlite3";

import { IVessel } from "./db"

export default class VesselRepository {

  db: Database;

  constructor(db: Database) {
    this.db = db;
  }

  /** 
  * List of listeners to notify whenever database is updated
  */
  listeners: ((_: IVessel[]) => void)[] = []

  addListener(listener: ((x: IVessel[]) => void)) {
    this.listeners.push(listener)
  }

  async closeDatabase() {
    this.db.close();
  }

  async notifyListeners() {
    const data = await this.findAll();
    this.listeners.forEach(listener => listener(data))
  }

  /**
   * @returns All vessel rows in database
   */
  async findAll(): Promise<IVessel[]> {
    return new Promise((resolve, reject) => {
      this.db.all("SELECT * FROM vessels", (error, response) => {
        error ? reject(error) : resolve(response as IVessel[])
      })
    })
  }

  /**
   * @returns The vessel row with the supplied id
   */
  async findById(id: number): Promise<IVessel | undefined> {
    return new Promise((resolve, reject) => {
      this.db.get(
        "SELECT * FROM vessels WHERE id = ?",
        [id],
        (error, response) => {
          error ? reject(error) : resolve(response as IVessel)
        }
      )
    })
  }

  /**
   * @returns The created vessel's database ID
   */
  async create(vessel: IVessel): Promise<number> {
    return new Promise((resolve, reject) => {
      const repo = this;
      const date = vessel.updated_at || new Date().toISOString()
      this.db.run(
        "INSERT INTO vessels (id, name, latitude, longitude, updated_at) VALUES(?,?,?,?,?)",
        [null, vessel.name, vessel.latitude, vessel.longitude, date],
        function (error) {
          if (error) {
            reject(error)
          } else {
            repo.notifyListeners()
            resolve(this.lastID)
          }
        }
      )
    })
  }
  /**
   * Updates the vessel with the supplied ID and details.
   * @returns The updated vessel details
   */
  async update(vessel: IVessel): Promise<IVessel | undefined> {
    return new Promise((resolve, reject) => {
      this.db.run(
        "UPDATE vessels SET name = ?, latitude = ?, longitude = ?, updated_at = ? WHERE id = ?",
        [vessel.name, vessel.latitude, vessel.longitude, new Date().toISOString(), vessel.id],
        async err => {
          if (err) reject(err)
          else {
            const updatedVessel = await this.findById(vessel.id!);
            resolve(updatedVessel)
            this.notifyListeners()
          }
        }
      )
    })
  }

  /**
   * Removes the vessel with the supplied ID
   * @returns 
   */
  async remove(id: number): Promise<void> {
    return new Promise((resolve, reject) => {
      this.db.all(
        "DELETE FROM vessels WHERE id = ?",
        [id],
        err => {
          if (err) {
            reject(err)
          } else {
            this.notifyListeners()
            resolve()
          }
        }
      )
    })
  }

  /**
   * Delete all vessels in database. This should only be used in testing.
   */
  async deleteAll() {
    return new Promise<void>((res, rej) => {
      this.db.run('DELETE FROM vessels', err =>
        err ? rej(err) : res())
    })

  }
}