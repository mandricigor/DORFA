


import sys



ov1 = int(sys.argv[3])
ov2 = 100


file1, file2 = sys.argv[1], sys.argv[2]


with open(file1) as f:
    a = f.readlines()


aa = map(lambda x: x.strip(), a)

with open(file2) as f:
    b = f.readlines()

bb = map(lambda x: x.strip(), b)



def overlap(seq1, seq2):
    for i in range(0, len(seq1)):
        s1, s2 = seq1[i:], seq2[:len(seq1) - i]
        if s1 == s2:
            return len(seq1) - i
    return -1



a = []
b = []

aaa = []
bbb = []


da = False



for x in aa:
    if da:
        a.append(x)
        da = not da
    else:
        aaa.append(x)
        da = not da


for y in bb:
    if da:
        b.append(y)
        da = not da
    else:
        bbb.append(y)
        da = not da




for x, xx in zip(a, aaa):
    for y, yy in zip(b, bbb):
        ov = overlap(x, y)
        if ov1 <= ov <= ov2 and ov % 3 == 0:
            print xx, yy, ov

