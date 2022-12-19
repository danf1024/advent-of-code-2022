mutable struct Valve
    id::String
    flow::Int64
    adj::Vector{Valve}
end

line_re = r"([A-Z]{2}).*rate=([0-9]+);.*valve[s]?\s(.*)"

valves = Dict{String, Valve}()
edges = Dict{String, Vector{AbstractString}}()
unopened = Set{Valve}()

for line in eachline(ARGS[1])
    id, rate_str, adj_str = match(line_re, line)
    rate = parse(Int64, rate_str)
    adj_ids = split(adj_str, ", ")

    if rate != 0
        prime_id = "$id'"
        valve_prime = Valve(prime_id, rate, [])
        valves[prime_id] = valve_prime
        edges[prime_id] = adj_ids
        push!(unopened, valve_prime)
        adj = [valve_prime]
    else
        adj = []
    end

    valves[id] = Valve(id, 0, adj)
    edges[id] = adj_ids
end

for (id, adj_ids) in edges
    valve = valves[id]
    for adj_id in adj_ids
        push!(valve.adj, valves[adj_id])
    end
end

c = 0

total_time = 30
function next_best_move(
    from::Valve,
    minute::Int64,
    eval::Int64,
    path::Vector{String},
    opened::Set{Valve},
    unopened::Set{Valve}
)::Tuple{Vector{String}, Int64}
    #println("call $(from.id), min=$minute, eval=$eval, path=$path")
    global c += 1
    if c % 50000 == 0 print("."); end

    time_remaining = total_time - minute

    new_eval = eval + from.flow * time_remaining
    new_path = vcat(path, from.id)

    if from.flow > 0
        opened_this_minute = true
        new_opened = union(opened, [from])
        new_unopened = setdiff(unopened, [from])
    else
        opened_this_minute = false
        new_opened = opened
        new_unopened = unopened
    end

    if minute == total_time || isempty(new_unopened) return new_path, new_eval; end

    max_eval = nothing
    max_path = nothing
    best_eval = nothing

    for v in from.adj
        if (!isempty(path) && v.id == path[end]) || in(v, opened) continue; end

        next_best = () -> next_best_move(
            v,
            minute + 1,
            new_eval,
            new_path,
            new_opened,
            new_unopened,
        )

        if isnothing(max_eval)
            max_path, max_eval = next_best()
        else
            if isnothing(best_eval)
                best_eval = best_outcome(new_eval, unopened, time_remaining, opened_this_minute ? 2 : 1)
            end

            if max_eval >= best_eval break; end

            branch_path, branch_eval = next_best()

            if branch_eval > max_eval
                max_eval = branch_eval
                max_path = branch_path
            end
        end
    end

    if isnothing(max_eval)
        new_path, new_eval
    else
        max_path, max_eval
    end
end

function best_outcome(eval::Int64, unopened::Set{Valve}, time_remaining::Int64, next_open::Int64)::Int64
    if time_remaining < next_open + 1 return eval; end

    flows = sort(map(y -> y.flow, collect(unopened)), rev=true)
    times = (time_remaining-next_open):-2:1
    eval + sum(map(prod, zip(flows, times)))
end

using Dates
start = now()
println(next_best_move(valves["AA"], 0, 0, Vector{String}(), Set{Valve}(), unopened))
println(now() - start)
