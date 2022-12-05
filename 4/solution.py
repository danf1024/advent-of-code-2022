import sys

def range_set(str_range):
    s1, s2 = str_range.split("-")
    return set(range(int(s1), int(s2) + 1))


section_sets = [
    tuple(map(range_set, line.split(",")))
    for line in open(sys.argv[1], "r")
]

# part 1
print(sum(a <= b or b <= a for a, b in section_sets))

# part 2
print(sum(bool(a & b) for a, b in section_sets))

