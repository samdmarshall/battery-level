battery-level
=============

This utility reports on the remaining battery percentage and charging status of
macOS-based computers. It is intended to be incorprated into shell prompts,
terminal-based editor status-lines, scripts, etc.

Usage
-----

Macs can have multiple power sources (though it's rare). Use the `--list` flag
to tell you how many sources you have, and then `--index:<num>` to select the
source you want. Note that it is a zero-based array, so if you have one source,
then use `--index:0`. The default output is the percentage of battery remaining.

    $ battery-level --list
    1
    $ battery-level --index:0
    48

There is also a handy `--default` flag to automatically select the first source.

    $ battery-level --default
    48

You can pass the flag `--charging`, which will return `1` if the battery is
currently charging, and `0` if it is not. Cases where it will return `0` include
when the computer is not plugged in, as well as when it is plugged in but the
battery is full.

Both of these result in the same output:

    $ battery-level --index:0 --charging
    0
    $ battery-level --default --charging
    0

Example Shell Integration
-------------------------

You can put the following in your `~/.bashrc`

    prompt_battery() {
      charge=$(battery-level --default --charging)
      if [[ $charge -eq 1 ]]; then
        echo '⚡️'
      fi
    }
    
    export PS1="\$(prompt_battery) \d \@ \w $ "

And, if the battery is charging, your prompt will look like

    ⚡️  Mon Feb 27 10:18 AM ~/Development/battery-level $
