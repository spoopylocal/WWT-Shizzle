# $language = "python"
# $interface = "1.0"

import time


def send(screen, text, delay=0.05):
    screen.Send(text)
    time.sleep(delay)


def main():
    screen = crt.Screen
    screen.Synchronous = True

    # F2 -> confirm -> F2
    send(screen, "\033OQ")   # F2
    send(screen, "Y")        # Confirm
    send(screen, "\033OQ")   # F2

    # Select Others -> 1
    send(screen, "9")
    send(screen, "1")

    # F4 -> 4 -> F4 -> 8 -> F4 + Enter
    send(screen, "\033OS")   # F4
    send(screen, "1") # Could be "4" or "1" for LAB
    send(screen, "\033OS")   # F4
    send(screen, "8") # Could be "8" or "\03313" for WIP Reprint
    send(screen, "\033OS\r") # F4 + Enter

    # WIP Reprint
    screen.WaitForString("WIP Reprint", 2)
    send(screen, crt.Clipboard.Text, 2)  # Copy WO number to clipboard before running script
    send(screen, "\r")
    send(screen, "\r", 1.0)
    send(screen, "\033OQy")   # F2

    # F2 confirm / exit sequence
    screen.WaitForString("Others")
    send(screen, "\033OQ")   # F2
    screen.WaitForString("Inventory")
    send(screen, "1")     # Select 1 -> 1
    send(screen, "1")


main()

# This script goes from Subinventory Transfer to WIP Reprint, enters the WO number,
# confirms to print, then goes back into Subinventory Transfer.