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

To launch image on OSX and start Jupyter in Safari in one go
```
./run.sh
```

To run image and start other pieces by hand
```
docker run -P -it --rm clima
```
when the image runs it will forward port 8888 back to another port on host.
A host browser can connect to the Jupyter lab session at the URL
```
http://localhost:PPPP/?token=TTTTT
```
where PPPP is the port on the host and TTTT is the Jupyter lab generated token.

To find forwarded port on host use
```
docker ps --format "{{.Image}}: {{.Ports}}" | grep clima | awk '{print $2}' | sed s/'[^:]*\:\([0-9]*\)-.*/\1/'
```
