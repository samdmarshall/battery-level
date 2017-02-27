import os
import strutils
import parseopt2

{.passL: "-framework IOKit -framework CoreFoundation".}

type
  CFTypeRef = ptr object
  CFArrayRef = CFTypeRef
  CFDictionaryRef = CFTypeRef
  CFAllocatorRef = CFTypeRef
  CFStringRef = CFTypeRef

proc IOPSCopyPowerSourcesInfo(): CFTypeRef {.importc.}
proc IOPSCopyPowerSourcesList(blob: CFTypeRef): CFArrayRef {.importc.}
proc IOPSGetPowerSourceDescription(blob: CFTypeRef, item: CFTypeRef): CFDictionaryRef {.importc.}

proc CFArrayGetValueAtIndex(array: CFArrayRef, index: cint): CFTypeRef {.importc.}
proc CFArrayGetCount(array: CFArrayRef): cint {.importc.}
proc CFStringCreateWithCString(alloc: CFAllocatorRef, string: cstring, encoding: int64): CFStringRef {.importc.}
proc CFDictionaryGetValue(dict: CFDictionaryRef, key: CFStringRef): CFTypeRef {.importc.}
proc CFNumberGetValue(number: CFTypeRef, num_type: int64, value: ptr cint): void {.importc.}

proc CFRelease(item: CFTypeRef): void {.importc.}

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

let blob = IOPSCopyPowerSourcesInfo()
let sources = IOPSCopyPowerSourcesList(blob)
var index: cint = 0
let source_array_length = CFArrayGetCount(sources)

if show_sources:
  echo(repr(source_array_length))
elif passed_index == -1:
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
