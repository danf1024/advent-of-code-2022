struct Coordinates
    i::Int64
    j::Int64
end

struct Face
    num::Int64
    pos::Coordinates
    adj::Vector{Tuple{Int64, Int64}}
end

mutable struct Position
    abs::Coordinates
    orientation::Int64
    face::Union{Nothing, Face}
end

Position(c::Coordinates, o::Int64) = Position(c, o, nothing)
Position(x::Int64, y::Int64, z::Int64, f::Face) = Position(Coordinates(x, y), z, f)

function rotate_right(p::Position)::Nothing
    p.orientation += 1
    if p.orientation > 3 p.orientation %= 4; end
    nothing
end

function rotate_left(p::Position)::Nothing
    p.orientation -= 1
    if p.orientation < 0 p.orientation = 3; end
    nothing
end

FACE_SIZE = 50
#FACE_SIZE = 4

function ahead(p::Position, faces::Dict{Int64, Face})::Tuple{Coordinates, Face}
    if p.orientation == 0
        face = p.abs.j == p.face.pos.j + FACE_SIZE - 1 ? faces[p.face.adj[1][1]] : p.face
        Coordinates(p.abs.i, p.abs.j+1), face
    elseif p.orientation == 1
        face = p.abs.i == p.face.pos.i + FACE_SIZE - 1 ? faces[p.face.adj[2][1]] : p.face
        Coordinates(p.abs.i+1, p.abs.j), face
    elseif p.orientation == 2
        face = p.abs.j == p.face.pos.j ? faces[p.face.adj[3][1]] : p.face
        Coordinates(p.abs.i, p.abs.j-1), face
    elseif p.orientation == 3
        face = p.abs.i == p.face.pos.i ? faces[p.face.adj[4][1]] : p.face
        Coordinates(p.abs.i-1, p.abs.j), face
    end
end

function wrapped_position(p::Position, board::Matrix{Char})::Coordinates
    if p.orientation == 0
        Coordinates(p.abs.i, findfirst(c -> c != ' ', board[p.abs.i,:]))
    elseif p.orientation == 1
        Coordinates(findfirst(c -> c != ' ', board[:, p.abs.j]), p.abs.j)
    elseif p.orientation == 2
        Coordinates(p.abs.i, findlast(c -> c != ' ', board[p.abs.i,:]))
    elseif p.orientation == 3
        Coordinates(findlast(c -> c != ' ', board[:, p.abs.j]), p.abs.j)
    end
end

transforms = Dict{Tuple{Int64, Int64}, Function}(
    (0, 0) => c -> Coordinates(FACE_SIZE - c.i + 1, FACE_SIZE),
    (0, 1) => c -> Coordinates(FACE_SIZE, c.i),
    (0, 2) => c -> Coordinates(c.i, 1),
    (0, 3) => c -> Coordinates(1, FACE_SIZE - c.i + 1),
    (1, 0) => c -> Coordinates(c.j, FACE_SIZE),
    (1, 1) => c -> Coordinates(FACE_SIZE, FACE_SIZE - c.j + 1),
    (1, 2) => c -> Coordinates(FACE_SIZE - c.j + 1, 1),
    (1, 3) => c -> Coordinates(1, c.j),
    (2, 0) => c -> Coordinates(c.i, FACE_SIZE),
    (2, 1) => c -> Coordinates(FACE_SIZE, FACE_SIZE - c.i + 1),
    (2, 2) => c -> Coordinates(FACE_SIZE - c.i + 1, 1),
    (2, 3) => c -> Coordinates(1, c.i),
    (3, 0) => c -> Coordinates(FACE_SIZE - c.j + 1, FACE_SIZE),
    (3, 1) => c -> Coordinates(FACE_SIZE, c.j),
    (3, 2) => c -> Coordinates(c.j, 1),
    (3, 3) => c -> Coordinates(1, FACE_SIZE - c.j + 1),
)

function cube_wrapped_position(p::Position, board::Matrix{Char}, faces::Dict{Int64, Face})::Tuple{Coordinates, Face, Int64}
    #println("cube_wrapped_position $(p.abs.i), $(p.abs.j)")
    #println("p.face $(p.face.num) $(p.face.pos.i), $(p.face.pos.j)")
    next_face, edge = p.face.adj[p.orientation + 1]
    new_face = faces[next_face]

    c = abs_to_face_relative_coordinates(p)
    #println("abs $(c.i), $(c.j)")
    c = transforms[(p.orientation, edge)](c)
    new_orientation = edge + 2
    if new_orientation > 3 new_orientation %= 4; end
    #println("new_orientation: $new_orientation")

    #println("abs rotated $(c.i), $(c.j)")

    #println("new_face $(new_face.pos.i) $(new_face.pos.j)")
    new_abs = face_relative_to_abs_coordinates(c, new_face)
    #println("new_abs $(new_abs.i), $(new_abs.j)")

    new_abs, new_face, new_orientation
end

function abs_to_face_relative_coordinates(p::Position)::Coordinates
    Coordinates(p.abs.i - p.face.pos.i + 1, p.abs.j - p.face.pos.j + 1)
end

function face_relative_to_abs_coordinates(c::Coordinates, face::Face)::Coordinates
    Coordinates(c.i + face.pos.i - 1, c.j + face.pos.j - 1)
end

function advance_position(p::Position, board::Matrix{Char}, faces::Dict{Int64, Face})::Bool
    a, face = ahead(p, faces)

    if a.i > 0 && a.i <= size(board, 1) && a.j > 0 && a.j <= size(board, 2) && board[a.i, a.j] != ' '
        #println("ahead $(a.i), $(a.j), $(face.num)")
        c = a
        orientation = p.orientation
    else
        # c = wrapped_position(p, board)
        c, face, orientation = cube_wrapped_position(p, board, faces)
    end

    if board[c.i, c.j] != '#'
        #println("advancing to $(c.i), $(c.j), $orientation")
        p.abs = c
        p.orientation = orientation
        p.face = face
        true
    else
        false
    end
end


function main(filename)
    str_map, inst_str = split(chomp(read(filename, String)), "\n\n")
    map_lines = split(str_map, "\n")

    width = maximum(length, map_lines)

    board = permutedims(hcat([collect(x * repeat(' ', width - length(x))) for x in map_lines]...))

    # sample
    #=faces = Dict{Int64, Face}(
        1 => Face(
            1,
            Coordinates(1, 2 * FACE_SIZE + 1),
            [(6, 0), (4, 3), (3, 3), (2, 3)],
        ),
        2 => Face(
            2,
            Coordinates(FACE_SIZE + 1, 1),
            [(3, 2), (5, 1), (6, 1), (1, 3)],
        ),
        3 => Face(
            3,
            Coordinates(FACE_SIZE + 1, FACE_SIZE + 1),
            [(4, 2), (5, 2), (2, 0), (1, 2)],
        ),
        4 => Face(
            4,
            Coordinates(FACE_SIZE + 1, 2 * FACE_SIZE + 1),
            [(6, 3), (5, 3), (3, 0), (1, 1)],
        ),
        5 => Face(
            5,
            Coordinates(2 * FACE_SIZE + 1, 2 * FACE_SIZE + 1),
            [(6, 2), (2, 1), (3, 1), (4, 1)],
        ),
        6 => Face(
            6,
            Coordinates(2 * FACE_SIZE + 1, 3 * FACE_SIZE + 1),
            [(1, 0), (2, 2), (5, 0), (4, 0)],
        )
    )=#

    # input
    faces = Dict{Int64, Face}(
        1 => Face(
            1,
            Coordinates(1, FACE_SIZE + 1),
            [(2, 2), (3, 3), (4, 2), (6, 2)],
        ),
        2 => Face(
            2,
            Coordinates(1, 2 * FACE_SIZE + 1),
            [(5, 0), (3, 0), (1, 0), (6, 1)],
        ),
        3 => Face(
            3,
            Coordinates(FACE_SIZE + 1, FACE_SIZE + 1),
            [(2, 1), (5, 3), (4, 3), (1, 1)],
        ),
        4 => Face(
            4,
            Coordinates(2 * FACE_SIZE + 1, 1),
            [(5, 2), (6, 3), (1, 2), (3, 2)],
        ),
        5 => Face(
            5,
            Coordinates(2 * FACE_SIZE + 1, FACE_SIZE + 1),
            [(2, 0), (6, 0), (4, 0), (3, 1)],
        ),
        6 => Face(
            6,
            Coordinates(3 * FACE_SIZE + 1, 1),
            [(5, 1), (2, 3), (1, 3), (4, 1)],
        )
    )

    inst_re = r"([0-9]+)(R|L)?"
    instructions = Vector{Union{Int64, Char}}()
    for m in eachmatch(inst_re, inst_str)
        push!(instructions, parse(Int64, m.captures[1]))
        if !isnothing(m.captures[2])
            push!(instructions, collect(m.captures[2])[1])
        end
    end

    pos = Position(1, findfirst(c -> c == '.', board[1,:]), 0, faces[1])

    for inst in instructions
        #println("from ($(pos.abs.i), $(pos.abs.j), $(pos.orientation)) $inst")
        if inst == 'R'
            rotate_right(pos)
        elseif inst == 'L'
            rotate_left(pos)
        else
            for i in 1:inst
                if !advance_position(pos, board, faces) break; end
            end
        end
        #println("stopped ($(pos.abs.i), $(pos.abs.j), $(pos.orientation))")
    end

    println(1000 * pos.abs.i + 4 * pos.abs.j + pos.orientation)
end

main(ARGS[1])
