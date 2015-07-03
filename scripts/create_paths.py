
#############################################################################
## This is the script for creating ORFs based on simple paths              ##
#############################################################################

import sys
from Bio import SeqIO
import os


NONCOMPLETE = sys.argv[1]
overlapFile = sys.argv[2]
allSimplePaths = sys.argv[3]
outputFile = sys.argv[4]


with open(overlapFile) as f:
    b = f.readlines()
goodb = map(lambda x: x.strip().split(), b)


aaa = {}
for x, y, z in goodb:
    aaa[(x, y)] = z  # (contig1, contig2) --> overlap


with open(allSimplePaths) as f:
    guys = f.readlines()
guys = map(lambda x: x.strip().split(), guys)




sw = {}
handle = open(NONCOMPLETE, "rU")
for record in SeqIO.parse(handle, "fasta"):
    sw[record.id] = record.seq.tostring()
handle.close()



joined_guys = {}

for guy in guys:
    guy_id = "___".join(guy)
    sikvans = sw[guy[0]]
    for i in range(1, len(guy)):
        cursikvans = sw[guy[i]]
        overlap = int(aaa[(">" + guy[i - 1], ">" + guy[i])])
        sikvans = sikvans + sw[guy[i]][overlap:]
    joined_guys[guy_id] = sikvans


# write fasta file
with open(outputFile, "w") as f:
    for seq in joined_guys:
        f.write(">%s\n" % seq)
        f.write("%s\n" % joined_guys[seq])

