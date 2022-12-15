paths = map(
    x -> map(y -> map(z -> parse(Int64, z), split(y, ",")), split(x, " -> ")),
    readlines(ARGS[1])
)

leftx = 0 # minimum(map(r -> minimum(map(p -> p[1], r)), paths)) - 1000
rightx = maximum(map(r -> maximum(map(p -> p[1], r)), paths)) + 1000
bottomy = maximum(map(r -> maximum(map(p -> p[2], r)), paths)) + 2

M = falses(bottomy + 1, rightx - leftx + 1)
M[end,:] .= 1

for path in paths
    for i in 1:(length(path) - 1)
        start = path[i]
        stop = path[i+1]
        if start[1] == stop[1]
            if start[2] < stop[2]
                row_range = start[2]+1:stop[2]+1
            else
                row_range = start[2]+1:-1:stop[2]+1
            end
            M[row_range,start[1]-leftx+1] .= 1
        elseif start[2] == stop[2]
            if start[1] < stop[1]
                col_range = start[1]-leftx+1:stop[1]-leftx+1
            else
                col_range = start[1]-leftx+1:-1:stop[1]-leftx+1
            end
            M[start[2]+1,col_range] .= 1
        else
            println("not good")
        end
    end
end

# display(M)
at_rest = 0
abyss = false

while !abyss
    i = 1
    j = 500 - leftx + 1
    #println("dropping sand")
    while true
        #if i == bottomy + 1
        #    println("into bottom abyss")
        #    global abyss = true
        #    break
        if !M[i+1,j]
            #println("falling down to $(i+1), $j")
            i += 1
        #elseif j == 1
        #    println("into left abyss")
        #    global abyss = true
        #    break
        elseif !M[i+1,j-1]
            #println("falling down left to $(i+1), $(j-1)")
            i += 1
            j -= 1
        #elseif j == rightx
        #    println("into right abyss")
        #    global abyss = true
        #    break
        elseif !M[i+1,j+1]
            #println("falling down right to $(i+1), $(j+1)")
            i += 1
            j += 1
        else # blocked
            #println("stopped at $i, $j")
            M[i,j] = 1
            if i == 1 && j == 500 - leftx + 1
                global abyss = true
            end

            global at_rest += 1
            break
        end
    end
end

println(at_rest)
