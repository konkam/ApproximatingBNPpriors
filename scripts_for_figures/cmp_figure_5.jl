
using JLD, GibbsTypePriors, DataFramesMeta, RCall, Optim, OptimTestProblems, StatsBase, Optim, OptimTestProblems

include("/Users/dariabystrova/Documents/GitHub/approximatingBNPpriors/scripts_for_figures/common_functions.jl")


R"library(tidyverse)
library(latex2exp)
library(viridis)
"


function approximation_prior_distribution(beta_,sigma,N,Nt)
    Pkn_numeric_ = GibbsTypePriors.Pkn_2PD.(1:N, N, beta_, sigma)
    Pkn_order2_ = GibbsTypePriors.Pkn_PY_pred_approx(N, beta_, sigma)
    Pkn_PY_Mult = GibbsTypePriors.Pkn_PYM.(1:N, N, Nt, beta_, sigma)
    R"SB_PY = Prior_on_K_SB_PY($beta_, $sigma, $N, $Nt, runs= 2*10^2)
    pk_sb_py = SB_PY$pk"
    @rget pk_sb_py
    df= DataFrame(Pkn_numeric = Pkn_numeric_,
                  Pkn_order2 = Pkn_order2_,
                  Pkn_PYM = Pkn_PY_Mult,
                  Pkn_SB  = pk_sb_py)
       return df
end



R"
StickBreakingPY <- function(alpha,sigma, N) {
  a<- rep(1-sigma,N-1)
  b<- alpha+ sigma*(1:N-1)
  V <- rbeta(N-1 , a, b)
  p    <- vector('numeric',length=N)
  p[1] <- V[1]
  for(l in 2:(N - 1))p[l] <- prod(1 - V[1:(l - 1)])*V[l]
  p[N] <- prod(1 - V)
  p
  return(p)
}

Prior_on_K_SB_PY<- function(alpha, sigma, N_s=100,N_tr=100, runs=10^4 ){
  array_nc<-c()
  i=1
  while (i<=runs){
    weights_PY<- StickBreakingPY(alpha,sigma,N_tr)
    c <- sample(1:N_tr,size=N_s, replace=TRUE, prob=weights_PY )
    n_c<- length(unique(c))
    array_nc[i]<- n_c
    i=i+1
  }
  p_k = tibble(k=as.numeric(names(table(array_nc))),
               p_k=as.vector(table(array_nc))/sum(table(array_nc)))
  p_zeros= tibble(k=(1:N_s)[!1:N_s%in%p_k$k],
                  p_k=rep(0,length((1:N_s)[!1:N_s%in%p_k$k])))
  pk_padded= rbind(p_k, p_zeros)%>% arrange(k)
  E_k=sum((1:N_s) *(pk_padded$p_k))
  V_k = sum((((1:N_s) - E_k)^2) *(pk_padded$p_k))
  return(list(pk=pk_padded$p_k, Ek= E_k,Vk=V_k ))
}
"

n=100
β= 1.0
ntr=250
sigma_vec= [0.25,0.75]
DF_all_100_py = map(x ->approximation_prior_distribution(β,x,n,ntr),sigma_vec)



n=100
β= 10.0
ntr=250
sigma_vec= [0.25,0.75]
DF_all_10_100_py = map(x ->approximation_prior_distribution(β,x,n,ntr),sigma_vec)



DF_100_250_py = [DF_all_100_py,DF_all_10_100_py]


save("/Users/dariabystrova/Documents/GitHub/approximatingBNPpriors/saves_for_figures/figure_5.jld", "DF_100_250_py" ,DF_100_250_py)
