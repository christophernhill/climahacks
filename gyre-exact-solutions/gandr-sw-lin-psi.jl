using Pkg
Pkg.add("Latexify")
using Latexify

Pkg.add("Plots")
using Plots
Pkg.add("PyPlot")
pyplot()

# Julia code for linear Stommel problem solution in "F. X. GIRALDO AND M. RESTELLI" 
# High-order semi-implicit time-integrators for a triangular discontinuous Galerkin 
# oceanic shallow water model

L=1e6 # Basin size
τ₀=0.2
β=1e-11
f₀=1e-4
γ=1e-6
g=10
H=1000
ρ=1000

# Derived terms
y_m=L/2
ϕ_B=g*H

ETMP01=:( ((β/γ)^2+4*(π/L)^2)^0.5 )
λ₁_def=:( λ₁ = (-β/γ+$ETMP01)/2 )
λ₂_def=:( λ₂ = (-β/γ-$ETMP01)/2 )
display( latexify(λ₁_def) )
display( latexify(λ₂_def) )

C₀_def=:( C₀ = τ₀/(γ*ρ*H)*(L/π) )
C₁_def=:( C₁ =  C₀*( (1-exp(λ₂*L))  / (exp(λ₂*L) - exp(λ₁*L)) ) )
C₂_def=:( C₂ = -C₀*( (1-exp(λ₁*L))  / (exp(λ₂*L) - exp(λ₁*L)) ) )
display( latexify(C₀_def) )
display( latexify(C₁_def) )
display( latexify(C₂_def) )

ψ_def=:( ψ = (C₀ + C₁*exp(λ₁*x) + C₂*exp(λ₂*x))*sin((π*y)/L) )
display( latexify(ψ_def) )

display( λ₁_def )
display( λ₂_def )
display( C₀_def )
display( C₁_def )
display( C₂_def )
display( ψ_def  ) 


λ₁ = (-β / γ + ((β / γ) ^ 2 + 4 * (π / L) ^ 2) ^ 0.5) / 2
λ₂ = (-β / γ - ((β / γ) ^ 2 + 4 * (π / L) ^ 2) ^ 0.5) / 2
C₀ = (τ₀ / (γ * ρ * H)) * (L / π)
C₁ = C₀ * ((1 - exp(λ₂ * L)) / (exp(λ₂ * L) - exp(λ₁ * L)))
C₂ = -C₀ * ((1 - exp(λ₁ * L)) / (exp(λ₂ * L) - exp(λ₁ * L)))
ψ(x,y) = (C₀ + C₁ * exp(λ₁ * x) + C₂ * exp(λ₂ * x)) * sin((π * y) / L)


nx=ny=50;
x=collect(range(0.,L,step=L/nx))
y=collect(range(0.,L,step=L/ny))
ψval=zeros(nx+1,ny+1)
for j=1:ny
 for i=1:nx
  ψval[i,j]=ψ(x[i],y[j])
 end
end
ψval

p1 = contour(x, y, ψval')
plot(p1)


ETMP01=:( C₀*β*L/π*cos(π*y/L) +fofy*ψ )
ETMP02=:( C₁/λ₁*exp(λ₁*x)+C₂/λ₂*exp(λ₂*x) )
display( latexify(ETMP01) )
display( latexify(ETMP02) )
ϕ_s_def=:( ϕ_s = $ETMP01 + γ*π/L*cos(π*y/L)*$ETMP02 )
display( latexify(ϕ_s_def) )

ϕ_s_func(x,y,fofy)=(((C₀ * β * L) / π) * cos((π * y) / L) + fofy * ψval[x,y]) + ((γ * π) / L) * cos((π * y) / L) * ((C₁ / λ₁) * exp(λ₁ * x) + (C₂ / λ₂) * exp(λ₂ * x))

ϕ_s_val=zeros(nx+1,ny+1)
for j=1:ny+1
 for i=1:nx+1
  ϕ_s_val[i,j]=ϕ_s_func( i,j,f₀+β*y[j] )
 end
end

p1 = contour(x, y, ϕ_s_val')
plot(p1)
