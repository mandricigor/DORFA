

from Bio import SeqIO
import sys


a = sys.argv[1]
b = sys.argv[2]
c = sys.argv[3]


ids = []
left = []
right = []
handle = open(b + "/" + a, "rU")
for record in SeqIO.parse(handle, "fasta"):
    seq = record.seq.tostring()
    l = seq[:100]
    r = seq[-100:]
    ids.append(record.id)
    left.append(l)
    right.append(r)
handle.close()



with open(c + "/" + a + ".left", "w") as f:
    for x, y in zip(ids, left):
        f.write(">%s\n" % x)
        f.write("%s\n" % y) 


with open(c + "/" + a + ".right", "w") as f:
    for x, y in zip(ids, right):
        f.write(">%s\n" % x)
        f.write("%s\n" % y) 


