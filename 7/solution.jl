mutable struct Node
    parent::Union{Node, Nothing}
    children::Dict{String, Node}
    name::String
    size::Int64
end

function getsize(node::Node)::Int64
    node.size + reduce(+, map(c -> getsize(c), values(node.children)), init=0)
end

output_re = r"(?:(\$)\s)?([a-z0-9]+)(?:\s(.*))?"

root = Node(nothing, Dict(), "/", 0)
curr = root

for line in eachline(ARGS[1])
    m = match(output_re, line)
    if isnothing(m.captures[1])
        _, size, name = m
        if size == "dir"
            size = 0
        else
            size = parse(Int64, size)
        end

        curr.children[name] = Node(curr, Dict(), name, size)
    else
         _, cmd, target = m
        if cmd == "cd"
            if target == ".."
                global curr = curr.parent
            elseif target == "/"
                global curr = root
            else
                global curr = curr.children[target]
            end
        end
    end
end


function filter_dirs_by_size(node::Node, filter, dirs = nothing)
    if isnothing(dirs)
        dirs = Dict{Node, Int64}()
    end

    size = getsize(node)

    if node.size == 0 && filter(size)
        dirs[node] = size
    end

    for child in values(node.children)
        filter_dirs_by_size(child, filter, dirs)
    end
    dirs
end

# part 1
println(sum(values(filter_dirs_by_size(root, s -> s <= 100000))))

# part 2
space_needed = 30000000 - (70000000 - getsize(root))
candidates = collect(filter_dirs_by_size(root, s -> s >= space_needed))
sort!(candidates, by = x -> x[2])
println(candidates[1][2])
