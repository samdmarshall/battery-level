import bitops
import winim/lean

import "protocol.nim"

proc getBatteries*(): seq[Battery] =
  var data: LPSYSTEM_POWER_STATUS
  GetSystemPowerStatus(data)
  result = @[Battery(percentage: data.BatteryLifePercent, isCharging: data.BatteryFlag.testBit(4))]
