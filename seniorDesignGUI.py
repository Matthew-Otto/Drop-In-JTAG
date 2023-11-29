import tkinter as tk
from tkinter import filedialog, messagebox, Canvas
from tkinter import font
from PIL import ImageTk, Image

class RegisterCheckerApp:
    def __init__(self, root):
        # Initialize the main application window
        self.root = root
        self.root.title("Register Checker App")

        # GUI components for file selection
        self.file_path_label = tk.Label(root, text="File Path:")
        self.file_path_label.place(x=25, y=20)

        self.file_path_entry = tk.Entry(root)
        self.file_path_entry.place(x=85, y=22)

        # Button to browse and select a file
        self.browse_button = tk.Button(root, text="Browse Files", command=self.browse_file, foreground="black", background="DarkOrange1")
        self.browse_button.place(x=250, y=18)

        # Button to check the registers for matches/mismatches
        self.check_button = tk.Button(root, text="Check Registers", command=self.load_file, foreground="black", background="DarkOrange1")
        self.check_button.place(x=350, y=18)

        # Text widget to display the results
        self.result_text = tk.Text(root, height=50, width=100, background="DarkOrange1")
        self.result_text.place(x=0, y=70)

        #setting window size
        width = 800
        height=800
        screenwidth=root.winfo_screenwidth()
        screenheight=root.winfo_screenheight()
        alignstr='%dx%d+%d+%d' % (width, height, (screenwidth-width)/2, (screenheight-height)/2)
        root.geometry(alignstr)
        root.resizable(width=False, height=False)

    def browse_file(self):
        # Open a file dialog to choose a file interactively
        file_path = filedialog.askopenfilename(filetypes=[("Text files", "*.txt")])

        # Insert the selected file path into the entry widget
        self.file_path_entry.delete(0, tk.END)
        self.file_path_entry.insert(0, file_path)

    def load_file(self):
        # Read the file path from the entry widget
        file_path = self.file_path_entry.get()

        try:
            # Open the file and read register information into a list
            with open(file_path, 'r') as file:
                self.registers = [line.strip().split(',') for line in file.readlines()]

            # Show success message
            messagebox.showinfo("Success", "File loaded successfully!")

        except Exception as e:
            # Show error message if there's an issue loading the file
            messagebox.showerror("Error", f"Error loading file: {e}")
        
        self.check_registers()

    def check_registers(self):
        # Clear previous results in the text widget
        self.result_text.delete(1.0, tk.END)

        # Check if registers are loaded
        if not hasattr(self, 'registers'):
            messagebox.showerror("Error", "Please load a file first.")
            return

        # Iterate through registers and check for matches/mismatches 
        ###THIS COLOR MATCHING ISNT WORKING NOT SURE WHY###
        
        name_ycounter = 110
        for register in self.registers:
            name, value, theoretical_value = register
            result = "Pass" if value == theoretical_value else "Fail"

            # Set color based on result (green for match, red for mismatch)
            color = "green" if result == "Pass" else "red"

            # Insert result into the text widget with the specified color
            #self.result_text.insert(tk.END, f"{name}: {value} - {result}\n", color)

            self.name_label = tk.Label(master=root, text="Register Name: ", foreground="black", background="DarkOrange1", font=font.Font(weight="bold"))
            self.name_label.place(x=5, y=name_ycounter-4)

            self.name_entry = tk.Label(root, text=name, fg='black', bg='white', width=15, borderwidth=2, relief="solid")
            self.name_entry.place(x=130, y=name_ycounter)

            self.expected_label = tk.Label(root, text="Expected TDO", fg='black', bg='DarkOrange1', font=font.Font(weight="bold"))
            self.expected_label.place(x=287, y=80)

            self.expected_entry = tk.Label(root, text=theoretical_value, fg='black', bg='white', width=15, borderwidth=2, relief="solid")
            self.expected_entry.place(x=290, y=name_ycounter)

            self.retreived_label = tk.Label(root, text="Retreived TDO", fg='black', bg='DarkOrange1', font=font.Font(weight="bold"))
            self.retreived_label.place(x=467, y=80)

            self.retreived_entry = tk.Label(root, text=value, fg='black', bg='white', width=15, borderwidth=2, relief="solid")
            self.retreived_entry.place(x=470, y=name_ycounter)

            self.result_label = tk.Label(root, text="Result", fg='black', bg='DarkOrange1', font=font.Font(weight="bold"))
            self.result_label.place(x=678, y=80)

            self.result_entry = tk.Label(root, text=result, fg='black', bg=color, width=15, borderwidth=2, relief="solid")
            self.result_entry.place(x=650, y=name_ycounter)

            name_ycounter = name_ycounter+55

if __name__ == "__main__":
    # Create the main Tkinter window and start the event loop
    root = tk.Tk()
    app = RegisterCheckerApp(root)
    root.mainloop()
