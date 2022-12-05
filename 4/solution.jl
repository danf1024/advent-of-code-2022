function fully_contains(x::Set, y::Set)::Bool
    ⊆(x, y) || ⊇(x, y)
end

section_sets = map(
    line -> map(
        x -> Set(range(map(y -> parse(Int64, y), split(x, "-"))...)),
        split(line, ",")
    ),
    readlines(ARGS[1])
)

# part 1
println(count(x -> fully_contains(x...), section_sets))

# part 2
println(count(v -> !isempty(intersect(v...)), section_sets))
