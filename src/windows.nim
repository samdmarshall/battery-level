
{.passC: "-d:lean" .}
import winim/lean

var data: LPSYSTEM_POWER_STATUS
GetSystemPowerStatus(data)
echo data.BatteryLifePercent
