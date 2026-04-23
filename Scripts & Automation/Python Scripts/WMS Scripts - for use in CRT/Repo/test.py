# $language = "python"
# $interface = "1.0"
def auto_prompt_responses():
    if screen.WaitForStrings(["Org Code"], 0.5) == 1:
        screen.Send("40\r")
    if screen.WaitForStrings(["Printer"], 0.5) == 1:
        screen.Send("NAIC1-183\r")
def Main():
    screen = crt.Screen
    # --- INITIAL INPUTS ---
    lpn = crt.Dialog.Prompt("1. Enter LPN (v1):", "Initial Setup", "")
    if lpn == "":
        return
    wo = crt.Dialog.Prompt("2. Enter Work Order (v2/v7):", "Initial Setup", "")
    if wo == "":
        return
    asset_rack = crt.Dialog.Prompt("3. Enter Asset Rack (v3/v5):", "Initial Setup", "")
    if asset_rack == "":
        return
    # --- DEVICE ASSETS ---
    device_count = crt.Dialog.Prompt("4. How many Device Assets?", "Device Assets", "")
    if device_count == "":
        return
    device_assets = []
    for i in range(int(device_count)):
        asset = crt.Dialog.Prompt("Enter Device Asset #" + str(i+1), "Device Assets", "")
        if asset == "":
            return
        device_assets.append(asset)
    # --- PDU ASSETS ---
    pdu_count = crt.Dialog.Prompt("5. How many PDU Assets?", "PDU Assets", "")
    if pdu_count == "":
        return
    pdu_assets = []
    for i in range(int(pdu_count)):
        asset = crt.Dialog.Prompt("Enter PDU Asset #" + str(i+1), "PDU Assets", "")
        if asset == "":
            return
        pdu_assets.append(asset)
    # --- AUTOMATION START ---
    screen.Send("311")
    crt.Sleep(1000)
    screen.Send(lpn + "\r\r")
    crt.Sleep(10000)
    screen.Send("WIPNA1\r\r")
    crt.Sleep(24000)
    # --- F2 Y SEQUENCE ---
    screen.Send("\033OQ")
    crt.Sleep(2000)
    screen.Send("Y")
    crt.Sleep(2000)
    screen.Send("\033OQ")
    crt.Sleep(2000)
    screen.Send("Y")
    crt.Sleep(2000)
    for _ in range(4):
        screen.Send("\033OQ")
        crt.Sleep(2000)
    # --- CONTINUE WORKFLOW ---
    for char in ["4", "1", "1"]:
        screen.Send(char)
        crt.Sleep(1000)
    screen.Send("\r" + wo + "\r")
    crt.Sleep(10000)
    screen.Send(asset_rack + "\r\rRACK\r\r\r")
    crt.Sleep(10000)
    # --- DEVICE ASSET ENTRY ---
    for asset in device_assets:
        screen.Send(asset + "\r")
        crt.Sleep(500)
    screen.Send("\r")
    crt.Sleep(10000)
    screen.Send(asset_rack + "\r\r")
    crt.Sleep(10000)
    # --- PDU ASSET ENTRY ---
    for asset in pdu_assets:
        screen.Send(asset + "\r")
        crt.Sleep(500)
    crt.Sleep(10000)
    screen.Send("\033[B\r")
    crt.Sleep(10000)
    screen.Send("y\r")
    crt.Sleep(10000)
    screen.Send("ZL4BTS0101\r")
    for char in ["2", "6", "2"]:
        screen.Send(char)
        crt.Sleep(1000)
    screen.Send("\r\r")
    for _ in range(5):
        screen.Send("\033OQy")
        screen.WaitForCursor(1)
    screen.Send("7")
    screen.WaitForCursor(1)
    screen.Send("1")
    screen.WaitForCursor(1)
    screen.Send("\033OS")
    screen.Send("1")
    screen.Send("\033OS")
    screen.Send("8")
    screen.Send("\033OS")
    screen.Send("1")
    screen.Send(wo + "\r")
    # --- BTS40 STEP ---
    crt.Window.Activate()
    bts40 = crt.Dialog.Prompt("PAUSED: Enter BTS40 (v8):", "Step 8 of 9", "")
    if bts40 == "":
        return
    crt.Sleep(5000)
    screen.Send(bts40 + "\r")
    screen.Send("\x03\r")
    # --- FINAL STEP ---
    bts_location = crt.Dialog.Prompt("FINAL STEP: Enter BTS Location (v9):", "Step 9 of 9", "")
    if bts_location == "":
        return
    crt.Sleep(2000)
    screen.Send(bts_location + "\r")
Main()
 