# Coral-Model-V12
## Archived versions of this software are available:
[![DOI](https://zenodo.org/badge/113405802.svg)](https://zenodo.org/badge/latestdoi/113405802)
The latest DOI as of 13 Apr 2019 is 10.5281/zenodo.2639127

This is the model used for a paper expected to be released as Logan, Dunne,
Ryan, Baskett, and Donner 2019.  Publication details are not yet available and
may change.

## To run the model:

1) Install MATLAB, using a 2013 version or later.  R2018a is the last version
   tested.
2) Place the directory containing this file with all its contents where MATLAB
   can access it.
3) Edits mentioned below will be in the file modelVars.txt, which contains a
   single JSON string.
4) Obtain m_map from www.eoas.ubc.ca/~rich/map.html, and edit m_mapPath to 
   point it the directory.
5) Edit outputBase to point to a location for output files.
6) In all locations, replace "D:/GitHub/Coral-Model-V12/" with the base
   directory in which you have placed this model.
7) Edit useThreads to a value no greater than the number of workers allowed in
   your MATLAB configuration.
8) For Windows, the file timeIteration_23040_mex.mexw64 is already in place. On
   other architectures use MATLAB Coder to compile timeIteration.m for your
   machine. As an entry point, use the main program, ideally after editing everyx
   in modelVars.txt to 100 or 1000 for faster operation.  Rename the resulting
   "mex" file exactly as shown.  The number must match the number of time points
   in the computation, as reflected in the array "time".
8) Select aCoralModel.m and run it.

## Expected output

Expected initial outputs include an echo of the parameters from modelVars.txt, 
and a line reading "Modeling 1925 reefs". The value will be smaller if you have
selected a subset of all reefs.  Next there will be progress lines, for example
"Set 2 is 26 percent complete." where the set number indicates which worker
thread is in use.

The run will end with several tables in this format:

```
Permanently bleached reefs as of the date given:
Year         1950    2000    2016    2050    2075    2100  Total Reefs Max Latitude
Equatorial  24.14   24.14   27.59   56.90   93.10  100.00           58          7.0
Low          6.15    6.15    6.15   24.62   81.54  100.00           65         15.0
High         8.22    9.59   12.33   46.58   87.67  100.00           73         28.5
All Reefs   12.24   12.76   14.80   42.35   87.24  100.00          196 
```

Followed by some timing statistics.
