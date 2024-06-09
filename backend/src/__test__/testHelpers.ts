import { IVessel } from "../db"

// Utility Jest functions to compare two lists of vessels and raise error if they don't match.

export function expectVesselsMatch(actual: IVessel[], expected: IVessel[]) {
  expect(actual.length).toEqual(expected.length)
  for (let i = 0; i < actual.length; i++) {
    expectVesselMatches(expected[i], actual[i])
  }
}

export function expectVesselMatches(actual: IVessel, expected: IVessel) {
  expect(actual.name).toEqual(expected.name)
  expect(actual.latitude).toEqual(expected.latitude)
  expect(actual.longitude).toEqual(expected.longitude)
}
