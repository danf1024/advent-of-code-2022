struct Point
    x::Int64
    y::Int64
end

function manhattan_dist(a::Point, b::Point)::Int64
    abs(a.x - b.x) + abs(a.y - b.y)
end

cov_range = 4000000
#cov_range = 20

function in_range_points(pos::Point, dist::Int64, y::Int64)::Union{Nothing, UnitRange}
    y_delta = abs(pos.y - y)
    if y_delta > dist return nothing; end

    x_range = dist - y_delta
    max(pos.x - x_range, 0):min(pos.x + x_range, cov_range)
end

line_re = r"x=(-?[0-9]+), y=(-?[0-9]+).*x=(-?[0-9]+), y=(-?[0-9]+)"

coverage = Vector{Union{Nothing, Vector{UnitRange}}}(nothing, cov_range+1)

for line in eachline(ARGS[1])
    x1, y1, x2, y2 = map(x -> parse(Int64, x), match(line_re, line))
    pos = Point(x1, y1)
    beacon = Point(x2, y2)

    if x2 >= 0 && x2 <= cov_range && y2 >= 0 && y2 <= cov_range
        if isnothing(coverage[x2+1])
            coverage[x2+1] = []
        end

        push!(coverage[x2+1], y2+1:y2+1)
    end

    dist = manhattan_dist(pos, beacon)

    Threads.@threads for i in 1:cov_range+1
        range = in_range_points(pos, dist, i-1)
        if isnothing(range) continue; end

        if isnothing(coverage[i])
            coverage[i] = []
        end

        push!(coverage[i], range)
    end
end

Threads.@threads for i in 1:cov_range+1
    cov = coverage[i]
    sort!(cov)

    a = 2
    b = 1

    while a <= length(cov)
        curr = cov[a]
        prev = cov[b]

        if curr.stop <= prev.stop
            a += 1
            continue
        end

        if curr.start > prev.stop + 1
            x = prev.stop + 1
            y = i - 1
            freq = x*4000000 + y
            println(freq)
            exit()
        end

        a += 1
        b = a - 1
    end
end
