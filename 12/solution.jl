M = permutedims(hcat(collect.(readlines(ARGS[1]))...))

mutable struct Node
    height::Int64
    dist::Float64
    prev::Union{Nothing, Node}
    adjacent::Vector{Node}
end

unvisited = Set()
start = nothing
dest = nothing
heights = Dict(zip(collect('a':'z'), collect(1:26)))

MM = Matrix(undef, size(M)...)

for j in 1:size(M, 2)
    for i in 1:size(M, 1)
        x = M[i,j]

        if x == 'S'
            node = Node(1, Inf, nothing, [])
            global start = node
        elseif x == 'E'
            node = Node(26, 0, nothing, [])
            global dest = node
        else
            node = Node(heights[x], Inf, nothing, [])
        end

        MM[i,j] = node
        push!(unvisited, node)
    end
end

function reachable(pos::Node, target::Node)
    target.height - pos.height <= 1
end

for j in 1:size(MM, 2)
    for i in 1:size(MM, 1)
        node = MM[i,j]
        if i > 1
            above = MM[i-1,j]
            if reachable(above, node) push!(node.adjacent, above); end
        end

        if i < size(MM, 1)
            below = MM[i+1,j]
            if reachable(below, node) push!(node.adjacent, below); end
        end

        if j > 1
            left = MM[i,j-1]
            if reachable(left, node) push!(node.adjacent, left); end
        end

        if j < size(MM, 2)
            right = MM[i,j+1]
            if reachable(right, node) push!(node.adjacent, right); end
        end
    end
end

function min_dist_unvisited()::Node
    m = nothing
    for n in unvisited
        if isnothing(m) || n.dist < m.dist
            m = n
        end
    end
    m
end

a_nodes = []

while !isempty(unvisited)
    curr = min_dist_unvisited()

    if curr.height == 1 && curr.dist < Inf
        push!(a_nodes, curr)
    end

    pop!(unvisited, curr)

    for neighbor in curr.adjacent
        if !in(neighbor, unvisited) continue; end
        alt = curr.dist + 1
        if alt < neighbor.dist
            neighbor.dist = alt
            neighbor.prev = curr
        end
    end
end

# part 1
println(start.dist)

sort!(a_nodes, by=n -> n.dist)
println(a_nodes[1].dist)
