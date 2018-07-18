on run argv
    set appleId to item 1 of argv
    tell application "Messages" to send "Weclome to the SAP Hybris Digital Innovation Space" to buddy appleId
    set attach to POSIX file "/Users/i323932/Documents/CEC-InnoLab-Customer-Entertainment/iosPass/Casino.pkpass"
    tell application "Messages" to send attach to buddy appleId 
end run
