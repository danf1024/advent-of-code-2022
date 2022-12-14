packet_pairs = map(
    x -> map(z -> eval(Meta.parse(z)), x),
    map(
        y -> split(y, "\n"),
        split(chomp(read(open(ARGS[1], "r"), String)), "\n\n")
    )
)

function compare(x::Vector, y::Vector)::Int64
    for (a, b) in zip(x, y)
        c = compare(a, b)
        if c != 0 return c; end
    end
    cmp(length(x), length(y))
end


function compare(x::Int64, y::Int64)::Int64
    cmp(x, y)
end


function compare(x::Vector, y::Int64)::Int64
    compare(x, [y])
end


function compare(x::Int64, y::Vector)::Int64
    compare([x], y)
end

# part 1
# println(sum(findall(x -> compare(x...) == -1, packet_pairs)))

# part 2
all_packets = vcat(packet_pairs...)
div1 = [[2]]
div2 = [[6]]

push!(all_packets, div1, div2)
sort!(all_packets, lt=(x, y) -> compare(x, y) == -1)

println(prod(findall(x -> x === div1 || x === div2, all_packets)))
