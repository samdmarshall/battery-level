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

# ===========
# Entry Point
# ===========

var passed_index: cint = -1
for kind, key, value in parseopt2.getopt():
  case kind
  of cmdLongOption, cmdShortOption:
    case key
    of "index", "i":
      if value.len > 0:
        passed_index = cast[cint](strutils.parseInt(value))
    of "default", "d":
      passed_index = 0
    else: discard
  else: discard

let blob = IOPSCopyPowerSourcesInfo()
let sources = IOPSCopyPowerSourcesList(blob)
var index: cint = 0
let source_array_length = CFArrayGetCount(sources)

if passed_index == -1:
  echo(repr(source_array_length) & " source(s)")
else:
  while index < source_array_length:
    if passed_index == index:
      let source = CFArrayGetValueAtIndex(sources, index)
      let source_description = IOPSGetPowerSourceDescription(blob, source)
      let current_capacity_cfstr = CFStringCreateWithCString(nil, "Current Capacity", 0x08000100'i64)
      let capacity_value = CFDictionaryGetValue(source_description, current_capacity_cfstr)
      var battery: cint
      CFNumberGetValue(capacity_value, 9'i64, addr battery) 
      echo(repr(battery))
    index += 1
CFRelease(sources)
CFRelease(blob)
