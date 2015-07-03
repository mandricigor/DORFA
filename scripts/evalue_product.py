
#############################################################################
## This is the script for concatenating (joining) overlapping partial ORFs ##
#############################################################################


import sys

separate_orfs = sys.argv[1]
inputfile = sys.argv[2]
outputfile = sys.argv[3]
method = sys.argv[4] # this means whether to apply min rule or product rule

# Allowed methods: MINIMUM and PRODUCT


with open(separate_orfs) as f:
    b = f.readlines()

b = map(lambda x: x.strip().split(), b)

separate = {}
for record in b:
    separate[record[0]] = (record[1], record[10])


with open(inputfile) as f:
    a = f.readlines()

a = map(lambda x: x.strip().split(), a)


with open(outputfile, "w") as f:
    for record in a:
        id1_id2 = record[0]
        protein = record[1]
        evalue = record[10]
    
        id1, id2 = id1_id2.split("___")
        protein1, evalue1 = separate.get(id1, ("--------------------", "---"))
        protein2, evalue2 = separate.get(id2, ("--------------------", "---"))
        GOOD = None
        try:
            if method == "PRODUCT":
                GOOD = float(evalue) <= float(evalue1) * float(evalue2)
            elif method == "MINIMUM":
                GOOD = float(evalue) <= min(float(evalue1), float(evalue2))
            if GOOD:
                GOOD = "GOOD!!!"
            else:
                GOOD = "BAD!!!!"
        except Exception:
            GOOD = "BAD!!!!"
        if GOOD == "GOOD!!!":            
            f.write("%-60s\t%-25s\t%-5s\t%-30s\t%-25s\t%-5s\t%-30s\t%-25s\t%-5s\t%-7s\n" % (id1_id2, protein, evalue, id1, protein1, evalue1, id2, protein2, evalue2, GOOD))



