# # Munk Gyre analytical solution equations
# things between #### blocks are the code for checking exact solution in DGmodel test

using Pkg
Pkg.add("Latexify")
using Latexify
Pkg.add("Plots")
using Plots
Pkg.add("PyPlot")
pyplot()

# Problem parameters
# These will come from DG model/problem settings
###
τ₀=0.1      # Stress
ρ=1000      # density
f=1.e-4     # Coriolis
β=1.e-11    # Rate of change of Coriolis
H=1000      # Depth 
L_x=1000.e3 # Zonal extent
L_y=1000.e3 # Meridional extent
Ah=1000.    # Viscosity
g=10.       # Gravity

δ_m=(Ah/β)^(1/3) 
####

# Set up Munk formula per https://mitgcm.readthedocs.io/en/latest/examples/examples.html#model-solution
# Build up using expressions to catch typos
t1=:( cos((3^0.5*x)/(2*δ_m))+(1)/(3^0.5)*sin((3^0.5*x)/(2*δ_m)) )
display(latexify(t1))
t2=:( 1-exp((-x)/(2*δ_m) ) * $t1 )
display(latexify(t2))
t3=:( π*sin(π*y/L_y) )
display(latexify(t3))
t4=:( τ₀/(ρ*g*H)*(f/β)*(1-x/L_x) )
display(latexify(t4))
tfull=:( ($t4) * ($t3) * ($t2) )
display(latexify(tfull))
display(tfull)

# Actual function (a copy paste from display(tfull) line)
#### This is formula needed for checking numerical against exact
ηfun(x,y)=(((τ₀ / (ρ * g * H)) * (f / β) * (1 - x / L_x)) * (π * sin((π * y) / L_y)) * (1 - exp(-x / (2δ_m)) * (cos((3 ^ 0.5 * x) / (2δ_m)) + (1 / 3 ^ 0.5) * sin((3 ^ 0.5 * x) / (2δ_m)))))
####

# Now make a plot to check
xvals=collect(0:L_x/100:L_x)
yvals=collect(0:L_y/100:L_y)
nx=length(xvals)
ny=length(yvals)
η=zeros(nx,ny)
for j=1:ny
 for i=1:nx
  η[i,j]=ηfun(xvals[i],yvals[j])
 end
end


p2 = contour(xvals, yvals, η')
plot(p2)
