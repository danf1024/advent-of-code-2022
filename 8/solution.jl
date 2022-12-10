M = permutedims(
    hcat(
         map(
             x -> parse.(Int64, x),
             collect.(readlines(ARGS[1]))
        )...
    )
)

cummax = x -> accumulate(max, x)

colpad = fill(-1, size(M, 1), 1)
rowpad = fill(-1, 1, size(M, 2))

leftmax = hcat(colpad, mapslices(cummax, M, dims=[2])[:,1:end-1])
topmax = vcat(rowpad, mapslices(cummax, M, dims=[1])[1:end-1,:])
rightmax = reverse(hcat(colpad, mapslices(cummax, reverse(M, dims=2), dims=[2])[:,1:end-1]), dims=2)
bottommax = reverse(vcat(rowpad, mapslices(cummax, reverse(M, dims=1), dims=[1])[1:end-1,:]), dims=1)

leftvis = (M .- leftmax) .> 0
topvis = (M .- topmax) .> 0
rightvis = (M .- rightmax) .> 0
bottomvis = (M .- bottommax) .> 0

vis = leftvis .| topvis .| rightvis .| bottomvis
# part 1
println(sum(vis))

function scenic_score_2d(v, idx, size)
    forward = findfirst(v[idx+1:end])
    if isnothing(forward) forward = size - idx; end

    backward = findfirst(v[idx-1:-1:begin])
    if isnothing(backward) backward = idx - 1; end

    forward * backward
end

LR = Matrix(undef, size(M)...)
for col_idx in 1:size(M, 2)
    H = repeat(M[:,col_idx], 1, size(M, 2))
    B = (M .- H) .>= 0
    v = mapslices(v -> scenic_score_2d(v, col_idx, size(M, 2)), B, dims=[2])
    LR[:, col_idx] = v
end

UD = Matrix(undef, size(M)...)
for row_idx in 1:size(M, 1)
    H = repeat(M[row_idx,:], 1, size(M, 1))
    B = (M' .- H) .>= 0
    v = mapslices(v -> scenic_score_2d(v, row_idx, size(M, 1)), B, dims=[2])
    UD[row_idx, :] = v'
end

S = LR .* UD
println(maximum(S))

