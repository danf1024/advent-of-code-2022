function snafu_to_decimal(s::String)::Int64
    chars = collect(s)
    val = 0
    for i in length(chars):-1:1
        pow = length(chars) - i
        c = chars[i]

        if c == '-'
            val -= 5^pow
        elseif c == '='
            val -= 2*5^pow
        else
            val += parse(Int64, c)*5^pow
        end
    end
    val
end

function carry(chars::Vector{Char}, pow::Int64, excess::Int64)::Nothing
    n = chars[pow+2]
    if n == '2'
        carry(chars, pow+1, 1)
        chars[pow+2] = '='
    elseif n == '1'
        chars[pow+2] = '2'
    elseif n == '0'
        chars[pow+2] = '1'
    elseif n == '-'
        chars[pow+2] = '0'
    elseif n == '='
        chars[pow+2] = '-'
    end

    if excess == 2
        chars[pow+1] = '='
    else
        chars[pow+1] = '-'
    end

    nothing
end

function decimal_to_snafu(d::Int64)::String
    rem = d
    len = Int(floor(log(5, rem))) + 2
    chars = map(x -> string(x)[1], zeros(len))

    while rem > 0
        pow = Int(floor(log(5, rem)))
        n = rem ÷ 5^pow
        rem %= 5^pow

        if n <= 2
            chars[pow+1] = string(n)[1]
        else
            carry(chars, pow, 5 - n)
        end
    end

    lstrip(join(reverse(chars)), '0')
end

function main(filename)
    dsum = sum(map(l -> snafu_to_decimal(l), readlines(filename)))
    println(dsum)
    println(decimal_to_snafu(dsum))
end

main(ARGS[1])
