buffer = Vector{Char}()
# const MARKER_LENGTH = 4
const MARKER_LENGTH = 14

open(ARGS[1], "r") do io
    while !eof(io)
        c = read(io, Char)

        if length(buffer) == MARKER_LENGTH pop!(buffer); end

        pushfirst!(buffer, c)

        if length(Set(buffer)) == MARKER_LENGTH
            println(position(io))
            break
        end
    end
end
