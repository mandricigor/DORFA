
#############################################################################
## This is the script for concatenating (joining) overlapping partial ORFs ##
#############################################################################


import sys





separate_orfs = sys.argv[1]
FILE = sys.argv[2]
output_file = sys.argv[3]
method = sys.argv[4] #method is PRODUCT or MINIMUM



with open(separate_orfs) as f:
    b = f.readlines()

b = map(lambda x: x.strip().split(), b)

separate = {}
for record in b:
    separate[record[0]] = (record[1], float(record[10]))


with open(FILE) as f:
    a = f.readlines()

a = map(lambda x: x.strip().split(), a)


def prod(alist):
    x = 1
    for i in alist:
        x *= i
    return x


def minimum(alist):
    return min(alist)



with open(output_file, "w") as f:
    for record in a:
        id1_id2 = record[0]
        protein = record[1]
        bitscore = float(record[10])
        
        ids = id1_id2.split("___")

        proteins = []
        bitscores = []

        for aidi in ids:
            prot, bit = separate.get(aidi, ("XXX", "XXX"))
            proteins.append(prot)
            bitscores.append(bit)        

        if method == "PRODUCT":
            path_score = prod(bitscores)
        elif method == "MINIMUM":
            path_score = minimum(bitscores)

        if bitscore <= path_score:
            f.write("%s\t%s\t%s\t%s\t%s\n" % (id1_id2, protein, bitscore, ",".join(proteins), ",".join(map(str, bitscores))))



