mutable struct Node
    value::Int128
    prev::Union{Nothing, Node}
    next::Union{Nothing, Node}
end

function print_list(head::Node)::Nothing
    node = head
    while true
        print(node.value)
        node = node.next
        if node === head break; end
        print(", ")
    end
    println()
end

function move_right(n::Node, num::Int128)::Nothing
    for i in 1:num
        next = n.next
        prev = n.prev

        n.next = next.next
        n.prev = next
        next.next.prev = n

        next.prev = prev
        next.next = n
        prev.next = next
    end
end

function move_left(n::Node, num::Int128)::Nothing
    for i in 1:num
        next = n.next
        prev = n.prev

        n.next = prev
        n.prev = prev.prev
        prev.prev.next = n

        prev.next = next
        prev.prev = n
        next.prev = prev
    end
end

function construct_list(filename::String)::Vector{Node}
    nums = map(x -> parse(Int128, x), readlines(filename))
    nums .*= 811589153

    nodes = []
    prev = nothing
    for v in nums
        n = Node(v, prev, nothing)
        if !isnothing(prev)
            prev.next = n
        end
        prev = n
        push!(nodes, n)
    end

    nodes[begin].prev = nodes[end]
    nodes[end].next = nodes[begin]

    nodes
end

function mix_list(nodes::Vector{Node})
    for n in nodes
        moves = abs(n.value) % (length(nodes) - 1)

        if n.value > 0
            move_right(n, moves)
        elseif n.value < 0
            move_left(n, moves)
        end

        #print_list(nodes[begin])
    end
end

function find_coordinates(head::Node)::Int128
    node = head
    seen_zero = false
    c = 0
    total = 0

    while true
        if seen_zero
            c += 1
            if c == 1000 || c == 2000 || c == 3000
                total += node.value
            end
            if c == 3000 break; end
        end

        if node.value == 0
            seen_zero = true
        end

        node = node.next
    end

    total
end

function main(filename::String)
    nodes = construct_list(filename)
    head = nodes[begin]
    #print_list(head)

    for i in 1:10
        println(".")
        mix_list(nodes)
        #print_list(head)
    end


    println(find_coordinates(head))
end

main(ARGS[1])
