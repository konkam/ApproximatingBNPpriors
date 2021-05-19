using JLD, GibbsTypePriors, DataFramesMeta, RCall, Optim, OptimTestProblems, StatsBase

include("/Users/dariabystrova/Documents/GitHub/approximatingBNPpriors/scripts_for_figures/common_functions.jl")


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


function EV_of_number_of_clusters_PY(n,par_vec)
    #pk_py = Pkn_NGG.(1:n, n, par_vec[1], par_vec[2])
    E =  GibbsTypePriors.E_PY(n, par_vec[1], par_vec[2]) |> Float64
    V  = GibbsTypePriors.V_PY(n, par_vec[1], par_vec[2])  |> Float64
    return E,V
end


sigma = collect(range(0.05,0.99, length=10))
alpha = collect(exp.(range(log(1), log(200), length =10)))
grid = collect(Iterators.product(alpha, sigma))
n=100
grid_vec = vec(grid)
H= 250

save("/Users/dariabystrova/Documents/GitHub/approximatingBNPpriors/saves_for_figures/figure_7_5.jld", "grid_vec" ,grid_vec)


## PY exact


EV_PY = EV_of_number_of_clusters_PY.(n, grid_vec)

DF_PY= DataFrame(Exp = first.(EV_PY),Var =last.(EV_PY), beta = first.(grid_vec), sigma = last.(grid_vec))
DF_PY.std = sqrt.(DF_PY.Var)
DF_PY.beta_log = log.(DF_PY.beta)

DF_PY

save("/Users/dariabystrova/Documents/GitHub/approximatingBNPpriors/saves_for_figures/figure_7_1.jld", "DF_PY" ,DF_PY)


## PY multinomial process

function EV_of_number_of_clusters_PYM(n,H,par_vec)
    pk_pym = GibbsTypePriors.Pkn_PYM.(1:n, n, H,  par_vec[1], par_vec[2])
    E_pym =  pk_pym|> ar -> map(*, ar, 1:n) |> sum
    x = ((1:n).-E_pym).^2
    V_pym = pk_pym |> ar -> map(*, ar, x) |> sum
    return E_pym, V_pym
end



EV_PYM = EV_of_number_of_clusters_PYM.(n,H,grid_vec)


DF_PYM= DataFrame(Exp = first.(EV_PYM),Var =last.(EV_PYM), beta = first.(grid_vec), sigma = last.(grid_vec))
DF_PYM.std = sqrt.(DF_PYM.Var)
DF_PYM.beta_log = log.(DF_PYM.beta)

DF_PYM


save("/Users/dariabystrova/Documents/GitHub/approximatingBNPpriors/saves_for_figures/figure_7_2.jld", "DF_PYM" ,DF_PYM)

## PY predictive approximation

function EV_of_number_of_clusters_PY_approx(n,par_vec)
    pk_approx = GibbsTypePriors.Pkn_PY_pred_approx(n, par_vec[1], par_vec[2])
    E_approx =  pk_approx|> ar -> map(*, ar, 1:n) |> sum
    x = ((1:n).-E_approx).^2
    V_approx = pk_approx |> ar -> map(*, ar, x) |> sum
    return E_approx, V_approx
end


EV_PY_apr= EV_of_number_of_clusters_PY_approx.(n, grid_vec)


DF_PY_apr= DataFrame(Exp = first.(EV_PY_apr),Var =last.(EV_PY_apr), beta = first.(grid_vec), sigma = last.(grid_vec))
DF_PY_apr.std = sqrt.(DF_PY_apr.Var)
DF_PY_apr.beta_log = log.(DF_PY_apr.beta)

DF_PY_apr

save("/Users/dariabystrova/Documents/GitHub/approximatingBNPpriors/saves_for_figures/figure_7_3.jld", "DF_PY_apr" ,DF_PY_apr)

##PY stick-breaking approximation


function EV_of_number_of_clusters_PY_SB(n,H, par_vec)
    R"SB_PY = Prior_on_K_SB_PY($(par_vec[1]),$(par_vec[2]), $n, $H, runs= 2*10^2)
    E_py_sb = SB_PY$Ek
    V_py_sb = SB_PY$Vk"
    @rget E_py_sb
    @rget V_py_sb
    return E_py_sb, V_py_sb
end


EV_PY_sb= EV_of_number_of_clusters_PY_SB.(n,H,  grid_vec)


DF_PY_sb= DataFrame(Exp = first.(EV_PY_sb),Var =last.(EV_PY_sb), beta = first.(grid_vec), sigma = last.(grid_vec))
DF_PY_sb.std = sqrt.(DF_PY_sb.Var)
DF_PY_sb.beta_log = log.(DF_PY_sb.beta)

DF_PY_sb


save("/Users/dariabystrova/Documents/GitHub/approximatingBNPpriors/saves_for_figures/figure_7_4.jld", "DF_PY_sb" ,DF_PY_sb)
