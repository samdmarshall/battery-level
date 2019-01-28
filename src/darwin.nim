
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

