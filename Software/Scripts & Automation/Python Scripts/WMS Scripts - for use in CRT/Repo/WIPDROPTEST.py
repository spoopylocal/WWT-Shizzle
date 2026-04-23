# $language = "python"
# $interface = "1.0"

import time


DROP_LOCATION = "ZL4BTS0101"
DROP_CODE = "262"


def send(screen, text, delay=0.05):
    # Sends text/keys to the SecureCRT session
    screen.Send(text)
    time.sleep(delay)


def pause(seconds):
    # Standalone pause used when a screen needs extra time to load
    time.sleep(seconds)


def main():
    # Gets the current SecureCRT screen object
    screen = crt.Screen

    # Keeps screen reading/sending in sync
    screen.Synchronous = True

    # Confirm initial prompt
    send(screen, "\033[B\r")
    send(screen, "Y")
    pause(1.0)

    # Advance through Move LPN screens
    send(screen, "\r")
    pause(1.0)
    send(screen, "\r")
    pause(1.0)

    # Send BTS drop location
    send(screen, DROP_LOCATION + "\r")

    # Enter BTS40 drop code
    send(screen, DROP_CODE + "\r")
    send(screen, "\r")
    pause(1.0)

    # Exit back to menu
    send(screen, "\033OQy")
    send(screen, "\033OQ")
    send(screen, "\033OQ")

    # Move into Subinventory Transfer
    send(screen, "3")
    send(screen, "1")
    send(screen, "1")


main()

# This script auto drops onto a BTS40, then goes into Subinventory Transfer.