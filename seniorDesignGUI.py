import tkinter as tk
from tkinter import filedialog, messagebox

class RegisterCheckerApp:
    def __init__(self, root):
        # Initialize the main application window
        self.root = root
        self.root.title("Register Checker App")

        # GUI components for file selection
        self.file_path_label = tk.Label(root, text="File Path:")
        self.file_path_label.grid(row=0, column=0, padx=5, pady=5)

        self.file_path_entry = tk.Entry(root)
        self.file_path_entry.grid(row=0, column=1, padx=5, pady=5)

        # Button to browse and select a file
        self.browse_button = tk.Button(root, text="Browse", command=self.browse_file)
        self.browse_button.grid(row=0, column=2, padx=5, pady=5)

        # Button to load the selected file
        self.load_button = tk.Button(root, text="Load File", command=self.load_file)
        self.load_button.grid(row=0, column=3, padx=5, pady=5)

        # Button to check the registers for matches/mismatches
        self.check_button = tk.Button(root, text="Check Registers", command=self.check_registers)
        self.check_button.grid(row=1, column=0, columnspan=4, pady=10)

        # Text widget to display the results
        self.result_text = tk.Text(root, height=10, width=40)
        self.result_text.grid(row=2, column=0, columnspan=4, pady=5)

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

    def check_registers(self):
        # Clear previous results in the text widget
        self.result_text.delete(1.0, tk.END)

        # Check if registers are loaded
        if not hasattr(self, 'registers'):
            messagebox.showerror("Error", "Please load a file first.")
            return

        # Iterate through registers and check for matches/mismatches 
        ###THIS COLOR MATCHING ISNT WORKING NOT SURE WHY###
        for register in self.registers:
            name, value, theoretical_value = register
            result = "Match" if value == theoretical_value else "Mismatch"

            # Set color based on result (green for match, red for mismatch)
            color = "green" if result == "Match" else "red"

            # Insert result into the text widget with the specified color
            self.result_text.insert(tk.END, f"{name}: {value} - {result}\n", color)

if __name__ == "__main__":
    # Create the main Tkinter window and start the event loop
    root = tk.Tk()
    app = RegisterCheckerApp(root)
    root.mainloop()
