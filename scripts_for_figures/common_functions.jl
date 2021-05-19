using SpecialFunctions, Nemo, StatsFuns, Memoization
import Nemo.binom, Nemo.gamma

"Session-wide precision"
const precision = 5000 ## Increase for better precision

"Converter from real to arbitrary precision real (Arb)"
const RR = RealField(precision)
const CC = ComplexField(precision)

## common functions
gamma(x::Int64) = Nemo.gamma(RR(x))

#  Factorial function
fac(x::Int64) = Nemo.fac(RR(x))

@memoize function unsigned_Stirling2(n::Integer,k::Integer)
  # special cases
  if k<0 || n<0
    throw(DomainError())
  end
  if k>n
    return big(0)
  end
  if n==0  # and, by logic, k==0
    return big(1)
  end
  if k==0  # and, by logic, n>0
    return big(0)
  end
  # end of special cases, invoke recursion
  return  (k)*unsigned_Stirling2(n-1,k) + unsigned_Stirling2(n-1,k-1)
end


import Nemo.risingfac

function risingfac(r, n)
  if r == 0
    return 0
  else
    return prod(r + i for i in 0:(n-1))
  end
end
function risingfac(r::arb, n)
  if r == 0
    return arb_0
  else
    return prod(r + i for i in 0:(n-1))
  end
end

##functions to compute M function for Fergusson&Klass approximation
using Distributions, Roots

Γ(x) = SpecialFunctions.gamma(x)
using RCall
R"library(expint)"

function gamma_inc_r(a::Float64, x::Float64)
    res::Float64 = R"expint::gammainc($a,$x)"
    return res
end
# Γ(s,x) = SpecialFunctions.gamma_inc_r(s, x, 0)[2] * Γ(s)
Γ(s,x) = gamma_inc_r(s, x)

function log_βnk(β, n, k, σ)
    return log(β) + log(n) - 1/σ*log(k)
end
βnk(β, n, k, σ) = exp(log_βnk(β, n, k, σ))

function logxk(n, k, β, σ)
    if n==1
        return log(k*σ ) + log(GibbsTypePriors.Cnk(n, k+1, σ)) - log(σ) - log(GibbsTypePriors.Cnk(n, k, σ))
    else
       return log(k*σ + βnk(β, n-1, k, σ)) + log(GibbsTypePriors.Cnk(n, k+1, σ)) - log(σ) - log(GibbsTypePriors.Cnk(n, k, σ))
    end
end

function logxk_py(n, k, β, σ)
       return log(k*σ + β) + log(GibbsTypePriors.Cnk(n, k+1, σ)) - log(σ) - log(GibbsTypePriors.Cnk(n, k, σ))
end


function Pkn_NGG_approx_full(n, β, σ, f)
        Axnk = Array{arb}(undef, n-1)
        Axnk[1:n-1] = f.(n, 1:n-1, β, σ)
        Sum_xn= exp(f(n, 1, β, σ))
        for i in (3:n)
             Sum_xn= Sum_xn + exp(sum(Axnk[1:i-1]))
        end
        P1n = Array{arb}(undef, n)
        P1n[1] = exp(- log(1 +Sum_xn))
        for k in 2:(n)
              P1n[k] = exp(log(P1n[k-1]) + Axnk[k-1])
        end
        return P1n
end

Pkn_NGG_pred_approx(n, β, σ) = convert(Array{Float64,1}, Pkn_NGG_approx_full(n,  β, σ, logxk))




function Pkn_NGGM_arb_precomputed(k::N, n::N,H::N,  β::T, σ::T, Pk_NGG::A) where {T<:Number, N<:Integer,A<:Vector}
    H_arb = RR(H)
    return (fac(H) // (H_arb^k * fac(H-k))) * sum([ (1//(H_arb^i))*unsigned_Stirling2(i+k,k)* Pk_NGG[k+i] for i in 0:(n-k)])
end


Pkn_NGGM_precomp(k,n, H, β, σ, Pk_NGG) = convert(Float64, Pkn_NGGM_arb_precomputed(k, n, H, β, σ, Pk_NGG))


## functions to smooth the plot


function quantilepk(pk)
  n = length(pk)
  cdfk = cumsum(pk)
  quantile_grid = (1:n)/(n+1)
  return [argmin(cdfk .< q) for q in quantile_grid]
end

function gamma_qq(pk, α, β)
  n = length(pk)
  quantile_grid = (1:n)/(n+1)
  return sum((quantile.(Gamma(α, 1/β), quantile_grid) - quantilepk(pk)).^2)
end


 function smooth_pk(Pkn)
  lower = [1., 0.0]
  upper = [10000, 10000]
  initial_x = [2.0, 2.0]
  objfun_pkn(x) = gamma_qq(Pkn, x[1], x[2])
  res = optimize(objfun_pkn, lower, upper, initial_x)
  α_, β_ = res.minimizer
  return Pkn__smooth = pdf.(Gamma(α_, 1/β_), eachindex(Pkn))
end

###
