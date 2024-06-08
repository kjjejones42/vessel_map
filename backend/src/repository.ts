import { RunResult } from "sqlite3"
import { IVessel, db } from "./db"

export class UserRepository {

  _listeners: ((x: IVessel[]) => void)[] = []

  addListener(func: ((x: IVessel[]) => void)) {
    this._listeners.push(func)
  }

  _notifyListeners() {
    this.findAll().then(data => {
      this._listeners.forEach(func => func(data))
    })
  }

  findAll(): Promise<IVessel[]> {
    return new Promise((resolve, reject) => {
      db.all("SELECT * FROM vessels", (err, res) => {
        if (err) reject(err)
        else resolve(res as IVessel[])
      })
    })
  }

  findById(userId: number): Promise<IVessel | undefined> {
    return new Promise((resolve, reject) => {
      db.get(
        "SELECT * FROM vessels WHERE id = ?",
        [userId],
        (err, res) => {
          if (err) reject(err)
          else resolve(res as IVessel)
        }
      )
    })
  }

  create(vessel: IVessel): Promise<IVessel> {
    return new Promise((resolve, reject) => {
      const outerThis = this;
      db.run(
        "INSERT INTO vessels (id, name, latitude, longitude, updated_at) VALUES(?,?,?,?,?)",
        [null, vessel.name, vessel.latitude, vessel.longitude, new Date().toISOString()],
        function (err) {
          if (err) reject(err)
          else {
            outerThis.findById(this.lastID)
              .then(user => resolve(user!))
              .then(() => outerThis._notifyListeners())
              .catch(reject)
          }
        }
      )
    })
  }

  update(vessel: IVessel): Promise<IVessel | undefined> {
    return new Promise((resolve, reject) => {
      const outerThis = this;
      db.run(
        "UPDATE vessels SET name = ?, latitude = ?, longitude = ?, updated_at = ? WHERE id = ?",
        [vessel.name, vessel.latitude, vessel.longitude, new Date().toISOString(), vessel.id],
        function (err) {
          if (err) reject(err)
          else {
            outerThis.findById(this.lastID)
              .then(resolve)
              .then(() => outerThis._notifyListeners())
              .catch(reject)
          }
        }
      )
    })
  }

  remove(userId: number): Promise<number> {
    return new Promise((resolve, reject) => {
      const outerThis = this;
      db.all(
        "DELETE FROM vessels WHERE id = ?",
        [userId],
        function (err, res) {
          if (err) reject(err)
          else {
            resolve(res.length)
            outerThis._notifyListeners()
          }
        }
      )
    })
  }
}