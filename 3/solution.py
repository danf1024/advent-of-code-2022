import sys
import string

priorities = dict([
    *zip(string.ascii_lowercase, range(1, 27)),
    *zip(string.ascii_uppercase, range(27, 53)),
])

lines = open(sys.argv[1], "r").read().strip().split("\n")

# part 1
print(
    sum(
        sum(
            priorities[x] for x in
            set(line[:int(len(line)/2)]) & set(line[int(len(line)/2):])
        )
        for line in lines
    )
)

# part 2
groups = (lines[i:i+3] for i in range(0, len(lines), 3))

print(
    sum(
        sum(
            priorities[x] for x in
            set(a) & set(b) & set(c)
        )
        for a, b, c in groups
    )
)
