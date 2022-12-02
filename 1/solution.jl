sums = map(
    x -> sum(
        map(y -> parse(Int64, y), x)
    ),
    map(
        z -> split(z, "\n"),
        split(chomp(read(open(ARGS[1], "r"), String)), "\n\n")
    )
)

# part 1
println(maximum(sums))

# part 2
println(sum(sort(sums, rev=true)[begin:3]))
