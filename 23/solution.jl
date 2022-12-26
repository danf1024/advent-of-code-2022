
abstract type Space; end

mutable struct Elf <: Space
    i::Int64
    j::Int64
end

struct Ground <: Space
    i::Int64
    j::Int64
end

function is_ground(s::Elf) false; end
function is_ground(s::Ground) true; end
function is_elf(s::Elf) true; end
function is_elf(s::Ground) false; end

function adjacent(elf::Elf, space::Matrix{Space})::Vector{Space}
    [
        space[elf.i - 1, elf.j - 1],
        space[elf.i - 1, elf.j],
        space[elf.i - 1, elf.j + 1],
        space[elf.i, elf.j + 1],
        space[elf.i + 1, elf.j + 1],
        space[elf.i + 1, elf.j],
        space[elf.i + 1, elf.j - 1],
        space[elf.i, elf.j - 1],
    ]
end

expanse = 200

function draw_space(space::Matrix{Space})::Nothing
    imin = findfirst(r -> any(is_elf, r), eachrow(space)) - 1
    imax = findlast(r -> any(is_elf, r), eachrow(space)) + 1
    jmin = findfirst(c -> any(is_elf, c), eachcol(space)) - 1
    jmax = findlast(c -> any(is_elf, c), eachcol(space)) + 1

    for i in imin:imax
        for j in jmin:jmax
            s = space[i, j]
            is_elf(s) ? print("#") : print(".")
        end
        println()
    end

    nothing
end

function count_empty_ground(space::Matrix{Space})::Int64
    imin = findfirst(r -> any(is_elf, r), eachrow(space))
    imax = findlast(r -> any(is_elf, r), eachrow(space))
    jmin = findfirst(c -> any(is_elf, c), eachcol(space))
    jmax = findlast(c -> any(is_elf, c), eachcol(space))

    count(is_ground, space[imin:imax, jmin:jmax])
end

function main(filename)
    init = permutedims(hcat([collect(ea) for ea in readlines(filename)]...))
    elf_pos = findall(c -> c == '#', init)

    space = Matrix{Space}([Ground(i, j) for i in 1:(2 * expanse + size(init, 1)), j in 1:(2 * expanse + size(init, 2))])

    elves = []
    for indx in elf_pos
        i, j = Tuple(indx)
        new_i = expanse + i
        new_j = expanse + j
        elf = Elf(new_i, new_j)
        space[new_i, new_j] = elf
        push!(elves, elf)
    end

    #draw_space(space)

    adj_checks = [(1, 2, 3, 2), (5, 6, 7, 6), (7, 8, 1, 8), (3, 4, 5, 4)]
    check_num = 1

    #for r in 1:10
    r = 1
    while true
        proposals = Vector{Union{Nothing, Ground}}()
        prop_set = Set{Ground}()
        dupes = Set{Ground}()
        for elf in elves
            #println("checking elf at $(elf.i), $(elf.j)")
            adj = adjacent(elf, space)
            #println("adj = $adj")
            if all(is_ground, adj)
                #println("Elf at $(elf.i), $(elf.j) proposing nothing")
                push!(proposals, nothing)
                continue
            end

            proposed = false
            for i in check_num:(check_num + 3)
                if i > 4 i %= 4; end
                x, y, z, dir = adj_checks[i]
                #println("x, y, z = $x, $y, $z")
                #println("adj [$(adj[x]), $(adj[y]), $(adj[z])]")
                if all(is_ground, [adj[x], adj[y], adj[z]])
                    prop = adj[dir]
                    #println("Elf at $(elf.i), $(elf.j) proposing $(prop.i), $(prop.j)")
                    push!(proposals, prop)
                    if in(prop, prop_set)
                        push!(dupes, prop)
                    else
                        push!(prop_set, prop)
                    end
                    proposed = true
                    break
                end
            end

            if !proposed
                #println("Elf at $(elf.i), $(elf.j) had nowhere to go; proposed nothing")
                push!(proposals, nothing)
            end
        end

        non_nothing_proposlas = filter(x -> !isnothing(x), proposals)
        if length(non_nothing_proposlas) == 0 break; end

        space = Matrix{Space}([Ground(i, j) for i in 1:(2 * expanse + size(init, 1)), j in 1:(2 * expanse + size(init, 2))])

        for (elf, new_space) in zip(elves, proposals)
            if !isnothing(new_space) && !in(new_space, dupes)
                elf.i = new_space.i
                elf.j = new_space.j
            end

            space[elf.i, elf.j] = elf
        end

        println("after round $r")
        #draw_space(space)

        check_num += 1
        if check_num > 4 check_num %= 4; end

        r += 1
    end

    println(r)
    #println(count_empty_ground(space))
end

main(ARGS[1])
