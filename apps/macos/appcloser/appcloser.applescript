#!/usr/bin/env osascript
-- appcloser.applescript
--
-- This script is designed to close the Music app on macOS if it is running.
-- The script runs forever and checks every second and closes the app if it is running.

-- set global variable to count how many times the app was closed
set closeCount to 0
set home             to (do shell script "echo $HOME")
set logfile          to home & "/.config/appcloser.log"
set logfileOld       to home & "/.config/appcloser.log.old"
set quotedLogfile    to quoted form of (POSIX path of logfile)
set quotedLogfileOld to quoted form of (POSIX path of logfileOld)

-- logger function to write messages to the log file and rotate the log file
on logger(message)
    global logfile, logfileOld, quotedLogfile, quotedLogfileOld
    set logMessage  to (do shell script "date +'%Y-%m-%d %H:%M:%S'") & " - " & message
    set logFileSize to (do shell script "stat -f%z " & quotedLogfile & " || echo 0") as integer
    if logFileSize > 1e6 then -- 1 MB
        do shell script "mv " & quotedLogfile & " " & quotedLogfileOld
    end if
    do shell script "echo " & quoted form of logMessage & " >> " & quotedLogfile
end logger

-- Make the script run in the background and checks every second if the app is running.
on closeApp(appName)
    global closeCount
    set closed to false
    tell application appName
        if it is running then
            tell application appName
                quit
            end tell
            set closeCount to closeCount + 1
            set closed to true
        end if
    end tell
    if closed then
        logger("Closed " & appName & " (count: " & closeCount & ")")
        return 60 -- wait 60 seconds before checking again (to avoid rapid closing)
    else
        return 1 -- idle time in seconds (check every second)
    end if
end closeApp

set appName to "Music.app" -- default app name
logger("Starting appcloser script for " & appName & " (PID: " & (do shell script "echo $PPID") & ") Press Ctrl+C to stop.")

repeat
    set idleTime to closeApp(appName)
    delay idleTime
end repeat
