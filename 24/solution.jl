struct Blizzard
    num::Int64
    i::Int64
    j::Int64
    dir::Char
end

mutable struct Space
    i::Int64
    j::Int64
    blizzards::Dict{Int64, Blizzard}
end

Space(i, j) = Space(i, j, Dict())

function is_blizzard(a::Space)::Bool
    !isempty(a.blizzards)
end

function manhattan_dist(a::Space, b::Space)::Int64
    abs(a.i - b.i) + abs(a.j - b.j)
end

function min_dist(open_set::Set{Space}, fscore::Dict{Space, Int64})::Space
    m = nothing
    for s in open_set
        if isnothing(m) || fscore[s] < fscore[m]
            m = s
        end
    end
    m
end

function get_space(
    blizzards::Vector{Blizzard},
    t::Int64,
    dim::Tuple{Int64, Int64}
)::Matrix{Space}
    space = Matrix{Space}([Space(i, j) for i in 1:dim[1], j in 1:dim[2]])
    println("get_space t=$t")
    for b in blizzards
        if b.dir == '>'
            new_i = b.i
            new_j = b.j + (t % dim[2])
            if new_j > dim[2] new_j %= dim[2]; end
        elseif b.dir == 'v'
            new_i = b.i + (t % dim[1])
            new_j = b.j
            if new_i > dim[1] new_i %= dim[1]; end
        elseif b.dir == '<'
            new_i = b.i
            new_j = b.j - (t % dim[2])
            if new_j < 1 new_j += dim[2]; end
        elseif b.dir == '^'
            new_i = b.i - (t % dim[1])
            new_j = b.j
            if new_i < 1 new_i += dim[1]; end
        end
        space[new_i, new_j].blizzards[b.num] = b
    end
    space
end

function print_space(space::Matrix{Space}, curr::Space)::Nothing
    for i in 1:size(space, 1) + 2
        for j in 1:size(space, 2) + 2
            if i == 1 || j == 1
                if j == 2
                    print(".")
                else
                    print("#")
                end
            elseif i == size(space, 1) + 2 || j == size(space, 2) + 2
                if j == size(space, 2) + 1
                    print(".")
                else
                    print("#")
                end
            else
                sp = space[i-1,j-1]
                if is_blizzard(sp)
                    if length(sp.blizzards) == 1
                        print(first(values(sp.blizzards)).dir)
                    else
                        print(length(sp.blizzards))
                    end
                else
                    print(".")
                end
            end
        end
        println()
    end
    nothing
end

function neighbors(s::Space, space::Matrix{Space}, dest::Space)::Vector{Space}
    nbors = Vector{Space}()
    if s.i == size(space, 1) && s.j == size(space, 2)
        push!(nbors, dest)
    end

    if s.i > 1
        sp = space[s.i-1,s.j]
        if !is_blizzard(sp) push!(nbors, sp); end
    end

    if s.i < size(space, 1)
        sp = space[s.i+1,s.j]
        if !is_blizzard(sp) push!(nbors, sp); end
    end

    if s.j > 1
        sp = space[s.i,s.j-1]
        if !is_blizzard(sp) push!(nbors, sp); end
    end

    if s.j < size(space, 2) && s.i > 0
        sp = space[s.i,s.j+1]
        if !is_blizzard(sp) push!(nbors, sp); end
    end
    nbors
end

function main(filename)::Int64
    init = permutedims(hcat([collect(ea) for ea in readlines(filename)]...))

    sizei = size(init, 1) - 2
    sizej = size(init, 2) - 2
    space_map = Dict{Int64, Matrix{Space}}()

    blizzards = Vector{Blizzard}()
    for (bnum, indx) in enumerate(findall(c -> in(c, Set(['>', '<', 'v', '^'])), init))
        c = init[indx]
        i = indx[1] - 1
        j = indx[2] - 1
        blizzard = Blizzard(bnum, i, j, c)
        push!(blizzards, blizzard)
    end

    start = Space(0, 1)
    dest = Space(sizei + 1, sizej)
    gscore = Dict{Space, Int64}(start => 0)
    fscore = Dict{Space, Int64}(start => manhattan_dist(Space(1, 1), Space(sizei, sizej)) + 2)
    open_set = Set{Space}([start])

    while !isempty(open_set)
        #println("i=$i")
        curr = min_dist(open_set, fscore)
        #println("visiting $curr")
        curr_dist = gscore[curr]

        if curr === dest
            return curr_dist
        end

        t = curr_dist + 1
        if haskey(space_map, t)
            space = space_map[t]
        else
            space = get_space(blizzards, t, (sizei, sizej))
            space_map[t] = space
        end

        if t == 308
            println(curr)
        end

        print_space(space, curr)
        nbors = neighbors(curr, space, dest)

        if isempty(nbors)
            #println("waiting")
            gscore[curr] += 1
            fscore[curr] += 1
            continue
        end

        pop!(open_set, curr)

        for n in nbors
            if n === dest
                return curr_dist + 1
            end

            tent_gscore = gscore[curr] + 1
            if tent_gscore < get(gscore, n, Inf)
                gscore[n] = tent_gscore
                fscore[n] = tent_gscore + manhattan_dist(n, Space(sizei, sizej)) + 1
            end
            push!(open_set, n)
        end
    end
    Inf
end

println(main(ARGS[1]))
