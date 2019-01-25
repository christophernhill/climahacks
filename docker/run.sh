#!/bin/bash -xev

cnam="clima-"`cat /dev/urandom | env LC_CTYPE=C tr -cd 'a-f0-9' | head -c 32 `
docker run -P -d -it --name ${cnam} --rm clima
sleep 2

# echo $cnam

ctok=`docker logs ${cnam} 2>&1 | grep http | grep token | grep -v LabApp | awk -F/ '{print $4}' `
pnum=`docker ps --format "{{.Names}} {{.Ports}}" | grep ${cnam} | awk '{print $2}' | awk -F: '{print $2}' | awk -F- '{print $1}'`

open -a safari http://localhost:${pnum}/${ctok}

docker logs   $cnam

echo "###########################################################################"
echo "# To run simple test open Julia notebook and execute the following commands"
echo " "

cat <<EOFA
 cd("/usr/myapp")
 using Pkg
 Pkg.activate(".")
 Pkg.test("CLIMA",coverage=true)
EOFA

echo " "
echo "###########################################################################"

docker attach $cnam
