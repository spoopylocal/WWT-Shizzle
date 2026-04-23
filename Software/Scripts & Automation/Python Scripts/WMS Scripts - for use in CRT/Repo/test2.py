# $language = "python"
# $interface = "1.0"

import re

def select_menu_option(screen, option_text):
    rows = screen.Rows
    cols = screen.Columns

    # Get all visible screen text
    screen_text = screen.Get(1, 1, rows, cols)

    for line in screen_text.splitlines():
        if option_text in line:
            # Find the number at the start of the line
            match = re.match(r"\s*(\d+)", line)
            if match:
                option_number = match.group(1)

                crt.Screen.Send(option_number + "\r")
                return True

    return False


crt.Screen.Synchronous = True

if select_menu_option(crt.Screen, "Subinventory Transfer"):
    crt.Dialog.MessageBox("Selected Subinventory Transfer")
else:
    crt.Dialog.MessageBox("Menu option not found")