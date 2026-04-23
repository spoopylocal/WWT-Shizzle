# $language = "Python3"
# $interface = "1.0"

F4 = "\x1bOS"
ENTER = "\r"
TIMEOUT_SEC = 1
TYPE_DELAY_MS = 1
PRE_MENU_KEY = "\033OQ"
PRE_MENU_DELAY_MS = 1
PRE_MENU_COUNT = 5
MOVEUP = True

MENU_FLOWS = {
    "1": {
        "name": "WIP Reprint",
        "steps": [
            {"goto": "Others", "send": ENTER},
            {"wait": "Label Printing", "goto": "Label Printing", "send": ENTER},
            {"wait": "Label Category", "goto": "Label Category", "type": "LAB", "send": ENTER, "moveup": False},
            {"wait": "Label type", "goto": "Label type", "type": "WIP REPRINT", "send": ENTER, "moveup": False},
            {"wait": "Level", "goto": "Level", "type": "JOB", "send": ENTER, "moveup": False},
        ],
    },
    "2": {
        "name": "LPN Unpack",
        "steps": [
            {"wait": "Lab", "goto": "Lab", "send": ENTER},
            {"wait": "Configuration", "goto": "Configuration", "send": ENTER},
            {"wait": "LPN Unpack", "goto": "LPN Unpack", "send": ENTER},
        ],
    },
    "3": {
        "name": "LPN Repack",
        "steps": [
            {"wait": "Lab", "goto": "Lab", "send": ENTER},
            {"wait": "Configuration", "goto": "Configuration", "send": ENTER},
            {"wait": "LPN Repack", "goto": "LPN Repack", "send": ENTER},
        ],
    },
    "4": {
        "name": "WIP Complete",
        "steps": [
            {"goto": "Lab", "send": ENTER},
            {"wait": "WIP/WOC", "goto": "WIP/WOC", "send": ENTER},
            {"wait": "WIP Completion", "goto": "WIP Completion", "send": ENTER},
        ],
    },
    "5": {
        "name": "Subinventory Transfer",
        "steps": [
            {"goto": "Inventory", "send": ENTER},
            {"wait": "Transfers", "goto": "Transfers", "send": ENTER},
            {"wait": "Subinventory Transfer", "goto": "Subinventory Transfer", "send": ENTER},
        ],
    },
    "6": {
        "name": "Data Capture",
        "steps": [
            {"goto": "Others", "send": ENTER},
            {"wait": "Label Printing", "goto": "Label Printing", "send": ENTER},
            {"wait": "Label Category", "goto": "Label Category", "type": "LAB", "send": ENTER, "moveup": False},
            {"wait": "Label type", "goto": "Label type", "type": "DATA CAPTURE", "send": ENTER, "moveup": False},
        ],
    },
    "7": {
        "name": "MSPN Reprint",
        "steps": [
            {"goto": "Others", "send": ENTER},
            {"wait": "Label Printing", "goto": "Label Printing", "send": ENTER},
            {"wait": "Label Category", "goto": "Label Category", "type": "INVENTORY", "send": ENTER, "moveup": False},
            {"wait": "Label type", "goto": "Label type", "type": "ASSET PREPRINT", "send": ENTER, "moveup": False},
            {"wait": "Material Desg", "goto": "Material Desg", "type": "MCIO_STOCK/VAS - O", "send": ENTER, "moveup": False},

        ],
    },
    "8": {
        "name": "Standalone Asset Capture",
        "steps": [
            {"goto": "Inventory", "send": ENTER},
            {"wait": "Standalone", "goto": "Standalone", "send": ENTER},
        ],
    },
    "9": {
        "name": "Functions",
        "function_menu": True,
    },
}

FUNCTION_FLOWS = {
    "1": {
        "name": "Print BTS Labels",
        "prompts": [
            {
                "key": "lpn_count",
                "status": "Input: LPNs per box",
                "prompt": "How many LPNs in a box?",
                "title": "Test Function",
                "default": "",
            },
            {
                "key": "material_designation",
                "status": "Input: Mat'l Desg",
                "prompt": "Enter Mat'l Desg:",
                "title": "Test Function",
                "default": "",
            },
        ],
        "steps": [
            {"goto": "Others", "send": ENTER},
            {"wait": "Label Printing", "goto": "Label Printing", "send": ENTER},
            {"wait": "Label Category", "goto": "Label Category", "type": "INVENTORY", "send": ENTER, "moveup": False},
            {"wait": "Label type", "goto": "Label type", "type": "LPN GENERATE", "send": ENTER, "moveup": False},
            {"wait": "LPN Type", "goto": "LPN Type", "type": "BACK TO STOCK", "send": ENTER, "moveup": False},
            {"wait": "# LPNs", "type_from": "lpn_count", "send": ENTER, "moveup": False},
            {"wait": "Mat'l Desig", "goto": "Mat'l Desig", "type_from": "material_designation", "send": ENTER, "moveup": False},
            {"send": ENTER},
        ],
    },
    "2": {
        "name": "WIP Reprint By WO",
        "prompts": [
            {
                "key": "work_order",
                "status": "Input: Work Order",
                "prompt": "Enter Work Order:",
                "title": "WIP Reprint By WO",
                "default": "",
            },
        ],
        "steps": [
            {"goto": "Others", "send": ENTER},
            {"wait": "Label Printing", "goto": "Label Printing", "send": ENTER},
            {"wait": "Label Category", "goto": "Label Category", "type": "LAB", "send": ENTER, "moveup": False},
            {"wait": "Label type", "goto": "Label type", "type": "WIP REPRINT", "send": ENTER, "moveup": False},
            {"wait": "Level", "goto": "Level", "type": "JOB", "send": ENTER, "moveup": False},
            {"type_from": "work_order", "send": ENTER},
            {"send": ENTER},
        ],
    },
    "3": {
        "name": "Change Printer",
        "prompts": [
            {
                "key": "printer_name",
                "status": "Input: Printer",
                "prompt": "Enter Printer:",
                "title": "Change Printer",
                "default": "",
            },
        ],
        "steps": [
            {"goto": "Others", "send": ENTER},
            {"wait": "Choose Printer", "goto": "Choose Printer", "send": ENTER},
            {
                "optional_wait": "Org Code",
                "prompt_key": "org_code",
                "prompt_status": "Input: Org Code",
                "prompt_text": "Enter Org Code:",
                "prompt_title": "Change Printer",
                "type_from": "org_code",
                "send": ENTER,
            },
            {"wait": "Printer", "goto": "Printer", "type_from": "printer_name", "send": ENTER, "moveup": False},
        ],
    },
    "4": {
        "name": "Dock Print",
        "prompts": [
            {
                "key": "repeat_count",
                "status": "Input: Repeat Count",
                "prompt": "How many times should I repeat?",
                "title": "Dock Print",
                "default": "1",
            },
            {
                "key": "repeat_delay_ms",
                "status": "Input: Delay",
                "prompt": "Delay between repeats (ms). Try 750 or 1000.",
                "title": "Dock Print",
                "default": "750",
            },
        ],
        "steps": [
            {"goto": "Inbound", "send": ENTER},
            {"wait": "Carrier Load", "goto": "Carrier Load", "send": ENTER},
            {"wait": "Carrier", "goto": "Carrier", "moveup": False},
            {"repeat_action": "dock_print_inventory"},
        ],
    },
}


def main():
    screen = crt.Screen
    screen.Synchronous = False

    menu_choice = choose_menu()
    if menu_choice is None:
        return

    selected_flow = MENU_FLOWS[menu_choice]
    if selected_flow.get("function_menu"):
        function_choice = choose_function()
        if function_choice is None:
            return
        selected_flow = FUNCTION_FLOWS[function_choice]
    context = collect_flow_inputs(selected_flow)
    if context is None:
        return

    send_repeated(screen, PRE_MENU_KEY, PRE_MENU_DELAY_MS, PRE_MENU_COUNT)

    for step in selected_flow["steps"]:
        if not run_step(screen, step, context):
            return


def choose_menu():
    prompt_lines = ["Choose a menu:"]
    for key in sorted(MENU_FLOWS):
        prompt_lines.append(key + ". " + MENU_FLOWS[key]["name"])

    while True:
        choice = crt.Dialog.Prompt("\n".join(prompt_lines), "Menu Select", "1")
        if choice is None or choice == "":
            return None
        choice = choice.strip()
        if choice in MENU_FLOWS:
            return choice
        crt.Dialog.MessageBox("Enter 1, 2, 3, 4, 5, 6, 7, 8, or 9.")


def choose_function():
    prompt_lines = ["Choose a function:"]
    for key in sorted(FUNCTION_FLOWS):
        prompt_lines.append(key + ". " + FUNCTION_FLOWS[key]["name"])

    while True:
        choice = crt.Dialog.Prompt("\n".join(prompt_lines), "Functions", "1")
        if choice is None or choice == "":
            return None
        choice = choice.strip()
        if choice in FUNCTION_FLOWS:
            return choice
        crt.Dialog.MessageBox("Enter 1, 2, 3, or 4.")


def set_status(text):
    try:
        crt.GetScriptTab().Session.SetStatusText("MES Script: " + text)
    except Exception:
        crt.Session.SetStatusText("MES Script: " + text)


def collect_flow_inputs(flow):
    context = {}
    prompts = flow.get("prompts", [])
    for prompt in prompts:
        set_status(prompt.get("status", "Collecting input"))
        value = crt.Dialog.Prompt(
            prompt.get("prompt", ""),
            prompt.get("title", "Input"),
            prompt.get("default", ""),
        )
        if value is None or value == "":
            return None
        context[prompt["key"]] = value

    if flow.get("name") == "Dock Print":
        repeat_count = parse_positive_int(context.get("repeat_count"), "repeat count")
        if repeat_count is None:
            return None
        delay_ms = parse_non_negative_int(context.get("repeat_delay_ms"), "delay")
        if delay_ms is None:
            return None
        context["repeat_count"] = repeat_count
        context["repeat_delay_ms"] = delay_ms

        if repeat_count >= 500:
            message = (
                "You're about to run this {} times.\n"
                "Delay: {} ms\n\n"
                "Continue?"
            ).format(repeat_count, delay_ms)
            title = "Confirm Huge Repeat"
        else:
            message = "Run Inventory% {} times?\nDelay: {} ms".format(repeat_count, delay_ms)
            title = "Confirm Repeat"

        if not confirm_yes_no(message, title):
            return None

    return context


def run_step(screen, step, context):
    repeat_action = step.get("repeat_action")
    if repeat_action:
        return run_repeat_action(screen, repeat_action, context)

    wait_for = step.get("wait")
    optional_wait = step.get("optional_wait")
    goto_text = step.get("goto")
    type_text = step.get("type")
    if step.get("type_from"):
        type_text = context.get(step.get("type_from"), "")
    send_key = step.get("send")
    move_up = step.get("moveup", MOVEUP)

    if wait_for and not wait_until_visible(screen, wait_for, TIMEOUT_SEC):
        crt.Dialog.MessageBox("Timed out waiting for '{}'.".format(wait_for))
        return False

    if optional_wait:
        if not wait_until_visible(screen, optional_wait, TIMEOUT_SEC):
            return True
        prompt_key = step.get("prompt_key")
        if prompt_key and prompt_key not in context:
            set_status(step.get("prompt_status", "Collecting input"))
            value = crt.Dialog.Prompt(
                step.get("prompt_text", ""),
                step.get("prompt_title", "Input"),
                step.get("prompt_default", ""),
            )
            if value is None or value == "":
                return False
            context[prompt_key] = value
        if step.get("type_from"):
            type_text = context.get(step.get("type_from"), "")

    if goto_text:
        row, col = search_for_text(screen, goto_text)
        if row is None:
            crt.Dialog.MessageBox("'{}' not found on screen.".format(goto_text))
            return False
        goto_text_at(screen, row, col, move_up)
        crt.Sleep(100)

    if type_text:
        send_slow(screen, type_text, TYPE_DELAY_MS)

    if send_key:
        screen.Send(send_key)

    return True


def wait_until_visible(screen, text, timeout_sec):
    attempts = int(timeout_sec * 5)
    for _ in range(attempts):
        row, _ = search_for_text(screen, text)
        if row is not None:
            return True
        crt.Sleep(200)
    return False


def send_slow(screen, text, char_delay_ms):
    for ch in text:
        screen.Send(ch)
        crt.Sleep(char_delay_ms)


def send_with_sleep(screen, text, delay):
    screen.Send(text)
    crt.Sleep(delay)


def send_repeated(screen, text, delay, count):
    for _ in range(count):
        send_with_sleep(screen, text, delay)
        send_with_sleep(screen, "y", delay)


def search_for_text(screen, needle):
    rows, cols = screen.Rows, screen.Columns
    needle_lower = needle.lower()

    for row in range(1, rows + 1):
        line = screen.Get(row, 1, row, cols)
        col_index = line.lower().find(needle_lower)
        if col_index != -1:
            return row, col_index + 1

    return None, None


def goto_text_at(screen, target_row, target_col, move_up):
    if not move_up:
        return
    send_with_sleep(screen, "\x1b[A" * 30, 100)
    if target_row > 2:
        send_with_sleep(screen, "\x1b[B" * (target_row - 2), 100)


def parse_positive_int(value, label):
    try:
        number = int(str(value).strip())
    except Exception:
        crt.Dialog.MessageBox("Please enter a valid {}.".format(label))
        return None
    if number < 1:
        crt.Dialog.MessageBox("Please enter a {} greater than 0.".format(label))
        return None
    return number


def parse_non_negative_int(value, label):
    try:
        number = int(str(value).strip())
    except Exception:
        crt.Dialog.MessageBox("Please enter a valid {} in milliseconds.".format(label))
        return None
    if number < 0:
        crt.Dialog.MessageBox("Please enter a {} of 0 or more.".format(label))
        return None
    return number


def confirm_yes_no(message, title):
    return crt.Dialog.MessageBox(message, title, 36) == 6


def run_repeat_action(screen, action_name, context):
    if action_name == "dock_print_inventory":
        return run_dock_print_inventory(screen, context)
    crt.Dialog.MessageBox("Unknown repeat action '{}'.".format(action_name))
    return False


def run_dock_print_inventory(screen, context):
    batch_size = 25
    repeat_count = context["repeat_count"]
    delay_ms = context["repeat_delay_ms"]

    for index in range(1, repeat_count + 1):
        set_status("Dock Print {}/{}".format(index, repeat_count))
        send_slow(screen, "INVENTORY%", TYPE_DELAY_MS)
        crt.Sleep(200)
        screen.Send(ENTER)
        crt.Sleep(200)
        screen.Send(ENTER)
        crt.Sleep(delay_ms)

        if index % batch_size == 0 and index != repeat_count:
            if not confirm_yes_no(
                "Progress: {} / {}\n\nYES = continue, NO = stop.".format(index, repeat_count),
                "Continue?",
            ):
                crt.Dialog.MessageBox("Stopped at {} / {}.".format(index, repeat_count))
                return False

    crt.Dialog.MessageBox("Done! Sent {} times.".format(repeat_count))
    return True


main()
