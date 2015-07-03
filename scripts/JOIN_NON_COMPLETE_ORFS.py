
#############################################################################
## This is the script for concatenating (joining) overlapping partial ORFs ##
#############################################################################

import sys
from Bio import SeqIO
import os


NONCOMPLETE = sys.argv[1]

inputfile = sys.argv[2]

outputfile = sys.argv[3]


with open(inputfile) as f:
    a = f.readlines()

a = map(lambda x: x.strip().split(), a)


sw = {}
handle = open(NONCOMPLETE, "rU")
for record in SeqIO.parse(handle, "fasta"):
    sw[record.id] = record.seq.tostring()
handle.close()



joined_guys = {}


for x, y, z in a:
    id1, id2 = x[1:], y[1:]
    try:
        seq1, seq2 = sw[id1], sw[id2]
    except Exception:
        continue
    overlap = int(z)
    newseq = seq1 + seq2[overlap:]
    joined_guys[id1 + "___" + id2] = newseq



# write fasta file
with open(outputfile, "w") as f:
    for seq in joined_guys:
        f.write(">%s\n" % seq)
        f.write("%s\n" % joined_guys[seq])

