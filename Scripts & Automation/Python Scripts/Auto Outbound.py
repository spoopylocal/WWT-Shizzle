# $language = "python"
# $interface = "1.0"

MOVEUP = True


def parse_count(raw_value, label):
    value = raw_value.strip()
    if value == "":
        crt.Dialog.MessageBox(label + " is required.")
        return None
    if not value.isdigit():
        crt.Dialog.MessageBox(label + " must be a whole number.")
        return None
    return int(value)


def set_status(text):
    try:
        crt.GetScriptTab().Session.SetStatusText("MES Script: " + text)
    except Exception:
        crt.Session.SetStatusText("MES Script: " + text)


def stop_at(step_name):
    set_status("Stopped at " + step_name)
    crt.Dialog.MessageBox("Script stopped at: " + step_name)


def get_clipboard_text():
    try:
        return crt.Clipboard.Text
    except Exception:
        return ""


def prompt_required(status_text, prompt_text, title, step_name):
    set_status(status_text)
    value = crt.Dialog.Prompt(prompt_text, title, "")
    if value is None or value == "":
        stop_at(step_name)
        return None
    return value


def load_serials(count_text, count_label, title, copy_status, read_status, empty_step):
    set_status(copy_status)
    crt.Dialog.MessageBox(
        "Copy " + title + " to clipboard, then click OK to continue.",
        title,
    )

    set_status(read_status)
    pasted = get_clipboard_text()
    if pasted is None or pasted.strip() == "":
        crt.Dialog.MessageBox("Clipboard is empty. Copy " + title + " first, then run again.")
        stop_at(empty_step)
        return None

    serials = []
    seen = set()
    for s in pasted.splitlines():
        if s.strip() == "":
            continue
        if s != s.strip():
            crt.Dialog.MessageBox("Serial contains spaces: [" + s + "]")
            return None
        if s != s.upper():
            crt.Dialog.MessageBox("Serial must be capitalized: [" + s + "]")
            return None
        if s in seen:
            crt.Dialog.MessageBox("Duplicate serial detected: [" + s + "]")
            return None
        seen.add(s)
        serials.append(s)

    expected_count = parse_count(count_text, count_label)
    if expected_count is None:
        return None
    if len(serials) != expected_count:
        crt.Dialog.MessageBox(count_label + " does not match number entered.")
        return None
    return serials


def send_with_sleep(screen, text, delay):
    screen.Send(text)
    crt.Sleep(delay)


def send_chars(screen, chars, delay):
    for char in chars:
        send_with_sleep(screen, char, delay)


def send_repeated(screen, text, delay, count):
    for _ in range(count):
        send_with_sleep(screen, text, delay)


def run_f2_sequence(screen, delay=250):
    send_repeated(screen, "\033OQ", delay, 1)
    send_repeated(screen, "Y", delay, 1)
    send_repeated(screen, "\033OQ", delay, 1)
    send_repeated(screen, "Y", delay, 1)
    send_repeated(screen, "\033OQ", delay, 4)


def send_serials(screen, serials):
    for serial in serials:
        send_with_sleep(screen, serial + "\r", 500)


def prompt_optional(status_text, prompt_text, title):
    set_status(status_text)
    return crt.Dialog.Prompt(prompt_text, title, "")


def wait_for_text(screen, text, timeout_seconds, status_text):
    set_status(status_text)
    if screen.WaitForString(text, timeout_seconds):
        return True
    crt.Dialog.MessageBox('Timed out waiting for "' + text + '" after ' + str(timeout_seconds) + " seconds.")
    return False


def scan_screen_for_text(screen, text, timeout_seconds, status_text):
    set_status(status_text)
    needle = text.lower()
    attempts = int(timeout_seconds * 5)

    for _ in range(attempts):
        visible_text = screen.Get(1, 1, screen.Rows, screen.Columns)
        if needle in visible_text.lower():
            return True
        crt.Sleep(200)
    return False


def choose_continue_or_stop(prompt_text, title, step_name):
    while True:
        choice = crt.Dialog.Prompt(prompt_text, title, "Continue")
        if choice is None:
            stop_at(step_name)
            return False
        choice = choice.strip().lower()
        if choice == "continue":
            return True
        if choice == "stop" or choice == "":
            stop_at(step_name)
            return False
        crt.Dialog.MessageBox('Type "Continue" to keep going or "Stop" to stop the script.')


def prompt_if_visible(screen, text, timeout_seconds, status_text, prompt_text, title):
    if not wait_until_visible(screen, text, timeout_seconds):
        return None
    set_status(status_text)
    value = crt.Dialog.Prompt(prompt_text, title, "")
    if value is None or value == "":
        return ""
    return value


def wait_until_visible(screen, text, timeout_sec):
    attempts = int(timeout_sec * 5)
    for _ in range(attempts):
        row, _ = search_for_text(screen, text)
        if row is not None:
            return True
        crt.Sleep(200)
    return False


def search_for_text(screen, needle):
    rows, cols = screen.Rows, screen.Columns
    needle_lower = needle.lower()

    for row in range(1, rows + 1):
        line = screen.Get(row, 1, row, cols)
        col_index = line.lower().find(needle_lower)
        if col_index != -1:
            return row, col_index + 1

    return None, None


def goto_text_at(screen, target_row, move_up):
    if not move_up:
        return
    send_with_sleep(screen, "\x1b[A" * 30, 100)
    if target_row > 2:
        send_with_sleep(screen, "\x1b[B" * (target_row - 2), 100)


def run_menu_step(screen, step):
    wait_for = step.get("wait")
    goto_text = step.get("goto")
    type_text = step.get("type")
    send_key = step.get("send")
    move_up = step.get("moveup", MOVEUP)

    if wait_for and not wait_until_visible(screen, wait_for, 2):
        crt.Dialog.MessageBox("Timed out waiting for '{}'.".format(wait_for))
        return False

    if goto_text:
        row, _ = search_for_text(screen, goto_text)
        if row is None:
            crt.Dialog.MessageBox("'{}' not found on screen.".format(goto_text))
            return False
        goto_text_at(screen, row, move_up)
        crt.Sleep(100)

    if type_text:
        for ch in type_text:
            screen.Send(ch)
            crt.Sleep(100)

    if send_key:
        screen.Send(send_key)

    return True


def select_printer(screen):
    set_status("Selecting printer")
    run_f2_sequence(screen)
    steps = [
        {"goto": "Others", "send": "\r"},
        {"wait": "Choose Printer", "goto": "Choose Printer", "send": "\r"},
    ]
    for step in steps:
        if not run_menu_step(screen, step):
            return False
    org_code = prompt_if_visible(
        screen,
        "Org Code",
        1,
        "Input: Org Code",
        "Enter Org Code:",
        "Change Printer",
    )
    if org_code == "":
        return False
    if org_code is not None:
        send_with_sleep(screen, org_code, 100)
        send_with_sleep(screen, "\r", 100)
    if not run_menu_step(screen, {"wait": "Printer", "goto": "Printer", "type": "NAIC1-532", "send": "\r"}):
        return False
    run_f2_sequence(screen)
    return True


def select_subinventory(screen):
    set_status("Selecting subinventory")
    steps = [
        {"goto": "Inventory", "send": "\r"},
        {"wait": "Transfers", "goto": "Transfers", "send": "\r"},
        {"wait": "Subinventory", "goto": "Subinventory", "send": "\r"},
    ]
    for step in steps:
        if not run_menu_step(screen, step):
            return False
    return True


def select_wip_completion(screen):
    set_status("Selecting WIP Completion")
    steps = [
        {"goto": "Lab", "send": "\r"},
        {"wait": "WIP/WOC", "goto": "WIP/WOC", "send": "\r"},
        {"wait": "WIP Completion", "goto": "WIP Completion", "send": "\r"},
    ]
    for step in steps:
        if not run_menu_step(screen, step):
            return False
    return True


def select_wip_reprint(screen):
    set_status("Running label reprint")
    steps = [
        {"goto": "Others", "send": "\r"},
        {"wait": "Label Printing", "goto": "Label Printing", "send": "\r"},
        {"wait": "Label Category", "goto": "Label Category", "type": "LAB", "send": "\r", "moveup": False},
        {"wait": "Label type", "goto": "Label type", "type": "WIP REPRINT", "send": "\r", "moveup": False},
        {"wait": "Level", "goto": "Level", "type": "JOB", "send": "\r", "moveup": False}
    ]
    for step in steps:
        if not run_menu_step(screen, step):
            return False
    return True


def Main():
    tab = crt.GetScriptTab()
    screen = tab.Screen
    screen.Synchronous = False
    if not tab.Session.Connected:
        crt.Dialog.MessageBox("No active SecureCRT session is connected.")
        return

    set_status("Collecting input")
    # --- INITIAL INPUTS ---
    lpn = prompt_required("Input step 1: LPN", "1. Enter LPN (v1):", "Initial Setup", "Step 1 (LPN)")
    if lpn is None:
        return
    wo = prompt_required("Input step 2: Work Order", "2. Enter Work Order (v2/v7):", "Initial Setup", "Step 2 (Work Order)")
    if wo is None:
        return
    serial_rack = prompt_required("Input step 3: Serial Rack", "3. Enter Serial Rack (v3/v5):", "Initial Setup", "Step 3 (Serial Rack)")
    if serial_rack is None:
        return

    # --- DEVICE SERIALS ---
    device_count = prompt_required("Input step 4: Device count", "4. How many Device Serials?", "Device Serials", "Step 4 (Device count)")
    if device_count is None:
        return
    device_serials = load_serials(
        device_count,
        "Device Serial count",
        "Device Serials",
        "Input step 4b: Copy device serials",
        "Input step 4b: Reading device serials from clipboard",
        "Step 4b (Device serial clipboard)",
    )
    if device_serials is None:
        return

    # --- PDU SERIALS ---
    pdu_count = prompt_required("Input step 5: PDU count", "5. How many PDU Serials?", "PDU Serials", "Step 5 (PDU count)")
    if pdu_count is None:
        return
    pdu_serials = load_serials(
        pdu_count,
        "PDU Serial count",
        "PDU Serials",
        "Input step 5b: Copy PDU serials",
        "Input step 5b: Reading PDU serials from clipboard",
        "Step 5b (PDU serial clipboard)",
    )
    if pdu_serials is None:
        return

    # --- AUTOMATION START ---
    tab.Activate()
    crt.Sleep(300)
    set_status("Starting automation")
    if not select_printer(screen):
        return
    if not select_subinventory(screen):
        return
    send_with_sleep(screen, lpn + "\r\r", 10000)
    screen.Send("WIPNA1\r\r")
    if not wait_for_text(screen, "Txn Success", 60, 'Waiting for "Txn Success"'):
        stop_at('Waiting for "Txn Success"')
        return

    # --- F2 Y SEQUENCE ---
    set_status("Running F2 confirmation sequence")
    run_f2_sequence(screen)

    # --- CONTINUE WORKFLOW ---
    set_status("Processing WO and rack")
    if not select_wip_completion(screen):
        return
    send_with_sleep(screen, "\r" + wo + "\r", 2500)

    if scan_screen_for_text(screen, "Not enough supply", 2, 'Checking for "Not enough supply"'):
        if not choose_continue_or_stop(
            '"Not enough supply" was detected.\n\nType "Continue" to keep going or "Stop" to stop the script.',
            "Supply Warning",
            '"Not enough supply"',
        ):
            return
        send_with_sleep(screen, "\r", 5000)

    send_with_sleep(screen, serial_rack + "\r\rRACK\r\r\r", 5000)

    # --- DEVICE SERIAL ENTRY ---
    set_status("Entering device serials")
    send_serials(screen, device_serials)
    send_with_sleep(screen, "\r", 5000)

    send_with_sleep(screen, serial_rack + "\r\r", 5000)

    # --- PDU SERIAL ENTRY ---
    set_status("Entering PDU serials")
    send_serials(screen, pdu_serials)
    crt.Sleep(5000)

    send_with_sleep(screen, "\033[B\r", 2000)
    send_with_sleep(screen, "y\r\r", 10000)
    send_with_sleep(screen, "ZL4BTS0101\r", 1000)
    send_chars(screen, "262", 250)
    send_with_sleep(screen, "\r\r", 50)

    run_f2_sequence(screen)
    if not select_wip_reprint(screen):
        return
    send_with_sleep(screen, wo + "\r", 500)
    send_with_sleep(screen, "\r", 500)
    crt.Sleep(1000)
    run_f2_sequence(screen, 250)

    # --- BTS40 STEP ---
    set_status("Waiting for BTS40 input")
    select_subinventory(screen)
    crt.Window.Activate()
    bts40 = crt.Dialog.Prompt("PAUSED: Enter BTS40 (v8):", "Step 8 of 9", "")
    if bts40 == "":
        return
    crt.Sleep(5000)
    send_with_sleep(screen, bts40, 1000)
    send_with_sleep(screen, "\r", 1000)
    send_with_sleep(screen, "\x03\r", 1000)

    # --- FINAL STEP ---
    bts_location = prompt_optional("Waiting for final location input", "FINAL STEP: Enter BTS Location (v9):", "Step 9 of 9")
    if bts_location == "":
        return
    crt.Sleep(2000)
    send_with_sleep(screen, bts_location + "\r", 250)
    send_with_sleep(screen, "\r", 250)
    set_status("Completed")

try:
    Main()
except Exception as exc:
    crt.Dialog.MessageBox("Script stopped due to error:\n{}".format(str(exc)))  
