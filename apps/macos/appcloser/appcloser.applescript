#!/usr/bin/env osascript
-- appcloser.applescript
--
-- This script is designed to close the Music app on macOS if it is running.
-- The script runs forever and checks every second and closes the app if it is running.

use scripting additions

-- set global variable to count how many times the app was closed
set closeCount to 0
set home        to (do shell script "echo $HOME")
set cfgfile     to home & "/.config/appcloser/config.txt"
set logfile     to home & "/.config/appcloser/appcloser.log"
set logfileOld  to home & "/.config/appcloser/appcloser.log.old"

set qConfigDir  to quoted form of (POSIX path of (home & "/.config/appcloser"))
set qCfgfile    to quoted form of (POSIX path of cfgfile)
set qLogfile    to quoted form of (POSIX path of logfile)
set qLogfileOld to quoted form of (POSIX path of logfileOld)

-- logger function to write messages to the log file and rotate the log file
on logger(message)
    global logfile, logfileOld, qLogfile, qLogfileOld
    set logMessage  to (do shell script "date +'%Y-%m-%d %H:%M:%S'") & " - " & message
    set logFileSize to (do shell script "stat -f%z " & qLogfile & " || echo 0") as integer
    if logFileSize > 1e6 then -- 1 MB
        do shell script "mv " & qLogfile & " " & qLogfileOld
    end if
    do shell script "echo " & quoted form of logMessage & " >> " & qLogfile
end logger

on findApps(processNameToFind)
    try
        tell application "System Events"
            set matchingProcesses to every process whose name starts with processNameToFind
            if (count of matchingProcesses) is 0 then
                return {}
            else
                set processNames to {}
                repeat with aProcess in matchingProcesses
                    set end of processNames to (name of aProcess)
                end repeat
                return processNames
            end if
        end tell
    on error errMsg number errNum
	    return {}
    end try
end findApps

on closeApps(appName)
    set matches to findApps(appName)
    if (count of matches) is 0 then
        return false
    end if
    set closed to false
    repeat with proc in matches
        if closeApp(proc as string) then
            set closed to true
        end if
    end repeat
    return closed
end closeApps

on closeApp(appName)
    global closeCount
    set closed to false

    -- check if appName is running, without "opening" it:
    set isRunning to false
    set process to ""
    set procs to {}
    tell application "System Events"
        set procs to (every process whose name is appName)
        if (count of procs) > 0 then
            -- kill all matching processes by ID
            repeat with proc in procs
                set pid to unix id of proc
                set frontmost of proc to false
                try
                    do shell script "kill " & pid
                    log "Closed app: " & appName & " (PID: " & pid & ")"
                on error errMsg number errNum
                    log "Error closing app: " & appName & " (PID: " & pid & ") - " & errMsg
                end try
            end repeat
            set closeCount to closeCount + 1
            set closed to true
        end if
    end tell

    if closed then
        logger("Closed " & appName & " (count: " & closeCount & ")")
        return true -- return true to indicate the app was closed
    else
        return true
    end if
end closeApp

on cleanList(theList)
	set cleanedList to {}
	repeat with currentItem in theList
		set currentItem to (currentItem as string)
        -- skip empty lines and lines starting with #
		if currentItem is not "" and currentItem is not missing value and currentItem is not {} and currentItem does not start with "#" then
			copy currentItem to the end of cleanedList
		end if
	end repeat
	return cleanedList
end cleanList

on joinList(values, sep)
    -- return "error: cannot join list"
    if (count of values) is 0 then
        return ""
    end if
    set outText to item 1 of values as string
    if (count of values) > 1 then
        repeat with i from 2 to count of values
            set outText to outText & sep & (item i of values as string)
        end repeat
    end if
    return outText
end joinList

on readAppcloserConfig(cfgText)
    logger("Reading appcloser config")
    return cleanList(paragraphs of cfgText)
end readAppcloserConfig

-- create appcloser dir in ~/.config if it does not exist
do shell script "mkdir -p " & qConfigDir

set appNames to {}
set pid to (do shell script "echo $PPID")

-- read config file
try
    set config to (read (cfgfile as POSIX file)) as string
    set appNames to readAppcloserConfig(config)
on error
    logger("Failed to read config file: " & cfgfile & " creating default config.")
    set config to "Music.app"
    set appNames to readAppcloserConfig(config)
    -- save default config
    do shell script "echo " & quoted form of config & " > " & qCfgfile
end try

logger("Starting appcloser script with config: " & (joinList(appNames, ", ") as string) & " (PID: " & pid & ") Press Ctrl+C to stop.")

-- main loop
repeat
    set idleTime to 1 -- default idle time in seconds
    repeat with appName in appNames
        if closeApps(appName as string) then
            # set idleTime to 60 -- do not check again for 60 seconds
            set idleTime to 1 -- check every second
        end if
    end repeat
    delay idleTime
end repeat
