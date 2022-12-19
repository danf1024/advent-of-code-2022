struct Point
    x::Int64
    y::Int64
end

abstract type Rock; end

mutable struct Rock1 <: Rock
    points::Vector{Point}
end

mutable struct Rock2 <: Rock
    points::Vector{Point}
end

mutable struct Rock3 <: Rock
    points::Vector{Point}
end

mutable struct Rock4 <: Rock
    points::Vector{Point}
end

mutable struct Rock5 <: Rock
    points::Vector{Point}
end


function new_rock(n)
    if n == 1
        Rock1([
             Point(0, 0),
             Point(1, 0),
             Point(2, 0),
             Point(3, 0),
        ])
    elseif n == 2
        Rock2([
            Point(0, 1),
            Point(1, 0),
            Point(1, 1),
            Point(1, 2),
            Point(2, 1),
        ])
    elseif n == 3
        Rock3([
            Point(0, 0),
            Point(1, 0),
            Point(2, 0),
            Point(2, 1),
            Point(2, 2),
        ])
    elseif n == 4
        Rock4([
            Point(0, 0),
            Point(0, 1),
            Point(0, 2),
            Point(0, 3),
        ])
    elseif n == 5
        Rock5([
            Point(0, 0),
            Point(0, 1),
            Point(1, 0),
            Point(1, 1),
        ])
    end
end

function left_edge(rock::Union{Rock1, Rock3})::Vector{Point}
    [rock.points[1]]
end

function left_edge(rock::Rock2)::Vector{Point}
    [rock.points[1], rock.points[2], rock.points[4]]
end

function left_edge(rock::Rock4)::Vector{Point}
    rock.points
end

function left_edge(rock::Rock5)::Vector{Point}
    [rock.points[1], rock.points[2]]
end

function right_edge(rock::Rock1)::Vector{Point}
    [rock.points[4]]
end

function right_edge(rock::Rock2)::Vector{Point}
    [rock.points[2], rock.points[4], rock.points[5]]
end

function right_edge(rock::Rock3)::Vector{Point}
    [rock.points[3], rock.points[4], rock.points[5]]
end

function right_edge(rock::Rock4)::Vector{Point}
    rock.points
end

function right_edge(rock::Rock5)::Vector{Point}
    [rock.points[3], rock.points[4]]
end

function bottom_edge(rock::Rock1)::Vector{Point}
    rock.points
end

function bottom_edge(rock::Rock2)::Vector{Point}
    [rock.points[1], rock.points[2], rock.points[5]]
end

function bottom_edge(rock::Rock3)::Vector{Point}
    [rock.points[1], rock.points[2], rock.points[3]]
end

function bottom_edge(rock::Rock4)::Vector{Point}
    [rock.points[1]]
end

function bottom_edge(rock::Rock5)::Vector{Point}
    [rock.points[1], rock.points[3]]
end

function top(rock::Rock)::Int64
    maximum(map(p -> p.y, rock.points))
end

function add(a::Point, b::Point)::Point
    Point(a.x + b.x, a.y + b.y)
end

function spawn(rock::Rock, point::Point)::Nothing
    map!(p -> add(p, point), rock.points, rock.points)
    nothing
end

function move_right(rock::Rock)::Nothing
    map!(p -> Point(p.x + 1, p.y), rock.points, rock.points)
    nothing
end

function move_left(rock::Rock)::Nothing
    map!(p -> Point(p.x - 1, p.y), rock.points, rock.points)
    nothing
end

function move_down(rock::Rock)::Nothing
    map!(p -> Point(p.x, p.y - 1), rock.points, rock.points)
    nothing
end

jets = map(c -> c == '>', collect(chomp(read(ARGS[1], String))))

rows = [trues(7)]

function print_falling(rock::Rock)::Nothing
    rock_coords = Set([(p.x, p.y) for p in rock.points])
    for i in length(rows):-1:1
        if i == 1
            println("+-------+")
        else
            print("|")
            row = rows[i]
            for j in 1:length(row)
                if in((j-1, i-1), rock_coords)
                    print("@")
                elseif row[j]
                    print("#")
                else
                    print(".")
                end
            end
            print("|")
            println()
        end
    end
    nothing
end

n = 1
j = 1
stopped = 0
d = Dict()
while stopped < 10000
    #if stopped % 10000 == 0
    #    println(stopped)
    #end

    rock = new_rock(n)
    y_spawn = findlast(any, rows) + 3
    spawn(rock, Point(2, y_spawn))

    for x in 1:(top(rock) - length(rows) + 1)
        push!(rows, falses(7))
    end

    # print_falling(rock)

    is_jet = true
    while true
        if is_jet
            jet = jets[j]
            if !haskey(d, (j, n)) d[(j, n)] = []; end
            push!(d[(j, n)], ((findlast(any, rows) - 1, stopped)))
            if jet
                blocked = false
                for p in right_edge(rock)
                    if p.x == 6 || rows[p.y+1][p.x+2]
                        blocked = true
                        break
                    end
                end

                if !blocked move_right(rock); end
            else
                blocked = false
                for p in left_edge(rock)
                    if p.x == 0 || rows[p.y+1][p.x]
                        blocked = true
                        break
                    end
                end

                if !blocked move_left(rock); end
            end
            global j += 1
            if j > length(jets) global j %= length(jets); end
        else
            blocked = false
            for p in bottom_edge(rock)
                if p.y == 1 || rows[p.y][p.x+1]
                    blocked = true
                    break
                end
            end

            if !blocked
                move_down(rock)
            else
                for p in rock.points
                    rows[p.y+1][p.x+1] = 1
                end
                global stopped += 1
                break
            end
        end
        is_jet = !is_jet
        #print_falling(rock)
    end
    global n += 1
    if n > 5 global n %= 5; end
end

println(findlast(any, rows) - 1)
display(d)
