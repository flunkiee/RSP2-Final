import pandas as pd

# Read the TSV file
df = pd.read_csv('caChrom3_hits.tsv', sep='\t', header=None, 
                 names=['query', 'subject', 'pident', 'length', 'qstart', 'qend', 
                        'sstart', 'send', 'evalue', 'bitscore'])

# Function to convert to GFF
def to_gff(row):
    attributes = f"ID={row['subject']}.{row['query']};Name={row['query']};Target={row['subject']} {row['qstart']} {row['qend']}"
    return (
        row['subject'],       # seqid
        '.',                  # source
        'protein_match',      # type
        min(row['sstart'], row['send']),  # start (GFF is 1-based)
        max(row['sstart'], row['send']),  # end
        row['bitscore'],      # score
        '+' if row['sstart'] < row['send'] else '-',  # strand
        '.',                  # phase
        attributes           # attributes
    )

# Function to convert to BED
def to_bed(row):
    start = min(row['sstart'], row['send']) - 1  # BED is 0-based
    end = max(row['sstart'], row['send'])
    return (
        row['subject'],       # chrom
        start,                # start (0-based)
        end,                  # end
        f"{row['query']}|{row['subject']}",  # name
        row['bitscore'],      # score
        '+' if row['sstart'] < row['send'] else '-',  # strand
    )

# Create GFF and BED data
gff_data = df.apply(to_gff, axis=1).tolist()
bed_data = df.apply(to_bed, axis=1).tolist()

# Write GFF file
with open('output.gff', 'w') as f:
    f.write("##gff-version 3\n")
    for line in gff_data:
        f.write('\t'.join(map(str, line)))
        f.write('\n')

# Write BED file
with open('output.bed', 'w') as f:
    for line in bed_data:
        f.write('\t'.join(map(str, line)))
        f.write('\n')

print("Conversion complete. Files saved as output.gff and output.bed")
