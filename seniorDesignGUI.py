import tkinter as tk
from tkinter import filedialog, messagebox, Canvas, Frame
from tkinter import font
from telnetlib import Telnet
import pickle

debug = False
test_mode = True

bsr_format = { # matches the position of the BSR, do not edit
    "ReadData" : 32,
    "WriteData" : 32,
    "DataAdr" : 32,
    "MemWrite" : 1,
    "Instr" : 32,
    "PC" : 32,
}

gui_order = [
    "PC",
    "Instr",
    "DataAdr",
    "ReadData" ,
    "WriteData",
]


def main():
    # Create the main Tkinter window and start the event loop
    global tn
    global root
    global app
    global correct_register_data

    if not test_mode:
        tn = Telnet("10.55.0.1", 4444)

    root = tk.Tk()

    button_run = tk.Button(root, text='Run', width=25, command=run_debug,)
    button_run.pack()

    button_fix = tk.Button(root, text='Override PC20', width=25, command=fix_bug,)
    button_fix.pack()

    app = RegisterCheckerApp(root)
    root.configure(bg='DarkOrange1')

    with open("fixed_data.pkl", "rb") as f:
        correct_register_data = pickle.load(f)

    root.mainloop()


class RegisterCheckerApp:
    def __init__(self, root):
        # Initialize the main application window
        self.root = root
        self.root.title("Register Checker App")

        self.title_label = tk.Label(root, text="Drop-In Semiconductor Tester GUI", font=font.Font(weight='bold', size='18'), pady=5, bg='DarkOrange1')
        self.title_label.pack(side='top', anchor='nw')

        #setting window size
        width = 2425
        height=1000
        screenwidth=root.winfo_screenwidth()
        screenheight=root.winfo_screenheight()
        alignstr='%dx%d+%d+%d' % (width, height, (screenwidth-width)/2, (screenheight-height)/2)
        root.geometry(alignstr)
        root.resizable(width=False, height=False)

    def check_registers(self, cycle, reference, measured):
        # Clear previous results in the text widget
        #self.result_text.delete(1.0, tk.END)
        frame = Frame(root, height=800, width=100, bg='white', borderwidth=3, relief='solid', padx=5, pady=8)
        frame.pack(side='left')
        # Iterate through registers and check for matches/mismatches
        counter = 0
        self.cycle_label = tk.Label(frame, text='Cycle '+str(cycle), fg='black',bg='white',padx=2, pady=3, font=font.Font(weight='bold'), borderwidth=2, relief='solid')
        self.cycle_label.pack(side='top')

        for k in gui_order:

            if reference[k] == measured[k]:
                result = "Pass"
                color = "green"
            elif k == "WriteData" and measured["MemWrite"] == "00":
                result = "Pass"
                color = "green"
            else:
                result = "Fail"
                color = "red"

            self.name_entry = tk.Label(frame, text=k, fg='black', bg='white', font=font.Font(weight='bold'), pady=3)
            self.name_entry.pack(side='top')

            self.expected_label = tk.Label(frame, text="Expected Value", fg='black', bg='white', pady=3)
            self.expected_label.pack(side='top')

            self.expected_entry = tk.Label(frame, text=reference[k], fg='black', bg='white', width=10, borderwidth=2, relief="solid", pady=3)
            self.expected_entry.pack(side='top')

            self.retreived_label = tk.Label(frame, text="Retreived Value", fg='black', bg='white', pady=3)
            self.retreived_label.pack(side='top')

            self.retreived_entry = tk.Label(frame, text=measured[k], fg='black', bg='white', width=10, borderwidth=2, relief="solid", pady=3)
            self.retreived_entry.pack(side='top')

            self.result_label = tk.Label(frame, text="Result", fg='black', bg='white', pady=3)
            self.result_label.pack(side='top')

            self.result_entry = tk.Label(frame, text=result, fg='black', bg=color, width=10, borderwidth=2, relief="solid", pady=3)
            self.result_entry.pack(side='top')

            counter += 1





def fix_bug():
    if test_mode:
        for idx, data in enumerate(correct_register_data):
            app.check_registers(idx+1, data, data)
        return

    trst()
    instr("halt") # stop system clock
    instr("reset") # reset the core

    cycle = 0
    #instr("step") # toggle system clock once
    while True:
        instr("sample_preload")
        data = boundary_scan()

        if data["PC"] == "00000024":
            # jump to next instruction
            preload({"PC" : 28, "Instr" : "0023A233"})
            instr("clamp")
            instr("step") # toggle system clock once
            break
        else:
            reference = correct_register_data[cycle]
            app.check_registers(cycle+1, reference, data)

        instr("step") # toggle system clock once
        cycle += 1

    while True:
        instr("sample_preload")
        data = boundary_scan()
        reference = correct_register_data[cycle]
        app.check_registers(cycle+1, reference, data)

        if data["DataAdr"] == "00000064" or data["WriteData"] == "00000019":
            instr("resume")
            break

        instr("step") # toggle system clock once
        cycle += 1

    trst()
    root.update()



def run_debug():
    if test_mode:
        with open("bad_data.pkl", "rb") as f:
            incorrect_register_data = pickle.load(f)
        for idx, data in enumerate(correct_register_data):
            app.check_registers(idx+1, data, incorrect_register_data[idx])
        return

    trst()
    instr("halt") # stop system clock
    instr("reset") # reset the core

    cycle = 0
    while (cycle < 24):
        instr("sample_preload")
        data = boundary_scan()
        reference = correct_register_data[cycle]

        app.check_registers(cycle+1, reference, data)
        instr("step")
        cycle += 1



def trst():
    execute("pathmove RESET IDLE")


def preload(scan_in):
    """
    scanning twice allows overwriting only a single register in the BSR chain
    """
    instr("sample_preload")
    payload = boundary_scan()
    for k,v in scan_in.items():
        payload[k] = v

    boundary_scan(scan_in=payload)
    return payload


def boundary_scan(scan_in=None):
    if test_mode:
        return None

    payload = "drscan core.tap"

    for reg, width in bsr_format.items():
        if scan_in and reg in scan_in:
            payload += f" {width} 0x{scan_in[reg]}"
        else:
            payload += f" {width} 0x0"

    scan_out = execute(payload)

    data = dict(zip(bsr_format.keys(), scan_out.split("\r\n")[1:]))

    return data


ir_codes = {
    "BYPASS"         : "0xf",
    "IDCODE"         : "0x1",
    "SAMPLE_PRELOAD" : "0x2",
    "EXTEST"         : "0x3",
    "INTEST"         : "0x4",
    "CLAMP"          : "0x5",
    "HALT"           : "0x6",
    "STEP"           : "0x7",
    "RESUME"         : "0x8",
    "RESET"          : "0x9",
}

def instr(instruction):
    """Load the specified instruction"""
    code = ir_codes[instruction.upper()]

    return execute(f"irscan core.tap {code}")


def execute(cmd):
    write(cmd)
    return read()

def write(cmd):
    if not test_mode:
        tn.write(cmd.encode('ascii') + b"\n")

def read():
    if test_mode:
        return None
    
    data = b""
    while True:
        rd = tn.read_until(b"\n", timeout=0.01)
        if not rd:
            break
        else:
            data += rd

    if debug:
        print(data.decode('ascii'))

    return data.decode('ascii')



if __name__ == "__main__":
    main()