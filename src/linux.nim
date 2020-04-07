import os
import streams
import strutils

import "protocol.nim"

const
  Prefix = "/sys/class/power_supply"

proc readAll(path: string): string =
  try:
    let s = openFileStream(path)
    result = s.readAll().strip()
    s.close()
  except:
    result = ""

proc getBatteries*(): seq[Battery] =
  result = newSeq[Battery]()
  for _, entry in walkDir(Prefix):
    let ptype = readAll(entry / "type")
    case ptype
    of "Battery":
      let percentage = readAll(entry / "capacity").parseInt()
      let state = readAll(entry / "status")
      if (percentage >= 0 and percentage <= 100) and (state.len > 0):
        let batt = Battery(percentage: percentage, isCharging: (state == "Charging"))
        result.add(batt)
    else: discard
