import os
import strutils
import parseopt2
import distros

proc progname(): string =
  result = os.extractFilename(os.getAppFilename())

proc usage(): void =
  let name = progName()
  let filler = repeat(" ", name.len)
  echo(name   & " [--version|-v]")
  echo(filler & " [--help|-h]")
  echo(filler & " [--list|-l] (this is 0-indexed; first source is index 0, second is 1, etc)")
  echo(filler & " [--index:# | -i:# ] [--charging|-c]")
  echo(filler & " [--default|-d] [--charging|-c]")
  quit(QuitSuccess)

proc versionInfo(): void =
  echo(progName() & " v0.4.1")
  quit(QuitSuccess)

# ===========
# Entry Point
# ===========

var show_sources = false
var get_charging_status = false
var passed_index: cint = -1
for kind, key, value in parseopt2.getopt():
  case kind
  of cmdLongOption, cmdShortOption:
    case key
    of "index", "i":
      if value.len > 0:
        passed_index = cast[cint](strutils.parseInt(value))
    of "charging", "c":
      get_charging_status = true 
    of "default", "d":
      passed_index = 0
    of "list", "l":
      show_sources = true
    of "help", "h":
      usage()
    of "version", "v":
      versionInfo()
    else:
      discard
  else:
    discard

when defined(macosx):
  include "./darwin.nim"
  let blob = IOPSCopyPowerSourcesInfo()
  let sources = IOPSCopyPowerSourcesList(blob)
  var index: cint = 0
  let source_array_length = CFArrayGetCount(sources)
  
  if show_sources:
    echo(repr(source_array_length))
  elif  passed_index == -1:
    usage()
  else:
    while index < source_array_length:
      if passed_index == index:
        let source = CFArrayGetValueAtIndex(sources, index)
        let source_description = IOPSGetPowerSourceDescription(blob, source)
        var key_string: cstring
        if get_charging_status:
          key_string = "Is Charging"
        else:
          key_string = "Current Capacity"
        let key_cfstr = CFStringCreateWithCString(nil, key_string, 0x08000100'i64)
        let value_cftype = CFDictionaryGetValue(source_description, key_cfstr)
        var real_value: cint
        CFNumberGetValue(value_cftype, 9'i64, addr real_value) 
        echo(repr(real_value))
      index += 1
  CFRelease(sources)
  CFRelease(blob)
else:
  var file: File
  if get_charging_status:
    if open(file, "/sys/class/power_supply/battery/status"):
      try:
        let state = readLine(file)
        if state == "Charging":
          echo("1")
        else:
          echo("0")
      except:
        echo("failed to open file :(")
      finally:
        close(file)
  else:
    if open(file, "/sys/class/power_supply/battery/capacity"):
      try:
        let charge = readLine(file)
        echo $charge
      except:
        echo("failed to open file :(")
      finally:
        close(file)