using Distributions, FreqTables, DataFrames



function MvInv_slow(u, a, κ, γ, M)
    N(x) =  a*κ^γ/SpecialFunctions.gamma(1-γ)*Γ(-γ,κ*x)
    ξ = cumsum(rand(Exponential(1), M))
    J = Array{Float64}(undef, M)
    higherbound = 10^3
    for i in eachindex(J)
        obj(x) = N(x) - ξ[i]
        # println((higherbound, obj.((8eps(), higherbound))))
        J[i] = find_zero(obj, (8eps(), higherbound))
        higherbound = J[i]
    end
    return J
end

function MvInv_slow_arb(u, a, κ, γ, M)
    N(x) =  a*κ^γ*Float64(real(1/gamma(CC(1-γ))*gamma(CC(-γ), CC(κ*x))))
    ξ = cumsum(rand(Exponential(1), M))
    J = Array{Float64}(undef, M)
    higherbound = 10
    for i in eachindex(J)
        obj(x) = N(x) - ξ[i]
        J[i] = find_zero(obj, (8eps(), higherbound))
        higherbound = J[i]
    end
    return J
end


function MvInv_simple(u, a, kappa, gama, N, M)
    J = Array{Float64}(undef, M)
    x = -log.(range(exp(-1e-05), exp(-10), length = N))
    f =  a/ Float64(real(gamma(CC(1- gama)))) * (x.^(-(1+gama)).*exp.( - (u+kappa)*x))
    dx = diff(x)
    h = (f[2:end] + f[1:(end-1)])/2
    Mv = zeros(N)
    ξ = cumsum(rand(Exponential(1), M))
    for i in (N-1):-1:1
        Mv[i] = Mv[i+1] + dx[i]*h[i]
    end
    for i in eachindex(J)
        J[i] = x[argmin(Mv .> ξ[i])]
    end
    return J
end

function fill_v2(M, Mv, W,N, x)
    v = Array{Float64}(undef, M)
    iMv = N
    for i in 1:M
        while iMv > 0 && Mv[iMv] < W[i]
            iMv = iMv -1
        end
        v[i] = x[iMv + 1]
    end
    return(v)
end

function MvInv_D(u, a, kappa, gama, N, M)
    x = -log.(range(exp(-1e-05),exp(-10), length=N))
    f =  a/ Float64(real(gamma(GibbsTypePriors.CC(1- gama)))) * (x.^(-(1+gama)).*exp.( - (u+kappa)*x))
    dx = diff(x)
    h = (f[2:end] + f[1:(end-1)]) / 2
    Mv = append!(reverse(cumsum(reverse(dx.* h))),[0])
    dist = Exponential(1)
    W = rand(dist, M)
    W = cumsum(W)
    return fill_v2(M,Mv,W,N,x)
end

## functions to compute weights pk for different approximations (FK, stick-breaking)



function NGG_FK_weights_fast(β, σ, M)
    a = 1
    κ = (σ*a*β)^(1/σ)
    γ = σ
    # Js = MvInv_slow(0, a, κ, γ, M)
    Js = MvInv_simple(0, a, κ, γ, 10^4, M)
    # Js = MvInv_D(0, a, κ, γ, 10^4, M)
    # println(Js[end]/sum(Js))
    return Js ./ sum(Js)
end


function Pkn_NGG_FK_fast(n, β, σ, M; runs=10^4)
    array_clust_num = Array{Int64}(undef, runs)
    for i in 1:runs
        weights_NGG = NGG_FK_weights_fast(β, σ, M)
        c = wsample(1:M, weights_NGG, n, replace=true)
        n_c =  length(unique(c))
        array_clust_num[i] = n_c
    end
    return proportions(array_clust_num, n)
end

## slow version

function NGG_FK_weights(β, σ, M)
    a = 1
    #a =σ*β
    #println(a)
    κ = (σ*a*β)^(1/σ)
    γ = σ
    Js = MvInv_slow(0, a, κ, γ, M)
    # Js = MvInv_simple(0, a, κ, γ, 10^4, M)
    # Js = MvInv_D(0, a, κ, γ, 10^4, M)
    # println(Js[end]/sum(Js))
    return Js ./ sum(Js)
end

function Pkn_NGG_FK(n, β, σ, M; runs=10^4)
    array_clust_num = Array{Int64}(undef, runs)
    for i in 1:runs
        weights_NGG = NGG_FK_weights(β, σ, M)
        c = wsample(1:M, weights_NGG, n, replace=true)
        n_c =  length(unique(c))
        array_clust_num[i] = n_c
    end
    return proportions(array_clust_num, n)
end
