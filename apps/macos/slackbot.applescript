#!/usr/bin/osascript
on run argv
    if (count of argv) is not 1 then
        error "Usage: osascript slackbot.applescript <message>"
    end if
    set theMessage to item 1 of argv

    -- read env var SLACKBOT_URL
    set slackbotURL to do shell script "echo \"$SLACKBOT_URL\""

    if slackbotURL is "" then
        error "Environment variable SLACKBOT_URL is not set. Set it to the Slack deep-link URL for Slackbot, e.g. slack://user?team=<TEAM_ID>&id=USLACKBOT"
    end if

    -- open the Slackbot chat in the Slack app
    do shell script "open \"" & slackbotURL & "\""
    delay 1

    if application "Slack" is not frontmost then
        error "Failed to open Slackbot chat. Make sure the Slack app is installed and SLACKBOT_URL is correct."
    end if

    tell application "System Events"
        keystroke theMessage
        delay 0.3
        keystroke return using {command down}
    end tell
end run
