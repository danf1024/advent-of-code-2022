priorities = Dict(
    zip(vcat(collect('a':'z'), collect('A':'Z')), collect(1:52))
)

lines = readlines(ARGS[1])

# part 1
println(
    sum(
        map(
            ln -> sum(
                map(
                    x -> priorities[x],
                    collect(intersect(Set(ln[begin:length(ln) ÷ 2]), Set(ln[length(ln) ÷ 2 + 1:end]))),
                ),
            ),
            lines
        )
    )
)

# part 2
groups = [lines[i:i+2] for i in 1:3:length(lines)]

println(
    sum(
        map(
            y -> sum(
                map(
                    x -> priorities[x],
                    collect(intersect(Set(y[1]), Set(y[2]), Set(y[3])))
                )
            ),
            groups,
        )
    )
)
