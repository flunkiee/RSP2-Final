import tkinter as tk
from tkinter import filedialog, messagebox
import csv
import re

# Function to extract accessions from FASTA
def extract_accessions(fasta_file):
    acc_pattern = re.compile(r'([A-Z]{2,5}[0-9]{5,}\.[0-9]+)')
    accessions = []

    with open(fasta_file, 'r') as f:
        for line in f:
            if line.startswith('>'):
                match = acc_pattern.search(line)
                if match:
                    accessions.append([match.group(1)])
                else:
                    print(f"Warning: No accession found in header:\n{line.strip()}")
    
    return accessions

# Callback function for GUI
def run_extraction():
    fasta_file = filedialog.askopenfilename(title="Select FASTA file", filetypes=[("FASTA files", "*.fasta *.fa"), ("All files", "*.*")])
    if not fasta_file:
        return

    accessions = extract_accessions(fasta_file)
    if not accessions:
        messagebox.showwarning("No Accessions Found", "No accession IDs were found in the selected FASTA file.")
        return

    csv_file = filedialog.asksaveasfilename(defaultextension=".csv", filetypes=[("CSV files", "*.csv")], title="Save CSV as")
    if not csv_file:
        return

    with open(csv_file, 'w', newline='') as csv_out:
        writer = csv.writer(csv_out)
        writer.writerow(['Accession_ID'])
        writer.writerows(accessions)

    messagebox.showinfo("Success", f"Extracted {len(accessions)} accession IDs to:\n{csv_file}")

# GUI setup
root = tk.Tk()
root.title("FASTA Accession Extractor")

frame = tk.Frame(root, padx=20, pady=20)
frame.pack()

label = tk.Label(frame, text="Extract Accession IDs from a multi-FASTA file")
label.pack(pady=(0, 10))

button = tk.Button(frame, text="Select FASTA File and Extract", command=run_extraction)
button.pack()

root.mainloop()
