# $language = "python"
# $interface = "1.0"

import time

username = "USERNAME"
password = "PASSWORD"
printer_name = "aa-000"

crt.Screen.Synchronous = True

crt.Screen.WaitForString("User Name:", 10)
crt.Screen.Send(username + "\r")

crt.Screen.WaitForString("Password :", 10)
crt.Screen.Send(password + "\r")

crt.Screen.Send("\x1b")
crt.Screen.Send("10")

crt.Screen.Send("3\r")
time.sleep(0.15)
crt.Screen.Send("1\r")
time.sleep(0.15)
crt.Screen.Send("1\r")
time.sleep(0.15)
crt.Screen.Send("40\r")
time.sleep(0.15)
crt.Screen.Send(printer_name + "\r")
time.sleep(0.15)

crt.Screen.Send("\033OQ")
time.sleep(0.15)
crt.Screen.Send("Y")
time.sleep(0.15)
crt.Screen.Send("\033OQ")
time.sleep(0.15)
crt.Screen.Send("\033OQ")