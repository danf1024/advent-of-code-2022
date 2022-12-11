x = 1
clock = 1
inst = nothing
strength = 0
cycles_to_measure = Set([20, 60, 100, 140, 180, 220])
LINE_LENGTH = 40

open(ARGS[1], "r") do io
    while true
        if in(clock, cycles_to_measure)
            global strength += clock * x
        end

        draw_pos = mod1(clock, LINE_LENGTH) - 1
        if abs(x - draw_pos) <= 1
            print("#")
        else
            print(".")
        end

        if isnothing(inst)
            if eof(io) break; end

            global inst = readline(io)
            if inst == "noop"
                global inst = nothing
            end
        else
            _, v = split(inst)
            global x += parse(Int64, v)
            global inst = nothing
        end

        if draw_pos == LINE_LENGTH - 1 println() end;

        global clock += 1
    end
end

# part 1
println(strength)
