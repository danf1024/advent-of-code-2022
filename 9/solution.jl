struct Point
    x::Int64
    y::Int64
end

mutable struct Knot
    loc::Point
    id::Int64
    next::Union{Nothing, Knot}
end

function adjacent(a::Knot, b::Knot)
    adjacent(a.loc, b.loc)
end

function adjacent(a::Point, b::Point)
    b == a ||
    b == Point(a.x, a.y + 1) ||
    b == Point(a.x, a.y - 1) ||
    b == Point(a.x + 1, a.y) ||
    b == Point(a.x - 1, a.y) ||
    b == Point(a.x + 1, a.y + 1) ||
    b == Point(a.x + 1, a.y - 1) ||
    b == Point(a.x - 1, a.y + 1) ||
    b == Point(a.x - 1, a.y - 1)
end

function move_to_follow(leader::Knot, follower::Knot)
    a = leader.loc
    b = follower.loc

    if a.y > b.y
        one_step(follower, "U")
    elseif a.y < b.y
        one_step(follower, "D")
    end

    if a.x > b.x
        one_step(follower, "R")
    elseif a.x < b.x
        one_step(follower, "L")
    end
end

function one_step(k::Knot, dir::AbstractString)
    a = k.loc
    if dir == "U"
        k.loc = Point(a.x, a.y + 1)
    elseif dir == "R"
        k.loc = Point(a.x + 1, a.y)
    elseif dir == "D"
        k.loc = Point(a.x,  a.y - 1)
    elseif dir == "L"
        k.loc = Point(a.x - 1, a.y)
    end
end

N = 10

head = Knot(Point(0, 0), 0, nothing)
k = head

for i in 1:N-1
    knot = Knot(Point(0, 0), i, nothing)
    k.next = knot
    global k = knot
end

tail = k
tail_visited = Set([tail.loc])

for line in eachline(ARGS[1])
    dir, n = split(line)
    for i in 1:parse(Int64, n)
        one_step(head, dir)
        curr = head
        next = head.next
        while !isnothing(next)
            if !adjacent(curr, next)
                move_to_follow(curr, next)
            end
            curr = next
            next = curr.next
        end

        push!(tail_visited, curr.loc)
    end
end

println(length(tail_visited))
