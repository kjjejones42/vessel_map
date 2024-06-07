import { ResultSetHeader } from "mysql2"

import { IVessel, pool } from "./db"

export class UserRepository {

  _subscribers: ((x: IVessel[]) => void)[] = []

  addListener(func: ((x: IVessel[]) => void)) {
    this._subscribers.push(func)
  }

  removeListener(func: ((x: IVessel[]) => void)) {
    const index = this._subscribers.indexOf(func);
    if (index != -1)
      this._subscribers.splice(index)
  }

  _notifyListeners() {
    this.findAll().then(data => {
      this._subscribers.forEach(func => func(data))
    })
  }

  findAll(): Promise<IVessel[]> {
    return new Promise((resolve, reject) => {
      pool.query<IVessel[]>("SELECT * FROM vessels", (err, res) => {
        if (err) reject(err)
        else resolve(res)
      })
    })
  }

  findById(user_id: number): Promise<IVessel | undefined> {
    return new Promise((resolve, reject) => {
      pool.query<IVessel[]>(
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
      pool.query<ResultSetHeader>(
        "INSERT INTO vessels (name, latitude, longitude) VALUES(?,?,?)",
        [vessel.name, vessel.latitude, vessel.longitude],
        (err, res) => {
          if (err) reject(err)
          else
            this.findById(res.insertId)
              .then(user => resolve(user!))
              .then(() => this._notifyListeners())
              .catch(reject)
        }
      )
    })
  }

  update(vessel: IVessel): Promise<IVessel | undefined> {
    return new Promise((resolve, reject) => {
      pool.query<ResultSetHeader>(
        "UPDATE vessels SET name = ?, latitude = ?, longitude = ? WHERE id = ?",
        [vessel.name, vessel.latitude, vessel.longitude, vessel.id],
        (err, _) => {
          if (err) reject(err)
          else
            this.findById(vessel.id)
              .then(resolve)
              .then(() => this._notifyListeners())
              .catch(reject)
        }
      )
    })
  }

  remove(user_id: number): Promise<number> {
    return new Promise((resolve, reject) => {
      pool.query<ResultSetHeader>(
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