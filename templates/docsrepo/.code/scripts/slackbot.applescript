#!/usr/bin/osascript
on run argv
    if (count of argv) is not 1 then
        error "Usage: osascript slackbot.applescript <message>"
    end if
    set theMessage to item 1 of argv

    -- safely read env var: DOCSREPO_SLACKBOT_URL
    set slackbotURL to do shell script "echo \"$DOCSREPO_SLACKBOT_URL\""

    if slackbotURL is "" then
        error "Environment variable DOCSREPO_SLACKBOT_URL is not set. Please set it to the URL to open a chat with Slackbot in the Slack app."
    end if

    -- use 'open URL' to open the Slackbot chat in the Slack app
    do shell script "open \"" & slackbotURL & "\""
    delay 1 -- Wait for app to open

    -- ensure Slack is the frontmost app
    if application "Slack" is not frontmost then
        error "Failed to open Slackbot chat. Please make sure the Slack app is installed and the URL in DOCSREPO_SLACKBOT_URL is correct."
    end if

    -- send message to Slackbot using System Events to simulate keystrokes
    tell application "System Events"
        keystroke theMessage
        delay 0.3
        -- send CMD+Enter to send the message (this is the default shortcut for sending messages in Slack)
        keystroke return using {command down}
    end tell
end run