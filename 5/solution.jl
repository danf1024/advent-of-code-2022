inst_regex = r"move\s([0-9]+)\sfrom\s([0-9]+)\sto\s([0-9]+)"

crates = []
crate_parsing = true
mode_9001 = true

for line in eachline(ARGS[1])
    if crate_parsing
        line_crates = [strip(line[i:i+1], [' ', '[']) for i in 1:4:length(line)]

        try
            parse(Int64, line_crates[1])
            global crate_parsing = false
            continue
        catch e
            if !isa(e, ArgumentError) throw(e); end
        end

        while length(line_crates) > length(crates) push!(crates, []) end;

        for (i, c) in pairs(line_crates)
            if isempty(c) continue; end

            pushfirst!(crates[i], c)
        end
    elseif !isempty(line)
        num, src, dest = map(x -> parse(Int64, x), match(inst_regex, line))
        stack = []
        if mode_9001
            for i in 1:num pushfirst!(stack, pop!(crates[src])); end
        else
            for i in 1:num push!(stack, pop!(crates[src])); end
        end
        push!(crates[dest], stack...)
    end
end

println(join([ea[end] for ea in crates]))
