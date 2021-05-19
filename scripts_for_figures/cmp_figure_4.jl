
using JLD, GibbsTypePriors, DataFramesMeta, RCall, Optim, OptimTestProblems, StatsBase

include("/Users/dariabystrova/Documents/GitHub/approximatingBNPpriors/scripts_for_figures/common_functions.jl")
include("/Users/dariabystrova/Documents/GitHub/approximatingBNPpriors/scripts_for_figures/FK_sampling_functions.jl")
include("/Users/dariabystrova/Documents/GitHub/approximatingBNPpriors/scripts_for_figures/SB_sampling_functions.jl")



DF_1000 =load("/Users/dariabystrova/Documents/GitHub/approximatingBNPpriors/saves_for_figures/figure_2.jld")
DF_1000_250 = DF_1000["DF_1000_250"]

using DataFrames, DataFramesMeta, RCall, Optim, OptimTestProblems
R"library(tidyverse)
library(latex2exp)
library(viridis)
"


function approximation_prior_distribution_precomp(beta,sigma,N,Nt,sigma_arr,df)
    i = findall(x->x==sigma, sigma_arr)
    Pkn_numeric_ = df[i[1]].Pkn_numeric
    Pkn_order2_ = df[i[1]].Pkn_order2
    Pkn_NGGMult = Pkn_NGGM_precomp.(1:N,N,Nt,beta,sigma, [Pkn_numeric_])
    Pkn_FK_ =  Pkn_NGG_FK(N, beta, sigma, Nt; runs=2*10^2)
    Pkn_SB_  = Pkn_NGG_SB_1(N,beta,sigma,Nt; runs=2*10^2)
    df= DataFrame(Pkn_numeric = Pkn_numeric_,
                  Pkn_order2 = Pkn_order2_,
                  Pkn_NGGM = Pkn_NGGMult,
                  Pkn_FK = Pkn_FK_,
                  Pkn_SB = Pkn_SB_)
       return df
end





n=1000
β= 1.0
ntr=1000
sigma_vec= [0.25,0.75]
DF_all_1_1000_1000 = map(x ->approximation_prior_distribution_precomp(β,x,n,ntr,sigma_vec,DF_1000_250[1]),sigma_vec)



n=1000
β= 10.0
ntr=1000
sigma_vec= [0.25,0.75]
#DF_all_1000_10 = map(x ->approximation_prior_distribution(β,x,n,ntr,sigma_vec),sigma_vec)
DF_all_10_1000_1000 = map(x ->approximation_prior_distribution_precomp(β,x,n,ntr,sigma_vec,DF_1000_250[2]),sigma_vec)




DF_1000_1000 = [DF_all_1_1000_1000,DF_all_10_1000_1000]


save("/Users/dariabystrova/Documents/GitHub/approximatingBNPpriors/saves_for_figures/figure_4.jld", "DF_1000_1000" ,DF_1000_1000)
