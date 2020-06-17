
import "protocol.nim"

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

proc getBatteries*(): seq[Battery] =
  result = newSeq[Battery]()
  let blob = IOPSCopyPowerSourcesInfo()
  let sources = IOPSCopyPowerSourcesList(blob)
  var index: cint = 0
  let source_array_length = CFArrayGetCount(sources)
  while index < source_array_length:
    let source = CFArrayGetValueAtIndex(sources, index)
    let source_description = IOPSGetPowerSourceDescription(blob, source)
#   if get_charging_status: "Is Charging"

    let percentage_cfstr = CFStringCreateWithCString(nil, "Current Capacity", 0x08000100'i64)
    let percentage_value_cftype = CFDictionaryGetValue(source_description, percentage_cfstr)
    var percentage_real_value: cint
    CFNumberGetValue(percentage_value_cftype, 9'i64, addr percentage_real_value)

    let status_cfstr = CFStringCreateWithCString(nil, "Is Charging", 0x08000100'i64)
    let status_value_cftype = CFDictionaryGetValue(source_description, status_cfstr)
    var status_real_value: cint
    CFNumberGetValue(status_value_cftype, 9'i64, addr status_real_value)

    let batt = Battery(percentage: percentage_real_value, isCharging: status_real_value == 1)
    result.add(batt)

    inc(index)
  CFRelease(sources)
  CFRelease(blob)
