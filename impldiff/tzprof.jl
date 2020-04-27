using Pkg; Pkg.add("Plots")
using Plots
# IJulia.clear_output(true)

# Define functions and parameters
H=4000.;L=H/10.;A=20.;C=50.;D=2.5;B=8.;E=5.e-4;
ft(x,L)=exp(-x/L)
th1(z)=A*ft.(-z .+ L, L);
th2(z)=C*ft(D*(-z .+ L), L);

# Plot for equally spaced discrete points
npt=1000;
z=-collect(range(0, 1, length=npt)) .* H
phi1=th1.(z)
phi2=th2.(z)
theta=phi1 .- phi2 .+ B .+ E .* z;
plot( theta ,z,label=false, lw=3, color = :black )
plot!(phi1 .+ B ,z,label=false , line=(:dash) )
plot!(phi2 .+ B ,z,label=false , line=(:dash) )

# Plot for ECCO 50-level discrete points
dzECCO50l=[10.00, 10.00, 10.00, 10.00, 10.00, 10.00, 10.00, 10.01, 
    10.03, 10.11, 10.32, 10.80, 11.76, 13.42, 16.04 , 19.82, 
    24.85,31.10, 38.42, 46.50, 55.00, 63.50, 71.58, 78.90, 
     85.15, 90.18, 93.96, 96.58, 98.25, 99.25,100.01,101.33,
    104.56,111.33,122.83,139.09,158.94,180.83,203.55,226.50,
     249.50,272.50,295.50,318.50,341.50,364.50,387.50,410.50,
    433.50,456.50];
dz=dzECCO50l;
z=-(cumsum(dz).-dz./2);
phi1=th1.(z)
phi2=th2.(z)
theta=phi1 .- phi2 .+ B .+ E .* z;
plot( theta ,z,label=false, lw=3, color = :black )
plot!(phi1 .+ B ,z,label=false , line=(:dash) )
plot!(phi2 .+ B ,z,label=false , line=(:dash) )


