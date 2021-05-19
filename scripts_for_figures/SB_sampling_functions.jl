
include("/Users/dariabystrova/Documents/GitHub/approximatingBNPpriors/scripts_for_figures/common_functions.jl")
include("/Users/dariabystrova/Documents/GitHub/approximatingBNPpriors/scripts_for_figures/FK_sampling_functions.jl")


using DataFrames, DataFramesMeta, RCall, Distributions, StatsBase
R"library(copula)"


function R_q(q, b, k_n, alpha)
    t1 = exp(- ((b/k_n)^alpha)*((1 + q^(1/alpha))^alpha - q))
    t2 =  ((q^(1/alpha))/(1+q^(1/alpha)))^(1-alpha)
    return t1*t2
end

function sample_xi_n(alpha, b, theta, k_n, n)
   u =  Uniform(0,1)
   g = Gamma(theta/alpha +n, 1/((b/k_n)^(alpha)))
   r_n = rand(u,1)[1]
   dz_n  = rand(g,1)[1]
   while r_n > R_q(dz_n, b, k_n,alpha)
       u =  Uniform(0,1)
       r_n = rand(u,1)[1]
       dz_n  = rand(g,1)[1]
       if r_n<= dz_n
        # println("true")
       end
         #return (b/k_n)*((dz_n)^(1/alpha))
   end
   return (b/k_n)*((dz_n)^(1/alpha))
end

function density_xi_n(x, alpha, b, theta, k_n, n)
  term1 = exp(-((b/k_n + x)^alpha))
  term2 = (b/k_n + x)^(alpha - 1)
  term3 = x^(theta + (n-1)*alpha)
  return term1*term2*term3
end

## test xi_n density

#x_t = collect(range(0,1.2*10, length=100))
#xi = Array{Float64}(undef, 10000)
#for i in 1:10000
#  xi[i] = sample_xi_n(0.75, 1, 0.75, 1,1)
#end

## TEST for xi_n

#histogram(xi,bins=250)
#x_t = collect(range(0,1.2*10^2, length=1000))
#plot!(x_t,2000*map(x ->density_xi_n(x,0.75, 1.0, 0.75, 1, 1),x_t))

#histogram(sim.^(1/0.25),bins=250, normalize=true)
#plot!(x_t,map(x ->density_xi_n(x,0.25, 1.0, 0.25, 1, 1),x_t)/20)
#plot!(x_t,2000*map(x ->density_xi_n(x,0.75, 1.0, 0.75, 1, 1),x_t))

function SB_NGG(alpha_, b, theta,N)
  u_n =Array{Float64}(undef, N-1)
  k_n = 1
  for i in (1:(N-1))
    if i == 1
      k_n  = 1
    else
      k_n =prod(vec(ones(1,i-1)).-u_n[1:(i-1)])
    end
      xi_n = sample_xi_n(alpha_, b, theta, k_n,i)
    #println(xi_n)
    R"zn = rgamma(1,1- $alpha_, $b/$k_n + $xi_n)"
    #g = Gamma(1- alpha_, 1/(b/k_n + xi_n))
    #z_n  = rand(g,1)[1]
    z_n  = @rget zn
    #h_n  = b/k_n + xi_n
    R" xn <- retstable($alpha_, 1, h =$b/$k_n + $xi_n,method = 'MH')"
    x_n = @rget xn
    u_n[i] = z_n/ (z_n + x_n)
 end

  p = Array{Float64}(undef, N)
  p[1] = u_n[1]
  for l in 2:(N-1)
    p[l] = prod(vec(ones(1,l - 1)).-u_n[1:(l - 1)])*u_n[l]
  end
  p[N]=prod(vec(ones(1,(N-1))).- u_n)
  return p
end

#n_tr=10
#p_k = SB_NGG(.25, 1,0.25,n_tr)
#plot(1:n_tr,p_k)



function Pkn_NGG_SB(n, β, σ, M; runs=10^4)
  theta = 1
  b = (σ*theta*β)^(1/σ)
  alpha_ = σ
    array_clust_num = Array{Int64}(undef, runs)
    for i in 1:runs
        weights_NGG_SB = SB_NGG(alpha_,b, theta, M)
        c = wsample(1:M, weights_NGG_SB, n, replace=true)
        n_c =  length(unique(c))
        array_clust_num[i] = n_c
    end
    return proportions(array_clust_num, n)
end



function Pkn_NGG_SB_1(n, β, σ, M; runs=10^4)
  theta = (σ*β)
  b = 1
  alpha_ = σ
    array_clust_num = Array{Int64}(undef, runs)
    for i in 1:runs
        weights_NGG_SB = SB_NGG(alpha_,b, theta, M)
        c = wsample(1:M, weights_NGG_SB, n, replace=true)
        n_c =  length(unique(c))
        array_clust_num[i] = n_c
    end
    return proportions(array_clust_num, n)
end
