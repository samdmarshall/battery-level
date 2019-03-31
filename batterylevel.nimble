# Package

version       = "0.5.0"
author        = "Samantha Demi"
description   = "utility for checking current battery level on a system."
license       = "MIT"
srcDir        = "src/"
skipExt       = @["nim"]
bin           = @["batterylevel"]

# Dependencies

#requires "nimble >= 0.9.0"
requires "winim >= 2.6"

