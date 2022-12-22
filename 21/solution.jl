mutable struct Monkey
    name::String
    operation::Union{Nothing, Function}
    lhs::Union{Nothing, String}
    rhs::Union{Nothing, String}
    terms::Dict{String, Int128}
    value::Union{Nothing, Int128}
    deps::Set{Monkey}
end

function ready(m::Monkey)::Bool
    if !isnothing(m.value) return true; end

    haskey(m.terms, m.lhs) && haskey(m.terms, m.rhs)
end

function evaluate(m::Monkey)::Nothing
    if !isnothing(m.value) return; end

    m.value = m.operation(m.terms[m.lhs], m.terms[m.rhs])
    nothing
end

function getvalue(target::Monkey, monkeys::Dict{String, Monkey}, node_set::Set{Monkey})::Rational{Int128}
    if !isnothing(target.value) return Rational(target.value); end

    while !isempty(node_set)
        monkey = pop!(node_set)
        evaluate(monkey)
        if monkey === target
            return Rational(monkey.value)
        end

        for dep in monkey.deps
            dep.terms[monkey.name] = monkey.value
            if ready(dep)
                push!(node_set, dep)
            end
        end
    end
    -Inf
end

function parse_monkeys(filename)::Tuple{Dict{String, Monkey}, Set{Monkey}}
    line_re = r"([a-z]{4}):\s(?:([0-9]+)|([a-z]{4})\s([\+\-\*/])\s([a-z]{4}))"

    edges = Dict{String, Vector{String}}()
    monkeys = Dict{String, Monkey}()
    start_monkeys = Set{Monkey}()

    for line in eachline(filename)
        name, value_str, lhs, op_str, rhs = match(line_re, line)
        value = isnothing(value_str) ? nothing : parse(Int128, value_str)
        op = isnothing(op_str) ? nothing : eval(Meta.parse(op_str))
        monkey = Monkey(name, op, lhs, rhs, Dict{String, Int128}(), value, Set{Monkey}())
        monkeys[name] = monkey

        if !isnothing(value)
            push!(start_monkeys, monkey)
        else
            if !haskey(edges, lhs)
                edges[lhs] = []
            end
            push!(edges[lhs], name)

            if !haskey(edges, rhs)
                edges[rhs] = []
            end
            push!(edges[rhs], name)
        end
    end

    for (m, deps) in edges
        push!(monkeys[m].deps, map(ea -> monkeys[ea], deps)...)
    end

    monkeys, start_monkeys
end

function part1(filename)
    monkeys, start_monkeys = parse_monkeys(filename)

    println(Integer(getvalue(monkeys["root"], monkeys, start_monkeys)))
end

function depends_on(monkey::Monkey, other_monkey::Monkey)::Bool
    if monkey === other_monkey return true; end

    for dep in other_monkey.deps
        if depends_on(monkey, dep) return true; end
    end
    false
end

function apply_inverse(
    operation::Function,
    x::Rational{Int128},
    y::Rational{Int128},
    invert::Bool
)::Rational{Int128}
    if operation === +
        x - y
    elseif operation === -
        invert ? y - x : x + y
    elseif operation === *
        x / y
    elseif operation === /
        invert ? y / x : x * y
    end
end

function part2(filename)
    monkeys, start_monkeys = parse_monkeys(filename)

    root = monkeys["root"]
    humn = monkeys["humn"]

    lhs = monkeys[root.lhs]
    rhs = monkeys[root.rhs]

    if depends_on(lhs, humn)
        expr = lhs
        constant = getvalue(rhs, monkeys, start_monkeys)
    else
        expr = rhs
        constant = getvalue(lhs, monkeys, start_monkeys)
    end

    while expr !== humn
        lhs = monkeys[expr.lhs]
        rhs = monkeys[expr.rhs]
        op = expr.operation

        if depends_on(lhs, humn)
            expr = lhs
            value = getvalue(rhs, monkeys, start_monkeys)
            constant = apply_inverse(op, constant, value, false)
        else
            expr = rhs
            value = getvalue(lhs, monkeys, start_monkeys)
            constant = apply_inverse(op, constant, value, true)
        end
    end

    println(Integer(constant))
end

part1(ARGS[1])
part2(ARGS[1])
