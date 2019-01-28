# Package

version       = "0.1.0"
author        = "Anonymous"
description   = "utility for checking current battery level on a system"
license       = "MIT"
srcDir        = "src"
bin           = @["battery_level"]
skipFiles = @["darwin.nim", "wsl.nim"]

# Dependencies

requires "nim >= 0.18.0"

when defined(nimdistro):
  import distros
  if detectOs(Windows):
    foriegnDep winim
