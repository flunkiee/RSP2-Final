import tkinter as tk
from tkinter import filedialog, messagebox
import os
import csv

def process_files():
    files = filedialog.askopenfilenames(
        title="Select CSV Files",
        filetypes=[("CSV Files", "*.csv")]
    )

    if not files:
        return

    output_lines = []

    for filepath in files:
        filename = os.path.basename(filepath)
        site_values = []

        try:
            with open(filepath, "r", newline='') as csvfile:
                reader = csv.reader(csvfile)
                for row in reader:
                    if row and len(row) > 0:
                        site_values.append(row[0])  #site

            combined = "+".join(site_values)
            output_lines.append(f"--- {filename} ---\n{combined}\n")

        except Exception as e:
            messagebox.showerror("Error", f"Failed to process {filename}:\n{e}")
            continue

    if output_lines:
        save_path = filedialog.asksaveasfilename(
            defaultextension=".txt",
            filetypes=[("Text Files", "*.txt")],
            title="Save Output File"
        )
        if save_path:
            with open(save_path, "w") as out_file:
                out_file.write("\n".join(output_lines))
            messagebox.showinfo("Done", "All files processed and saved!")

def main():
    root = tk.Tk()
    root.title("CSV Site Combiner")
    root.geometry("300x150")

    label = tk.Label(root, text="Combine Site Values from CSV Files", pady=20)
    label.pack()

    button = tk.Button(root, text="Select CSV Files", command=process_files)
    button.pack(pady=10)

    root.mainloop()

if __name__ == "__main__":
    main()
