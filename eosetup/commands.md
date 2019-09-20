# Commands to get started with Julia and MPI on engaging

# Centos7
```
ssh -l cnh eofe7.mit.edu

# In one tmux 
ssh -l cnh eofe7.mit.edu
cd /nfs/cnhlab001/cnh/projects/julia-envs/test-my-mpi
srun -p sched_mit_darwin2 --gres=gpu:2 -N 2 --exclusive --time=12:00:00 --pty /bin/bash
sinfo --nodes=${SLURM_JOB_NODELIST}  -N -o "%N" -h -p sched_system_all  > mf
node1=`head -1 mf`

# In another tmux
ssh ${node1}
cd /nfs/cnhlab001/cnh/projects/julia-envs/test-my-mpi
module add intel/2018-01; module add impi/2018-01

# If needed
julia -e 'using Pkg;Pkg.add("MPI");Pkg.build("MPI")'

mpirun -np 2  julia  test.jl
```

# Centos6
```
cd /nfs/cnhlab001/cnh/projects/julia-envs/test-my-mpi
srun -p sched_mit_darwin -n 2 --time=12:00:00 --constraint="centos6" --pty /bin/bash
module load engaging/openmpi/2.0.3 

# If needed
julia -e 'using Pkg;Pkg.add("MPI");Pkg.build("MPI")'

mpirun -np 2 julia test.jl

```
