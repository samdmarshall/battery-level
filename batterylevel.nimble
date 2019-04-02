# Package

version       = "0.5.0"
author        = "Samantha Demi"
description   = "utility for checking current battery level on a system"
license       = "BSD-3-Clause"
srcDir        = "src"
bin           = @["batterylevel"]


# Dependencies

requires "nim >= 0.18.0"

when defined(nimdistros):
  import distros
  if detectOs(Windows):
    requires "winim"
