import tkinter as tk
from tkinter import filedialog, messagebox, Canvas, Frame
from tkinter import font
from PIL import ImageTk, Image

register_names = ['register1','register2','register3','register4','register5']
expected_tdo = ['abcdefgh','abcdefgh','abcdemgh','abcdefgh','abcdefgh']
retreived_tdo = ['abcdefgh','abcdefgh','abcdefgh','abcdefgh','abcdefgh']
step_flag = 0
step_count = 0
current_cycle = 1

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

    def check_registers(self):
        # Clear previous results in the text widget
        #self.result_text.delete(1.0, tk.END)
        frame = Frame(root, height=800, width=100, bg='white', borderwidth=3, relief='solid', padx=5, pady=8)
        frame.pack(side='left')
        # Iterate through registers and check for matches/mismatches
        counter = 0
        global current_cycle
        self.cycle_label = tk.Label(frame, text='Cycle '+str(current_cycle), fg='black',bg='white',padx=2, pady=3, font=font.Font(weight='bold'), borderwidth=2, relief='solid')
        self.cycle_label.pack(side='top')
        for x in register_names:
            result = "Pass" if retreived_tdo[counter] == expected_tdo[counter] else "Fail"

            # Set color based on result (green for match, red for mismatch)
            color = "green" if result == "Pass" else "red"

            self.name_entry = tk.Label(frame, text=register_names[counter], fg='black', bg='white', font=font.Font(weight='bold'), pady=3)
            self.name_entry.pack(side='top')

            self.expected_label = tk.Label(frame, text="Expected TDO", fg='black', bg='white', pady=3)
            self.expected_label.pack(side='top')

            self.expected_entry = tk.Label(frame, text=expected_tdo[counter], fg='black', bg='white', width=10, borderwidth=2, relief="solid", pady=3)
            self.expected_entry.pack(side='top')

            self.retreived_label = tk.Label(frame, text="Retreived TDO", fg='black', bg='white', pady=3)
            self.retreived_label.pack(side='top')

            self.retreived_entry = tk.Label(frame, text=retreived_tdo[counter], fg='black', bg='white', width=10, borderwidth=2, relief="solid", pady=3)
            self.retreived_entry.pack(side='top')

            self.result_label = tk.Label(frame, text="Result", fg='black', bg='white', pady=3)
            self.result_label.pack(side='top')

            self.result_entry = tk.Label(frame, text=result, fg='black', bg=color, width=10, borderwidth=2, relief="solid", pady=3)
            self.result_entry.pack(side='top')

            counter += 1
        
        current_cycle = current_cycle + 1

if __name__ == "__main__":
    # Create the main Tkinter window and start the event loop
    root = tk.Tk()
    app = RegisterCheckerApp(root)
    root.configure(bg='DarkOrange1')
    while(step_count < 25):
        step_flag = input()
        if(step_flag):
            app.check_registers()
            step_count += 1
    root.mainloop()
    
