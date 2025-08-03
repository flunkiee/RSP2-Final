import tkinter as tk
from tkinter import filedialog, messagebox
import re

def clean_fasta(input_path, output_path):
    patterns = [
        re.compile(r'mutant', re.IGNORECASE),
        re.compile(r'strain\s+168', re.IGNORECASE),
        re.compile(r'NCIB\s+3610', re.IGNORECASE) #regex
    ]

    removed = 0
    kept_entries = []
    current_entry = []
    keep = True

    with open(input_path, 'r') as f:
        for line in f:
            if line.startswith('>'):
                if current_entry and keep:
                    kept_entries.extend(current_entry)

                current_entry = [line]
                keep = not any(p.search(line) for p in patterns)
                if not keep:
                    removed += 1
            else:
                current_entry.append(line)

        if current_entry and keep:
            kept_entries.extend(current_entry)

    with open(output_path, 'w') as out:
        out.writelines(kept_entries)

    return removed

def run():
    root = tk.Tk()
    root.withdraw()  # Hide main window

    input_path = filedialog.askopenfilename(
        title="Select FASTA File",
        filetypes=[("FASTA files", "*.fasta *.fa *.fna"), ("All files", "*.*")]
    )
    if not input_path:
        return

    output_path = filedialog.asksaveasfilename(
        defaultextension=".fasta",
        filetypes=[("FASTA files", "*.fasta *.fa *.fna")],
        title="Save Output As"
    )
    if not output_path:
        return

    removed = clean_fasta(input_path, output_path)
    messagebox.showinfo("Unwanted accessions removed!", f"Removed {removed} sequence(s).\nSaved to: {output_path}") #removed count is mostly for debug stuff, if it suddenly deletes like all ur data somethings gone wrong.

if __name__ == "__main__":
    run()
