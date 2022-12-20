abstract type Point; end

mutable struct Air <: Point
    x::Int64
    y::Int64
    z::Int64
    is_encapsulated::Union{Nothing, Bool}
end

Air(x, y, z) = Air(x, y, z, nothing)

mutable struct Water <: Point
    x::Int64
    y::Int64
    z::Int64
end

function is_air(p::Air) true; end
function is_air(p::Water) false; end
function is_water(p::Water) true; end
function is_water(p::Air) false; end

function is_edge(p::Point, space::Array{Point})::Bool
    if p.x == 1 || p.y == 1 || p.z == 1 return true; end
    if p.x == size(space, 1) || p.y == size(space, 2) || p.z == size(space, 3) return true; end

    false
end

function neighbors(p::Point, space::Array{Point})::Vector{Point}
    [
        space[p.x+1,p.y,p.z],
        space[p.x-1,p.y,p.z],
        space[p.x,p.y+1,p.z],
        space[p.x,p.y-1,p.z],
        space[p.x,p.y,p.z+1],
        space[p.x,p.y,p.z-1],
    ]
end

function path_out(visited::Set{Point}, p::Air, space::Array{Point})::Bool
    if is_edge(p, space) return true; end
    if !isnothing(p.is_encapsulated) && p.is_encapsulated return false; end

    push!(visited, p)

    for n in neighbors(p, space)
        if in(n, visited) || is_water(n) continue; end

        if (!isnothing(n.is_encapsulated) && !n.is_encapsulated) || path_out(visited, n, space)
            p.is_encapsulated = false
            return true
        end
    end

    p.is_encapsulated = true
    false
end

function is_free_air(from::Water, p::Point, space::Array{Point})::Bool
    visited::Set{Point} = Set([from])
    is_air(p) && path_out(visited, p, space)
end

function surface_count(p::Water, space::Array{Point})::Int64
    count = 0
    if p.x == size(space, 1) || is_free_air(p, space[p.x+1,p.y,p.z], space)
        count += 1
    end

    if p.x == 1 || is_free_air(p, space[p.x-1,p.y,p.z], space)
        count += 1
    end

    if p.y == size(space, 2) || is_free_air(p, space[p.x,p.y+1,p.z], space)
        count += 1
    end

    if p.y == 1 || is_free_air(p, space[p.x,p.y-1,p.z], space)
        count += 1
    end

    if p.z == size(space, 3) || is_free_air(p, space[p.x,p.y,p.z+1], space)
        count += 1
    end

    if p.z == 1 || is_free_air(p, space[p.x,p.y,p.z-1], space)
        count += 1
    end

    count
end

function surface_area(points::Vector{Tuple{Int64, Int64, Int64}})::Int64
    xmax = maximum(p -> p[1], points)
    ymax = maximum(p -> p[2], points)
    zmax = maximum(p -> p[3], points)

    space::Array{Point} = [Air(i, j, k) for i=1:xmax+1, j=1:ymax+1, k=1:zmax+1]

    drops::Vector{Point} = []
    for (x, y, z) in points
        w = Water(x+1, y+1, z+1)
        space[x+1,y+1,z+1] = w
        push!(drops, w)
    end

    sum(p -> surface_count(p, space), drops)
end

points = map(x -> Tuple(map(y -> parse(Int64, y), split(x, ","))), readlines(ARGS[1]))
println(surface_area(points))
