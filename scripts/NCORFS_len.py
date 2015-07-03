

from Bio import SeqIO
import sys


a = sys.argv[1]

b = sys.argv[2] # diamond mapping file

c = sys.argv[3] # newORFs_lens

sw = {}
handle = open(a, "rU")
for record in SeqIO.parse(handle, "fasta"):
    sw[record.id] = len(record.seq)
handle.close()



with open(b) as f:
    m = f.readlines()

m = map(lambda x: x.strip().split(), m)

di = {}

for mm in m:
    di[mm[0]] = mm[10] # contig --> e_value





with open(c, "w") as f:
    for x, y in sw.items():
        f.write("%s %s %s\n" % (x, y, di[x]))

