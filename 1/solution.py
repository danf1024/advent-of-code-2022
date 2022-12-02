import sys

sums = [
    sum(map(int, ea.split("\n")))
    for ea in open(sys.argv[1], "r").read().strip().split("\n\n")
]

# part 1
print(max(sums))

# part 2
print(sum(sorted(sums, reverse=True)[:3]))
