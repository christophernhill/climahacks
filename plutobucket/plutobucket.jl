### A Pluto.jl notebook ###
# v0.12.15

using Markdown
using InteractiveUtils

# ╔═╡ adace680-337d-11eb-0d7a-1b7271279e94
md"""
### Basic bucket model

A simple bucket model, at a give location ``(x,y)``, takes the following inputs 

* the maximum bucket depth, ``D^{max}``. This term can be taken to be a constant everywhere in a simple model. It is oftem specified in units of mm, e.g
```math
  D^{\rm{max}}=150~\rm{mm}
```
* the maximum potential evaporation rate, ``E^{\rm{max}}(x,y)``. This term is typically a function of atmospheric boundary state variables (temperature, relative humdity, wind speed). The ``E^{\rm{max}}`` term is often given in units of mm month``^{-1}`` e.g.
```math
  E^{\rm{max}}=60~\frac{\rm{mm}}{\rm{month}}
```

* some function, ``I``, that regulates the _infiltration_ efficiency i.e. the efficiency with which a bucket can uptake precipitation. Give a current bucket level, ``B^{l}``, a typical infiltration function will increase the uptake effciency of precipitation for a relatively empty (i.e. drier soil) bucket e.g.
```math
  I = 0.75 - 0.5 \frac{B^{l}}{D^{\rm{max}}}
```

* a runoff location, ``R^{\rm{loc}}``. This is an ocean grid location where excess precipitation that is added to the runoff, ``R``, will be deposited.


* a precipitation rate, ``P(x,y)``, that is often specified in units of  mm month``^{-1}`` e.g.
```math
   P=60~\frac{\rm{mm}}{\rm{month}}
```

"""

# ╔═╡ ca4be9b6-3383-11eb-1509-c30ad4e5e746
md"""
For a given ``(x,y)`` location the bucket model will compute the change, ``\Delta B^{l}``, in the bucket level at the location and the change, ``\Delta R``, in the runoff amount to be added at the runoff location, ``R^{\rm{loc}}``.

"""

# ╔═╡ 0fd7771a-3387-11eb-2ebd-e383b33b743a
## Define bucket function
# """
#  
# """
function bucket(;b=0,d=150,e=60,Ifunc=nothing,p=60)
 
 println("******** executing bucket()")
	
 # Calculate evaporation depending on how full bucket is
 αᵉ=b/d*e
 println("Evaporation = ",αᵉ)
	
 # Compute how much precipitation goes to runoff and how much is
 # stored in bucket
 Δr=p*(1-Ifunc(b,d))
 println("Unabsorbed precip = ",Δr)
 pᵇ=p*Ifunc(b,d)
 println("Absorbed precip = ",pᵇ)
	
 # Compute update to b 
 Δb = pᵇ-αᵉ
	
 # Reduce update to b and increase runoff if bucket is full
 if b + Δb > d
  Δr=Δr+(b+Δb)-d
  Δb=d-b
 end
	
 # Summary
 println("Summary: b+p, b+Δb+αᵉ+Δr = ", b+p, ", ", b+Δb+αᵉ+Δr)
 println("Summary: b, p, E, Δr, Δb = ", b, ", ", p, ", ", αᵉ,", ", Δr,", ", Δb)
 
	
 return Δb, Δr
	
end

# Note - per https://github.com/fonsp/Pluto.jl/issues/245 println() output appears in the console that launched pluto. 

# ╔═╡ 3e1a8390-337d-11eb-1824-43eebfe1ed2b
## Set parameters
begin
	Dᵐᵃˣ=150
	Eᵐᵃˣ=60
	Ifunc(b,d)=0.75-0.5*b/d
	Rˡᵒᶜ=(10,32)
	P=10
	Bˡ=20
end

# ╔═╡ b66643c8-3386-11eb-248b-2f6abd612e53
## Evaluate function
ΔBˡ, ΔR = bucket(b=Bˡ,d=Dᵐᵃˣ,e=Eᵐᵃˣ,Ifunc=Ifunc,p=P)

# ╔═╡ Cell order:
# ╠═adace680-337d-11eb-0d7a-1b7271279e94
# ╠═ca4be9b6-3383-11eb-1509-c30ad4e5e746
# ╠═0fd7771a-3387-11eb-2ebd-e383b33b743a
# ╠═3e1a8390-337d-11eb-1824-43eebfe1ed2b
# ╠═b66643c8-3386-11eb-248b-2f6abd612e53
