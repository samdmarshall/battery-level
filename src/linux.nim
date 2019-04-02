
const
  Prefix = "/sys/class/power_supply"

proc readAll(path: string): string =
  try:
    let s = openFileStream(path)
    result = s.readAll()
    s.close()
  except:
    result = ""

proc getBatteries(): seq[Battery] =
  result = newSeq[Battery]()
  for _, entry in walkDir(Prefix):
    case readAll(entry / "type")
    of "Battery":
      let percentage = readAll(entry / "capacity").parseInt()
      let state = readAll(entry / "status")
      if (percentage > 0 and percentage <= 100) and (state.len > 0):
        result.add(Battery(percentage, state == "Charging"))

