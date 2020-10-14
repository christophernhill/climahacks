#
# Python script that reads CLiMA VTU files and makes XY plots for
# ShallowWater CLiMA model setup.
#

#
#  To activate conda environment with needed packages e.g.
#  $ source /Users/chrishill/projects/myconda/miniconda3/bin/activate
#
#  To generate a movie e.g.
#  $ fld="eta" ; ffmpeg -r 24 -s 1920x1080 -i mpirank0000_step%04d_${fld}.png -vf pad="iw:ih+200:(ow-iw)/2:(oh-ih)/2:color=white" -b:v 16M -pix_fmt yuv420p -r 24 foo_${fld}.mp4
#

#
#
# Some dependencies!!!
# - sudo apt update
# - sudo apt install libgl1-mesa-glx libxext6 libxtst6 libxt6
# - sudo apt install ffmpeg
#
# wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
# ./Miniconda3-latest-Linux-x86_64.sh -b -p miniconda3
# source ../../myconda/miniconda3/bin/activate
# conda create -n py37 python=3.7
# conda activate py37
# conda install matplotlib numpy pandas vtk 
#

#
#  Import needed packages
#
import vtk
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
from mpl_toolkits import mplot3d
from mpl_toolkits.axes_grid1 import make_axes_locatable
import re
from datetime import datetime, timedelta


#
# Function to remove consolidate numeric values that are within eps of
# each other in a list to a single common value.
# Used to reduce coordinates that are very slightly different to a common value.
#
# Args
# phi :: Vector of sorted numbers to "dedup"
#
# Returns
# phi :: Updated sorted list with epsilon searated values collapsed to
#        one value
def dedup( phi ):
  deps=1e-4;
  for i in range(len(phi)-1):
    delta=phi[i+1]-phi[i]
    if abs(delta) < deps:
     phi[i+1]=phi[i]
  phi=np.unique(phi)
  return phi

#
# Function to read CLiMA VTU file contents into a Python Data Frame construct
#
# Args:
# fn :: File name to read
#
# Returns:
# df   :: Data frame with columns named by valiable or coordinate axis name
# xloc :: Deduplicated, ordered list of nodal point coordinates for X-dimension
# yloc :: Deduplicated, ordered list of nodal point coordinates for Y-dimension
# zloc :: Deduplicated, ordered list of nodal point coordinates for Z-dimension
def readvtu(fn):
   # Read CLiMA VTU data into data frame   
   reader = vtk.vtkXMLUnstructuredGridReader()
   reader.SetFileName(fn)
   reader.Update()
   output = reader.GetOutput()

   # 1. Get variable names
   pntData=output.GetPointData()
   nArr=pntData.GetNumberOfArrays()
   print("File contains ",nArr," arrays with names")
   aNames=[pntData.GetArrayName(i) for i in range(nArr) ]
   print("  ",aNames)

   # 2. Get array size (they are all same size)
   nT=pntData.GetArray(aNames[0]).GetNumberOfTuples()
   nC=pntData.GetArray(aNames[0]).GetNumberOfComponents()
   nEl=nT*nC
   ## print("Each array is of size ",nEl)   

   # 3. Get coord data size
   pntLocs=output.GetPoints().GetData()
   nDim=pntLocs.GetNumberOfTuples()
   nCoord=pntLocs.GetNumberOfComponents()
   ## print("Coords are ",nDim,"x",nCoord)

   # 4. Read coords
   cData=np.reshape([pntLocs.GetValue(i) for i in range(nDim*nCoord)],(nDim,nCoord))
   ## print(cData[0,:])  

   # 5. Create a data frame holding coords
   df = pd.DataFrame(data=cData, columns=["X", "Y", "Z"])

   # 6. Get the unique coords along each axis so these can be returned too
   xloc=dedup( np.sort( df.X.unique() ) )
   yloc=dedup( np.sort( df.Y.unique() ) )
   zloc=dedup( np.sort( df.Z.unique() ) )             

   # 7. Read data vectors and add a named column for each vector
   aNamesSel=aNames[:]
   for aN in aNamesSel[:]:
     print(aN)
     pData=[pntData.GetArray(aN).GetValue(i) for i in range(nEl) ]
     df[aN]=pData
   return df,xloc,yloc,zloc

#
# Function to make a specific plot layout for 2d data from Ocean Shallow
# Water setup. 
#
# Args ::
# fp   :: File prefix for VTU file to read
# fig  :: Not needed
# fc   :: Field labels [0] - name used in output .png file name
#                      [1] - name used in labeling plots
#                      [2] - code for field in VTU file
# scal :: Scaling used for plots [0] - X-dimension scaling
#                                [1] - Y-dimension scaling
#                                [2] - Field scaling
#
def mkplot(fp,fig,fc,scal):
 fig=plt.figure(figsize=(10,7),dpi=300)
 nstep=int(re.split("step",fp.split('_')[1])[1])+1
 ts=nstep*1000*20
 sec = timedelta(seconds=ts)
 time='%4.4d days'%sec.days + ', %6.6d secs'%sec.seconds
 fig.suptitle('%s'%time,y=1.0)
 fn='%s.vtu'%fp
 fs=fc[0];
 fl=fc[1];
 fdf=fc[2];
 s1=scal[0];s2=scal[1];s3=scal[2];
 print(fn)
 df,xloc,yloc,zloc=readvtu(fn);
 # plt.tight_layout()
 fig.set_tight_layout(True)
 # fig, axs2 = plt.subplots(2, 2, constrained_layout=True)
 # fig.suptitle(fp)
 # fig, axs4 = plt.subplots(4, 2, constrained_layout=True)
 # fig.suptitle(fp)
 
 # XY scatter
 ax=fig.add_subplot(2,2,1)
 rslt_df=df
 rslt_df[fdf]=rslt_df[fdf]*s3
 vmax=np.max(rslt_df[fdf])
 vmin=np.min(rslt_df[fdf])
 sctt=ax.scatter(rslt_df['X']*s1,rslt_df['Y']*s2,s=3,c=rslt_df[fdf],cmap=plt.get_cmap('jet'))
 ax.set_xlim(0,1000) 
 ax.set_ylim(0,1000)
 ax.set_xlabel('X (km)')
 ax.set_ylabel('Y (km)')
 ax.tick_params(axis='x', labelsize=6 )
 ax.tick_params(axis='y', labelsize=6 )
 cbar=plt.colorbar(sctt)
 cbar.ax.tick_params(labelsize=6) 
 cbar.ax.set_xlabel('%s \n min=%e \n max=%e'%(fl,vmin,vmax),fontsize=8,fontweight='bold')

 # Line in X
 ax=fig.add_subplot(4,2,2) 
 # yc=np.sort(df['Y'].unique())[-1]
 yc=np.sort(df['Y'].unique())[35]
 # yc=np.sort(df['Y'].unique())[0]
 rslt_df = df[( abs(df.Y-yc)<1e-4 )]
 vmax=np.max(rslt_df[fdf])
 vmin=np.min(rslt_df[fdf])
 ax.scatter(rslt_df['X']/1000,rslt_df[fdf],c=rslt_df[fdf],cmap=plt.get_cmap('jet'),s=6)
 ax.set_ylim(vmin-abs(vmin*0.05),vmax+abs(vmax*0.05))
 ax.set_xlabel('X (km)')
 ax.set_ylabel('%s, Y=%.1fKM \n min=%e \n max=%e'%(fl,yc/1000,vmin,vmax) , fontsize=8 , fontweight='bold')
 ax.tick_params(axis='x', labelsize=6 )
 ax.tick_params(axis='y', labelsize=6 )
 ax.set_xlim(0,1000)
 ax.grid(True)
 
 # Line in Y
 ax=fig.add_subplot(4,2,4) 
 # xc=np.sort(df['X'].unique())[-1]
 xc=np.sort(df['X'].unique())[16]
 # xc=np.sort(df['X'].unique())[0]
 rslt_df = df[( abs(df.X-xc)<abs(xc*1e-4+1e-4) )] 
 vmax=np.max(rslt_df[fdf])
 vmin=np.min(rslt_df[fdf])
 ax.scatter(rslt_df[fdf],rslt_df['Y']/1000,c=rslt_df[fdf],cmap=plt.get_cmap('jet'),s=6)
 ax.set_xlim(vmin-abs(vmin*0.05),vmax+abs(vmax*0.05))
 ax.set_ylim(0,1000)
 ax.set_ylabel('Y (km)')
 ax.set_xlabel('%s, X=%.1fKM, \n min=%e \n max=%e'%(fl,xc/1000,vmin,vmax), fontsize=8 , fontweight='bold')
 ax.tick_params(axis='x', labelsize=6 )
 ax.tick_params(axis='y', labelsize=6 )
 ax.grid(True)

 pn='%s_%s.png'%(fp,fc[0])
 plt.savefig(pn)
 plt.close(fig)
 # plt.show()

# Loop that makes a series of .png to generate a movie
fig=plt.figure(figsize=(10,7),dpi=300)
for i in range(0,432):
        fp='mpirank0000_step%4.4d'%i
        print(fp)
        mkplot(fp,fig,('eta','η (m)','η'),(1./1000,1./1000,1.))
        mkplot(fp,fig,('uvel','u (m/s)','U[1]'),(1./1000,1./1000,1./3000))
        mkplot(fp,fig,('vvel','v (m/s)','U[2]'),(1./1000,1./1000,1./3000))
