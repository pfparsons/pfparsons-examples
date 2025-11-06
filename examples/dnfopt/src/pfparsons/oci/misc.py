
def recursive_tree(height: int, degree) -> Node:
    tot_nodes = (degree**(height + 1) - 1) // (degree - 1)
    nodes_per_tree = ((degree**2 -1) // (degree-1))
    digits = len(str(tot_nodes))
    def fmt(n: int) -> str: return str(n).rjust(digits, ' ')
    nodes = [fmt(m) for m in range(tot_nodes)]
    parents = [fmt(max(0, (n - 1) // 2)) for n in range(tot_nodes)]
    children = [[fmt(2 * n + 1), fmt(2 * n + 2)] for n in range(tot_nodes - (tot_nodes//2+1))]
    print(nodes)
    print(parents)
    print(children)
