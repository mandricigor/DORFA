
import networkx as nx
import sys

f1 = sys.argv[1]
f2 = sys.argv[2]
f3 = sys.argv[3]


g = nx.DiGraph()


with open(f1) as f:
    a = f.readlines()

a = map(lambda x: x.strip().split(), a)


with open(f2) as f:
    b = f.readlines()

b = map(lambda x: x.strip().split(), b)

with open(f3) as f:
    c = f.readlines()

c = map(lambda x: x.strip().split(), c)


sources = []
destinations = []



for x, y in a:
    destinations.append(y)
    g.add_edge(x, y)

for x, y in b:
    g.add_edge(x, y)

for x, y in c:
    sources.append(x)
    g.add_edge(x, y)


for x in sources:
    for y in destinations:
        try:
            paths = nx.all_simple_paths(g, x, y)
            for path in paths:
                print " ".join(path)
        except Exception:
            pass


