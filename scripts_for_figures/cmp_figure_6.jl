
include("/Users/dariabystrova/Documents/GitHub/approximatingBNPpriors/scripts_for_figures/common_functions.jl")
include("/Users/dariabystrova/Documents/GitHub/approximatingBNPpriors/scripts_for_figures/FK_sampling_functions.jl")
include("/Users/dariabystrova/Documents/GitHub/approximatingBNPpriors/scripts_for_figures/SB_sampling_functions.jl")

using JLD, GibbsTypePriors, DataFramesMeta, RCall, Optim, OptimTestProblems, StatsBase



function EV_of_number_of_clusters_NGG(n,H,par_vec)
    pk_ngg = GibbsTypePriors.Pkn_NGG.(1:n, n, par_vec[1], par_vec[2])
    E_ngg =  pk_ngg|> ar -> map(*, ar, 1:n) |> sum
    x = ((1:n).-E_ngg).^2
    V_ngg = pk_ngg |> ar -> map(*, ar, x) |> sum
    pk_nggm = Pkn_NGGM_precomp.(1:n,n,H,par_vec[1], par_vec[2], [pk_ngg])
    E_nggm =  pk_nggm|> ar -> map(*, ar, 1:n) |> sum
    x_nggm = ((1:n).-E_nggm).^2
    V_nggm = pk_nggm |> ar -> map(*, ar, x_nggm) |> sum
    return [E_ngg, V_ngg] , [E_nggm, V_nggm]
end


function EV_of_number_of_clusters_NGG_approx(n,par_vec)
    pk_ngg_approx = Pkn_NGG_pred_approx(n,par_vec[1], par_vec[2])
    E_ngg_approx =  pk_ngg_approx|> ar -> map(*, ar, 1:n) |> sum
    x = ((1:n).-E_ngg_approx).^2
    V_ngg_approx = pk_ngg_approx |> ar -> map(*, ar, x) |> sum
    return E_ngg_approx, V_ngg_approx
end


function EV_of_number_of_clusters_NGG_FK(n,par_vec,M)
    pk_ngg_fk = Pkn_NGG_FK_fast(n,par_vec[1], par_vec[2],M)
    E_ngg_fk =  pk_ngg_fk|> ar -> map(*, ar, 1:n) |> sum
    x = ((1:n).-E_ngg_fk).^2
    V_ngg_fk = pk_ngg_fk |> ar -> map(*, ar, x) |> sum
    return E_ngg_fk, V_ngg_fk
end



function EV_of_number_of_clusters_NGG_FK_slow(n,par_vec,M)
    println([par_vec[2],par_vec[1]])
    pk_ngg_fk = Pkn_NGG_FK(n,par_vec[1], par_vec[2], 250; runs = 2*10^2)
    E_ngg_fk =  pk_ngg_fk|> ar -> map(*, ar, 1:n) |> sum
    x = ((1:n).-E_ngg_fk).^2
    V_ngg_fk = pk_ngg_fk |> ar -> map(*, ar, x) |> sum
    return E_ngg_fk, V_ngg_fk
end



function EV_of_number_of_clusters_NGG_FK_fast(n,par_vec,M)
    println([par_vec[2],par_vec[1]])
    pk_ngg_fk = Pkn_NGG_FK_fast(n,par_vec[1], par_vec[2], 250; runs = 2*10^2)
    E_ngg_fk =  pk_ngg_fk|> ar -> map(*, ar, 1:n) |> sum
    x = ((1:n).-E_ngg_fk).^2
    V_ngg_fk = pk_ngg_fk |> ar -> map(*, ar, x) |> sum
    return E_ngg_fk, V_ngg_fk
end


sigma = collect(range(0.05,0.99, length=10))
alpha = collect(exp.(range(log(1), log(200), length =10)))
grid = collect(Iterators.product(alpha, sigma))
n=100
grid_vec = vec(grid)
H = 250

save("/Users/dariabystrova/Documents/GitHub/approximatingBNPpriors/saves_for_figures/figure_6_6.jld", "grid_vec" ,grid_vec)


EV = EV_of_number_of_clusters_NGG.(n,H,grid_vec)
EV_NGG= first.(EV)
EV_NGGM = last.(EV)

## Expectation and variance for NGG
save("/Users/dariabystrova/Documents/GitHub/approximatingBNPpriors/saves_for_figures/figure_6_1.jld", "NGG", EV_NGG)

## Expectation and variance for NGG multinomial
save("/Users/dariabystrova/Documents/GitHub/approximatingBNPpriors/saves_for_figures/figure_6_3.jld", "NGGM", EV_NGGM)

## Expectation and variance for NGG predictive approximation

EV_NGG_approx = EV_of_number_of_clusters_NGG_approx.(n,grid_vec)

save("/Users/dariabystrova/Documents/GitHub/approximatingBNPpriors/saves_for_figures/figure_6_2.jld", "NGG_approx", EV_NGG_approx)



function EV_of_number_of_clusters_NGG_SB(par_vec,n,M)
    println([par_vec[1], par_vec[2]])
    pk_ngg_sb= Pkn_NGG_SB_1(n,par_vec[1], par_vec[2],M)
    E_ngg_sb =  pk_ngg_sb|> ar -> map(*, ar, 1:n) |> sum
    x = ((1:n).-E_ngg_sb).^2
    V_ngg_sb = pk_ngg_sb |> ar -> map(*, ar, x) |> sum
    return E_ngg_sb, V_ngg_sb
end


sigma = collect(range(0.05,0.99, length=10))
#alpha = collect(range(0.05,20, length=5))
alpha = collect(exp.(range(log(1), log(200), length =10)))
grid = collect(Iterators.product(alpha, sigma))
#grid_borders = vcat(collect(Iterators.product(alpha[1], sigma)),collect(Iterators.product(alpha[nb], sigma)), collect(Iterators.product(alpha, sigma[1])),collect(Iterators.product(alpha, sigma[ns])))
n=100
grid_vec = vec(grid)[11:100]
H = 250


EV_NGG_SB = EV_of_number_of_clusters_NGG_SB.(grid_vec,n,H)

save("/Users/dariabystrova/Documents/GitHub/approximatingBNPpriors/saves_for_figures/figure_6_5.jld", "NGG_FSB", EV_NGG_SB)



## Expectation and variance for NGG FK approximation
## As FK is computationally expensive algorithm we use the reduced grid for computing Expectation and Variance
reduced_grid = filter(x -> (x[2] > 0.25)&&(x[1] > 3), grid_vec)


EV_NGG_FK_ = EV_of_number_of_clusters_NGG_FK_fast.(n,reduced_grid,250)
EV_NGG_FK__fast = DataFrame(EV_NGG_FK_)
DF_NGG_FK_fast = DataFrame(Exp = EV_NGG_FK__fast[1],Var =EV_NGG_FK__fast[2], beta = first.(reduced_grid), sigma = last.(reduced_grid))
DF_NGG_FK_fast.std = sqrt.(DF_NGG_FK_fast.Var)
DF_NGG_FK_fast.beta_log= log.(DF_NGG_FK_fast.beta)

DF_NGG_FK_reduced = EV_NGG_FK__fast[9:64,:]
reduced_grid_red =  reduced_grid[9:64]


DF_NGG_FK = DataFrame(Exp = DF_NGG_FK_reduced[1],Var =DF_NGG_FK_reduced[2], beta = first.(reduced_grid_red), sigma = last.(reduced_grid_red))
DF_NGG_FK.std = sqrt.(DF_NGG_FK.Var)
DF_NGG_FK.beta_log= log.(DF_NGG_FK.beta)


save("/Users/dariabystrova/Documents/GitHub/approximatingBNPpriors/saves_for_figures/figure_6_4.jld", "DF_NGG_FK", DF_NGG_FK)




### more tine consuming computatoin for FK (using reduced grid and coombination of fast&slow algorithms)

reduced_grid = filter(x -> (x[2] > 0.25)&&(x[1] > 3), grid_vec)
EV_NGG_FK_slow = EV_of_number_of_clusters_NGG_FK_slow.(n,reduced_grid,250)


EV_NGG_FK__slow = DataFrame(EV_NGG_FK_slow)
EV_NGG_FK__slow = DataFrame(Exp = EV_NGG_FK__slow[1],Var =EV_NGG_FK__slow[2], beta = first.(reduced_grid), sigma = last.(reduced_grid))
EV_NGG_FK__slow.std = sqrt.(EV_NGG_FK__slow.Var)
EV_NGG_FK__slow.beta_log= log.(EV_NGG_FK__slow.beta)

DF_NGG_FK_reduced_slow = EV_NGG_FK__slow[9:64,:]
reduced_grid_red =  reduced_grid[9:64]


DF_NGG_FK_slow = DataFrame(Exp = DF_NGG_FK_reduced_slow[1],Var =DF_NGG_FK_reduced_slow[2], beta = first.(reduced_grid_red), sigma = last.(reduced_grid_red))
DF_NGG_FK_slow.std = sqrt.(DF_NGG_FK_slow.Var)
DF_NGG_FK_slow.beta_log= log.(DF_NGG_FK_slow.beta)


save("/Users/dariabystrova/Documents/GitHub/approximatingBNPpriors/saves_for_figures/figure_6_4_2.jld", "DF_NGG_FK_slow", DF_NGG_FK_slow)
