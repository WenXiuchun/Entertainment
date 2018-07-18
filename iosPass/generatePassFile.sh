appleId=$1
name=$2
echo $appleId
echo $name
cat /Users/i323932/Documents/CEC-InnoLab-Customer-Entertainment/iosPass/pass.json | awk '{
    if (FNR==11) {
        print "    \"message\" : \"'$appleId';'$name'\","
    } else if (FNR == 20) {
        print "      \"relevantText\" : \"A game awaits you '$name'! Find us on the 2nd floor \""
    } else if (FNR == 40) {
        print "       \"value\": \"A game awaits you '$name'! Find us on the 2nd floor\""
    } else {
        print $0
    }

}' > /Users/i323932/Documents/CEC-InnoLab-Customer-Entertainment/iosPass/Casino.pass/pass.json

/Users/i323932/Documents/CEC-InnoLab-Customer-Entertainment/iosPass/signpass -p /Users/i323932/Documents/CEC-InnoLab-Customer-Entertainment/iosPass/Casino.pass
osascript /Users/i323932/Documents/CEC-InnoLab-Customer-Entertainment/iosPass/send-imessage-passbook.scpt $appleId
