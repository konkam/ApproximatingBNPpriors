using JLD, GibbsTypePriors, DataFramesMeta, RCall, Optim, OptimTestProblems, StatsBase

include("/Users/dariabystrova/Documents/GitHub/approximatingBNPpriors/scripts_for_figures/common_functions.jl")
include("/Users/dariabystrova/Documents/GitHub/approximatingBNPpriors/scripts_for_figures/FK_sampling_functions.jl")
include("/Users/dariabystrova/Documents/GitHub/approximatingBNPpriors/scripts_for_figures/SB_sampling_functions.jl")


load("/Users/dariabystrova/Documents/GitHub/approximatingBNPpriors/saves_for_figures/figure_3.jld")


function approximation_prior_distribution_precomp(beta,sigma,N,Nt,sigma_arr,df)
    i = findall(x->x==sigma, sigma_arr)
    Pkn_numeric_ = df[i[1]].Pkn_numeric
    Pkn_order2_ = df[i[1]].Pkn_order2
    Pkn_FK_ =  Pkn_NGG_FK(N, beta, sigma, Nt; runs=2*10^2)
    Pkn_SB_  = Pkn_NGG_SB_1(N,beta,sigma,Nt; runs=2*10^2)
    Pkn_NGGMult = Pkn_NGGM_precomp.(1:N,N,Nt,beta,sigma, [Pkn_numeric_])
        df= DataFrame(Pkn_numeric = Pkn_numeric_,
                  Pkn_order2 = Pkn_order2_,
                  Pkn_NGGM = Pkn_NGGMult,
                  Pkn_FK = Pkn_FK_,
                  Pkn_SB = Pkn_SB_)
       return df
end


# truncation 1000
DF_all_100=DF_100[1]
n=100
β= 1.0
ntr=1000
sigma_vec= [0.25,0.75]
DF_1_100_1000 = map(x ->approximation_prior_distribution_precomp(β,x,n,ntr,sigma_vec,  DF_all_100),sigma_vec)


DF_all_10_100_1000=DF_100[2]

n=100
β= 10.0
ntr=1000
sigma_vec= [0.25,0.75]
DF_10_1000_1000 = map(x ->approximation_prior_distribution_precomp(β,x,n,ntr,sigma_vec, DF_all_10_100_1000),sigma_vec)


DF_100_1000 = [DF_1_100_1000,DF_10_1000_1000]


save("/Users/dariabystrova/Documents/GitHub/approximatingBNPpriors/saves_for_figures/figure_3.jld", "DF_100_1000" ,DF_100_1000)
