import pandas as pd
import tkinter as tk
from tkinter import filedialog

#gui stuff
root = tk.Tk()
root.withdraw()

#file selection prompt
file_path = filedialog.askopenfilename(
    title="Select FUBAR output",
    filetypes=[("CSV files", "*.csv"), ("All files", "*.*")]
)

#main
if file_path:
    try:
        #ignore first row of csv
        df = pd.read_csv(file_path, header=None, skiprows=1)

        site_col = 0        # Site
        prob_alpha_gt_beta_col = 5  # Prob[α > β]

        # filter for sites with Prob[α > β] > 0.9
        negative_sites = df[df[prob_alpha_gt_beta_col] > 0.9]
        
        site_numbers = negative_sites[site_col].tolist()

        #output
        print("\nSites under pervasive negative selection (Prob[α > β] > 0.9):")
        if site_numbers:
            print(site_numbers)
        else:
            print("No sites meet the threshold.")

        #write output
        output_path = file_path.replace(".csv", "_negative_selection.csv")
        negative_sites.to_csv(output_path, index=False, header=False)
        print(f"\nFiltered results saved to: {output_path}")

    except Exception as e:
        print("Error reading or processing the file:", e)
else:
    print("No file selected.")
