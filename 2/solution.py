import sys

lookup = {
    "A X": 4, # rock v rock D + 1 = 4
    "A Y": 8, # paper v rock W + 2 = 8
    "A Z": 3, # scissors v rock L + 3 = 3
    "B X": 1, # rock v paper L + 1 = 1
    "B Y": 5, # paper v paper D + 2 = 5
    "B Z": 9, # scisscors v paper W + 3 = 9
    "C X": 7, # rock v scissors W + 1 = 7
    "C Y": 2, # paper v scissors L + 2 = 2
    "C Z": 6, # scissors v scissors D + 3 = 6
}

# X = L
# Y = D
# Z = W
lookup_2 = {
    "A X": "Z", # rock v. scissors = L
    "A Y": "X", # rock v. rock = D
    "A Z": "Y", # rock v. paper = W
    "B X": "X", # paper v. rock = L
    "B Y": "Y", # paper v. paper = D
    "B Z": "Z", # paper v. scissors = W
    "C X": "Y", # scissors v. paper = L
    "C Y": "Z", # scissors v. scissors = D
    "C Z": "X", # scissors v. rock = W
}


# part 1
print(sum(lookup[ea.strip()] for ea in open(sys.argv[1], "r")))

# part 2
print(sum(lookup[f"{ea.split()[0]} {lookup_2[ea.strip()]}"] for ea in open(sys.argv[1], "r")))
