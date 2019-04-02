# =======
# Imports
# =======

import os
import osproc
import hashes
import tables
import distros
import streams
import parseopt
import strutils

import "protocol.nim"

when detectOs(Linux):
  import "linux.nim"
when detectOs(Windows):
  import "windows.nim"
when detectOs(MacOSX):
  import "macosx.nim"

# =====
# Types
# =====

const
  AppName    = "batterylevel"
  AppVersion = "0.5.0"

type
  Action = enum
    Color   = ('c', "color"),
    Default = ('d', "default"),
    Help    = ('h', "help"),
    Index   = ('i', "index"),
    List    = ('l', "list"),
    Status  = ('s', "status"),
    Version = ('v', "version"),

proc hash(x: Action): Hash =
  result = hash($x)

# ===========
# Entry Point
# ===========

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

for key in state.keys():
  case key
  of Version:
    echo(AppName & " v" & AppVersion)
    break
  of Help:
    echo(AppName & "\n" &
      "\t -v  , --version  Display Version \n" &
      "\t -h  , --help     Display Help and Usage \n" &
      "\t -l  , --list     List available batteries \n" &
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
    if List in index:
      outputHandle.write($batteries.len)
    else:
      let index = state[Index].parseInt()
      let battery = batteries[index]
      outputHandle.write(battery.percentage)
