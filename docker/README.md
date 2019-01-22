Docker file for creating an image for running CLIMA test and model.
When the image execurtes it creates a Jupuyter lab session. A browser
on the host can connect to the Jupyter session and, for example, run CLIMA 
test cases in a Julia notebook using Julia commands
```
using Pkg
Pkg.activate(".")
Pkg.test("CLIMA",coverage=true)
```

To build image
```
docker build -t clima -f CLIMA.dockerfile .
```

To run image
```
docker run -P -it --rm clima
```
when the image runs it will forward port 8888 back to another port on host.
A host browser can connect to the Jupyter lab session at the URL
```
http://localhost:PPPP/?token=TTTTT
```
where PPPP is the port on the host and TTTT is the Jupyter lab generated token.
