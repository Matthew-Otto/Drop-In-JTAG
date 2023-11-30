import tkinter as tk
from tkinter import filedialog, messagebox, Canvas, Frame
from tkinter import font
from telnetlib import Telnet
import pickle

debug = True

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


step_flag = 0
step_count = 0
current_cycle = 1


def main():
    # Create the main Tkinter window and start the event loop
    global root
    root = tk.Tk()
    app = RegisterCheckerApp(root)
    root.configure(bg='DarkOrange1')

    with open("fixed_data.pkl", "rb") as f:
        correct_register_data = pickle.load(f)


    global tn
    with Telnet("10.55.0.1", 4444) as tn:
        read()

        trst()

        instr("halt") # stop system clock
        instr("reset") # reset the core


        cycle = 0
        while (cycle < 25):
            instr("sample_preload")
            data = boundary_scan()
            reference = correct_register_data[cycle]

            app.check_registers(reference, data)
            instr("step")
            cycle += 1

        a = input(">")

        root.mainloop()

        root.update()




        #instr("sample_preload")
        #data = boundary_scan()
        #app.check_registers()
        #cycle += 1

    return





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

    def check_registers(self, reference, measured):
        # Clear previous results in the text widget
        #self.result_text.delete(1.0, tk.END)
        frame = Frame(root, height=800, width=100, bg='white', borderwidth=3, relief='solid', padx=5, pady=8)
        frame.pack(side='left')
        # Iterate through registers and check for matches/mismatches
        counter = 0
        global current_cycle
        self.cycle_label = tk.Label(frame, text='Cycle '+str(current_cycle), fg='black',bg='white',padx=2, pady=3, font=font.Font(weight='bold'), borderwidth=2, relief='solid')
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
        
        current_cycle = current_cycle + 1





def fix_bug():
    trst()

    instr("halt") # stop system clock
    instr("reset") # reset the core


    while True:
        instr("step") # toggle system clock once
        instr("sample_preload")
        data = boundary_scan()
        if data["PC"] == "00000024":
            # jump to next instruction
            preload({"PC" : 28, "Instr" : "0023A233"})
            instr("clamp")
            break

    while True:
        instr("step") # toggle system clock once
        instr("sample_preload")
        data = boundary_scan()
        if data["PC"] == "00000050":
            instr("resume")
            break

    trst()


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
    tn.write(cmd.encode('ascii') + b"\n")

def read():
    data = b""
    while True:
        rd = tn.read_until(b"\n", timeout=0.05)
        if not rd:
            break
        else:
            data += rd

    if debug:
        print(data.decode('ascii'))

    return data.decode('ascii')



if __name__ == "__main__":
    main()