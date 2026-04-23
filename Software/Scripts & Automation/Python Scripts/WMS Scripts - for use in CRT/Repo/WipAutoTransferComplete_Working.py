# $language = "python"
# $interface = "1.0"

import time


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

    send(screen, "3")
    send(screen, "1")
    send(screen, "1")

    # Paste copied LPN from clipboard
    pause(10)
    send(screen, crt.Clipboard.Text)

    pause(10)
    send(screen, "\r")

    pause(10)
    send(screen, "\r")

    # Type WIPNA1 and press Enter
    pause(10)
    send(screen, "WIPNA1\r")
    send(screen, "\r")

    # Press F2
    send(screen, "\033OQ")
    send(screen, "Y")
    send(screen, "\033OQ")
    send(screen, "\033OQ")

    send(screen, "4")
    send(screen, "1")
    send(screen, "1")
    send(screen, "\r")


main()

# This script navigates to Subinventory Transfer, pastes the LPN,
# sends the location WIPNA1, then moves into 411.