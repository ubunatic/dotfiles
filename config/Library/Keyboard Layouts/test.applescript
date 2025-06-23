-- Get current working directory
set currentDir to (do shell script "pwd")
-- Open TextEdit application and bring it to the front
do shell script "open -a TextEdit"

-- test func to check clipboard content

tell application "TextEdit"
    tell application "System Events"
        keystroke "Line 1: running in " & currentDir & return
        keystroke "Line 2: this is a test of the TextEdit application" & return
        keystroke "Line 3: no text" & return
        keystroke "Line 4: no text" & return
    end tell

    -- German PC keyboard codes for <, >, and |, ^, °
    -- The key right of the left shift key must be [<, >, |] and not [^, °]
    -- The key left of the [1] key must be [^, °] and not [<, >, |]
    -- The remapped codes are: 10 and 50 for modifier keys: shift and option
    tell application "System Events"
        keystroke "Line 5: "
        key code 10 -- < key
        key code 10 using {shift down} -- > key
        key code 10 using {option down} -- | key

        -- select and copy the current line
        -- press "ctrl+shift+a" to select the line
        keystroke "a" using {control down, shift down}
        delay 0.1
        keystroke "c" using {command down}
        delay 0.1
    end tell

    set expectedContent to "Line 5: <>|"
    set clipboardContent to the clipboard
    if clipboardContent is not expectedContent then
        display dialog "ClipContent test failed, clipboardContent: " & clipboardContent
    else
        display dialog "ClipContent test successful!\nTextEdit will quit now." buttons {"Done"} default button "Done" with title "ClipContent Test Result" giving up after 5
    end if

    tell application "TextEdit" to quit saving no

end tell
