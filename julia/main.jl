#! /usr/bin/julia
include("Data.jl")

const T = 1
const C = 2
const W = 3

const EPSILON = 1e-15

const REINSERTION = 1
const OR_OPT2     = 2
const OR_OPT3     = 3
const SWAP        = 4
const TWO_OPT     = 5

dimension, c = get_instance_info()

function subseq_load(s::Array{Int64, 1}, seq::Array{Float64, 3})

    for i in 1:dimension+1
        k = 1 - i -(i==0)#convert(Int64, i==0)

        seq[i,i,T] = 0.0
        seq[i,i,C] = 0.0
        seq[i,i,W] = i!=0#convert(Float64, i != 0)

        for j in i+1:dimension+1
            j_prev = j-1
            
            seq[i,j,T] = c[s[j_prev], s[j]] + seq[i,j_prev,T]
            seq[i,j,C] = seq[i,j,T] + seq[i,j_prev,C]
            seq[i,j,W] = j+k
        end
    end

end

function construction(alpha::Float64)
    s = [1]
    cList = [2:dimension;]

    r = 1
    while length(cList) > 0
        sort!(cList, by= i -> c[i,r])

        i = convert(Int64, floor(length(cList)*alpha + 1))
        cN = cList[rand(1:i)]
        push!(s, cN)
        r = cN
        deleteat!(cList, findfirst(x->x==cN, cList))

        println(cList)
    end

    return s
end

function RVND(s::Array{Int64, 1}, seq::Array{Float64, 3})

end

function perturb(sl::Array{Int64, 1})
    s = copy(sl)
    return s
end

function GILS_RVND(Imax::Int64, Iils::Int64, R)
    cost_best = Inf
    s_best = []

    """
    s = Array{Int64, 1}()
    for i in 1:dimension
        push!(s, i)
    end
    push!(s, 1)
    println(s)

    subseq = zeros(dimension+1, dimension+1, 3)
    subseq_load(s, subseq)

    println(subseq)
    println(subseq[1, dimension+1, C])
    """
    for i in 1:Imax
        alpha = R[rand(1:26)]
        s = construction(alpha)
        sl = copy(s)
        subseq_load(s, subseq)

        rvnd_cost_best = subseq[0,dimension,C] - EPSILON

        iterILS = 0
        while iterILS < Iils
            RVND(s, subseq)
            rvnd_cost_crnt = subseq[0,dimension,C] - EPSILON
            if rvnd_cost_crnt < rvnd_cost_best
                rvnd_cost_best = rvnd_cost_crnt
                sl = copy(s)
                iterILS = 0
            end

            s = perturb(sl)
            subseq_load(s, subseq)

            iterILS += 1
        end

        subseq_load(sl, subseq)
        sl_cost = subseq[0,dimension,C] - EPSILON

        if sl_cost < cost_best
            s_best = sl
            cost_best = sl_cost
        end
        exit(0)
    end
end

function main()
    println(dimension)
    println(c)

    R = [0.00, 0.01, 0.02, 0.03, 0.04, 0.05, 0.06, 0.07, 0.08, 0.09, 0.10, 0.11, 0.12, 
         0.13, 0.14, 0.15, 0.16, 0.17, 0.18, 0.19, 0.20, 0.21, 0.22, 0.23, 0.24, 0.25] 
    
    Imax = 10
    Iils = min(dimension, 100)

    GILS_RVND(Imax, Iils, R)

end

main()
