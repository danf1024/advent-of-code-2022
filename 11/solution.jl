mutable struct Monkey
    id::Int64
    items::Vector{Int64}
    operation::Function
    mod::Int64
    true_dest::Int64
    false_dest::Int64
    inspection_count::Int64
end

function parse_monkey(s)
    lines = split(s, "\n")
    id = parse(Int64, split(lines[1])[end][begin:end-1])
    items = map(x -> parse(Int64, x), split(split(lines[2], ":")[end], ","))

    op_str = strip(split(lines[3], "=")[end])
    operation = eval(Meta.parse("old -> $op_str"))

    mod = parse(Int64, split(lines[4])[end])
    true_dest = parse(Int64, split(lines[5])[end]) + 1
    false_dest = parse(Int64, split(lines[6])[end]) + 1

    Monkey(id, items, operation, mod, true_dest, false_dest, 0)
end

monkeys = map(
    lines -> parse_monkey(lines),
    split(chomp(read(open(ARGS[1], "r"), String)), "\n\n")
)

reducer = x -> x ÷ 3
reducer = x -> x % prod(map(m -> m.mod, monkeys))

function take_turn(monkey::Monkey)
    while !isempty(monkey.items)
        item = popfirst!(monkey.items)
        monkey.inspection_count += 1
        new_item = monkey.operation(item)
        new_item = reducer(new_item)
        if new_item % monkey.mod == 0
            push!(monkeys[monkey.true_dest].items, new_item)
        else
            push!(monkeys[monkey.false_dest].items, new_item)
        end
    end
end


N = 10000
check = Set([1, 20, 1000, 2000, 3000, 4000, 5000, 6000, 7000, 8000, 9000, 10000])

for i in 1:N
    for monkey in monkeys take_turn(monkey); end
    if in(i, check)
        println("== After round $i ==")
        for monkey in monkeys
            println("Monkey $(monkey.id) inspected items $(monkey.inspection_count) times.")
        end
        println()
    end
end

monkeys_by_activity = sort(monkeys, by=m -> -1 * m.inspection_count)
println(monkeys_by_activity[1].inspection_count * monkeys_by_activity[2].inspection_count)
