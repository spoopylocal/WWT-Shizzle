# $language = "python"
# $interface = "1.0"

import time

# --- Configuration ---
USERNAME = "CULLUMJB"
PASSWORD = "NightStone4Harbor"
PRINTER_NAME = "NAIC1-183"

def main():

    screen = crt.Screen
    screen.Synchronous = True

    # Start login
    screen.Send("1\r")

    screen.WaitForString("User Name:", 10)
    screen.Send(USERNAME + "\r")

    screen.WaitForString("Password :", 10)
    screen.Send(PASSWORD + "\r")
    time.sleep(0.5)

    # Navigate menus
    screen.Send("N")
    screen.Send("1")
    screen.Send("3")
    screen.Send("1")
    screen.Send("1")
    screen.Send("40")

    time.sleep(0.2)
    screen.Send("\r")

    # Enter printer name
    time.sleep(0.3)
    screen.Send(PRINTER_NAME + "\r")

main()