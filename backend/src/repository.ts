import { ResultSetHeader  } from "mysql2"

import { IVessel, connection } from "./db"

export class UserRepository {

  _subscribers: ((x: IVessel[]) => void)[]  = []

  addListener(func: ((x: IVessel[]) => void)) {
    this._subscribers.push(func)    
  }

  removeListener(func: ((x: IVessel[]) => void)) {
    const index = this._subscribers.indexOf(func);
    if (index != -1)
      this._subscribers.splice(index)
  }

  async _notifyListeners() {
    const data = await this.readAll()
    this._subscribers.forEach(func => func(data))
  }
  
  readAll(): Promise<IVessel[]> {
    return new Promise((resolve, reject) => {
      connection.query<IVessel[]>("SELECT * FROM vessels", (err, res) => {
        if (err) reject(err)
        else resolve(res)
      })
    })
  }

  readById(user_id: number): Promise<IVessel | undefined> {
    return new Promise((resolve, reject) => {
      connection.query<IVessel[]>(
        "SELECT * FROM vessels WHERE id = ?",
        [user_id],
        (err, res) => {
          if (err) reject(err)
          else resolve(res?.[0])
        }
      )
    })
  }

  create(vessel: IVessel): Promise<IVessel> {
    return new Promise((resolve, reject) => {
      connection.query<ResultSetHeader >(
        "INSERT INTO vessels (name, latitude, longitude, updated_at) VALUES(?,?,?,?)",
        [vessel.name, vessel.latitude, vessel.longitude, new Date()],
        (err, res) => {
          if (err) reject(err)
          else 
            this.readById(res.insertId)
              .then(user => resolve(user!))
              .then(() => this._notifyListeners())
              .catch(reject)
        }
      )
    })
  }

  update(vessel: IVessel): Promise<IVessel | undefined> {
    return new Promise((resolve, reject) => {
      connection.query<ResultSetHeader >(
        "UPDATE vessels SET name = ?, latitude = ?, longitude = ?, updated_at = ? WHERE id = ?",
        [vessel.name, vessel.latitude, vessel.longitude, new Date(), vessel.id],
        (err, res) => {
          if (err) reject(err)
          else
            this.readById(vessel.id!)
              .then(resolve)
              .then(() => this._notifyListeners())
              .catch(reject)
        }
      )
    })
  }

  remove(user_id: number): Promise<number> {
    return new Promise((resolve, reject) => {
      connection.query<ResultSetHeader >(
        "DELETE FROM vessels WHERE id = ?",
        [user_id],
        (err, res) => {
          if (err) reject(err)
          else {
            resolve(res.affectedRows)
            this._notifyListeners()
          }
        }
      )
    })
  }
}