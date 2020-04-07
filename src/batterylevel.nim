# =======
# Imports
# =======

import os
import hashes
import tables
import macros
import parseopt
import sequtils
import strutils
import terminal

import "protocol.nim"

when defined(windows):
  import "windows.nim"
when defined(macosx):
  import "macosx.nim"
when defined(linux):
  import "linux.nim"

# =====
# Types
# =====

const
  AppName    = "batterylevel"
  NimblePkgVersion  {.strdefine.} = ""

type
  Action = enum
    Color   = ('c', "color"),
    Default = ('d', "default"),
    Help    = ('h', "help"),
    Index   = ('i', "index"),
    List    = ('l', "list"),
    Status  = ('s', "status"),
    Version = ('v', "version")

# =========
# Functions 
# =========


#
#
proc hash(x: Action): Hash =
  result = hash($x)

#
#
proc main() =
  var state = initOrderedTable[Action, string]()
  var parser = initOptParser()
  for kind, key, value in parser.getopt():
    case kind
    of cmdShortOption, cmdLongOption:
      try:
        let property: Action = parseEnum[Action](key)
        state[property] = value
      except: discard
    else: discard

  let commands = toSeq(state.keys())
  for key in commands:
    case key
    of Version:
      echo(AppName & " v" & NimblePkgVersion)
      break
    of Help:
      echo(AppName & "\n" &
        "\t -v  , --version  Display Version \n" &
        "\t -h  , --help     Display Help and Usage \n" &
        "\t -l  , --list     List number of batteries \n" &
        "\t -d  , --default  Use the first/default battery \n" &
        "\t -s  , --status   Display charging status \n" &
        "\t -c  , --color    Apply color+text styling to output \n" &
        "\t -i N, --index=N  Use the Nth battery \n")
      break
    of Default:
      if not state.hasKey(Index):
        state[Index] = "0"
    else:
      let use_color = state.hasKey(Color)
      let show_status = state.hasKey(Status)
      let batteries = getBatteries()
      if List in commands:
        var counter = 0
        for batt in batteries:
          stdout.write("#" & $counter & " : " & $batt.percentage & "\n")
          inc(counter)
        break
      else:
        let index = state[Index].parseInt()
        let battery = batteries[index]

        stdout.write("[")
        if use_color:
          let color =
            if (0..25).contains(battery.percentage): fgRed
            elif (25..75).contains(battery.percentage): fgYellow
            else: fgGreen
          stdout.setForegroundColor(color)
          if battery.percentage >= 75 or battery.percentage <= 10:
            stdout.setStyle({styleBright})
        if show_status:
          if battery.isCharging:
            stdout.setStyle({styleUnderscore})
        stdout.write($battery.percentage & "%")
        if use_color:
          stdout.resetAttributes()
        stdout.write("]")
      break

# ===========
# Entry Point
# ===========

when isMainModule:
   main()
