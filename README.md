# Coral-Model-V12
## Archived versions of this software are available:
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.4640536.svg)](https://doi.org/10.5281/zenodo.4640536)
The software is under a "3-Clause BSD License".  See the LICENSE file and other
license_*.txt files for included third-party software.

This is the model used for a paper submitted for publication by Logan, Dunne,
Ryan, Baskett, and Donner in early 2020.  Publication details are not yet available and
may change.

## To run the model:

1) Install MATLAB, using a 2013 version or later.  R2019b is the last version
   tested.
2) Place the directory containing this file with all its contents where MATLAB
   can access it.
3) Edits mentioned below will be in the file modelVars.txt, which contains a
   single JSON string.
4) Obtain m_map from www.eoas.ubc.ca/~rich/map.html, and edit m_mapPath to 
   point at the directory where you install it.
5) Edit outputBase to point to a location for output files.
6) In all locations, replace "D:/GitHub/Coral-Model-V12/" with the base
   directory in which you have placed this model.
7) Edit useThreads to a value no greater than the number of workers allowed in
   your MATLAB configuration.  Later, try changing this to optimize performance.
8) For Windows, the file timeIteration_23040_mex.mexw64 is already in place. On
   other architectures use MATLAB Coder to compile timeIteration.m for your
   machine. As an entry point, use the main program, ideally after editing everyx
   in modelVars.txt to 100 or 1000 for faster operation.  Rename the resulting
   "mex" file exactly as shown.  The number must match the number of time points
   in the computation, as reflected in the array "time".
9) Open A_Coral_Model.m and replace "D:\GitHub\Coral-Model-V12\modelVars.txt" with
   the actual path to the modelVars file you edited above.
9) From the base directory used above, run A_Coral_Model.m

## Definitions for all variables in modelVars.txt
<p>&nbsp;</p>
<p>Input options. &nbsp; These are the variables which may be modified by editing
 modelVars.txt.  At runtime they are stored in an object called ParameterDictionary,
 which provides some limited error checking.</p>
<table border="0" cellpadding="0" cellspacing="0" >
  <tbody>
    <tr>
      <td valign="bottom" >
        <p><strong>Name</strong></p>
      </td>
      <td valign="bottom" >
        <p><strong>Example value</strong></p>
      </td>
      <td colspan="2" valign="bottom" >
        <p><strong>Description</strong></p>
      </td>
    </tr>
    <tr>
      <td colspan="4" valign="bottom" >
        <p><strong>Science</strong></p>
      </td>
    </tr>
    <tr>
      <td valign="bottom" >
        <p>dataset</p>
      </td>
      <td valign="bottom" >
        <p>ESM2M</p>
      </td>
      <td colspan="2" valign="bottom" >
        <p>Category of climate dataset</p>
      </td>
    </tr>
    <tr>
      <td valign="bottom" >
        <p>E</p>
      </td>
      <td valign="bottom" >
        <p>true</p>
      </td>
      <td colspan="2" valign="bottom" >
        <p>Allow the symbionts to evolve.</p>
      </td>
    </tr>
    <tr>
      <td valign="bottom" >
        <p>OA</p>
      </td>
      <td valign="bottom" >
        <p>false</p>
      </td>
      <td colspan="2" valign="bottom" >
        <p>Include a growth penalty based on ocean acidification effects.</p>
      </td>
    </tr>
    <tr>
      <td valign="bottom" >
        <p>RCP</p>
      </td>
      <td valign="bottom" >
        <p>rcp26</p>
      </td>
      <td colspan="2" valign="bottom" >
        <p>The representative concentration pathway selection for this run. &nbsp; &nbsp; rcp26, rcp45, rcp60, rcp85, and control400 are supported.</p>
      </td>
    </tr>
    <tr>
      <td valign="bottom" >
        <p>superAdvantage</p>
      </td>
      <td valign="bottom" >
        <p>0.5</p>
      </td>
      <td colspan="2" valign="bottom" >
        <p>Thermal advantage in degrees C for any special symbionts.</p>
      </td>
    </tr>
    <tr>
      <td valign="bottom" >
        <p>superMode</p>
      </td>
      <td valign="bottom" >
        <p>7</p>
      </td>
      <td colspan="2" valign="bottom" >
        <p>Mode of special symbiont introduction, defined in setupSuperSymbionts.m</p>
      </td>
    </tr>
    <tr>
      <td valign="bottom" >
        <p>superGrowthPenalty</p>
      </td>
      <td valign="bottom" >
        <p>0.25</p>
      </td>
      <td colspan="2" valign="bottom" >
        <p>Coral growth penalty applied when a heat-tolerant symbiont strain dominates.</p>
      </td>
    </tr>
    <tr>
      <td valign="bottom" >
        <p>superStart</p>
      </td>
      <td valign="bottom" >
        <p>1861</p>
      </td>
      <td colspan="2" valign="bottom" >
        <p>Year of introduction of special symbionts.</p>
      </td>
    </tr>
    <tr>
      <td colspan="4" valign="bottom" >
        <p><strong>Computation</strong></p>
      </td>
    </tr>
    <tr>
      <td valign="bottom" >
        <p>everyx</p>
      </td>
      <td valign="bottom" >
        <p>1</p>
      </td>
      <td colspan="2" valign="bottom" >
        <p>If &gt; 1 skip reefs for fast debugging or feature testing.</p>
      </td>
    </tr>
    <tr>
      <td valign="bottom" >
        <p>specialSubset</p>
      </td>
      <td valign="bottom" >
        <p>useEveryx</p>
      </td>
      <td colspan="2" valign="bottom" >
        <p>Options: "no" = compute all reefs, ignoring everyx; "useEveryx" = obey the values in everyx; "keyOnly": compute only the reefs listed in keyReefs; "eq", "lo", "hi" = compute reefs with absolute value of latitude in the range [0, 7], (7, 15], or &gt; 15, respectively.</p>
      </td>
    </tr>
    <tr>
      <td valign="bottom" >
        <p>optimizerMode</p>
      </td>
      <td valign="bottom" >
        <p>False</p>
      </td>
      <td colspan="2" valign="bottom" >
        <p>This is normally false, but must be set true when optimizing the proportionality constant.</p>
      </td>
    </tr>
    <tr>
      <td valign="bottom" >
        <p>useThreads</p>
      </td>
      <td valign="bottom" >
        <p>6</p>
      </td>
      <td colspan="2" valign="bottom" >
        <p>Number of threads (MATLAB workers) to use, subject to system configuration limits.</p>
      </td>
    </tr>
    <tr>
      <td colspan="4" valign="bottom" >
        <p><strong>Output</strong></p>
      </td>
    </tr>
    <tr>
      <td valign="bottom" >
        <p>doPlots</p>
      </td>
      <td valign="bottom" >
        <p>true</p>
      </td>
      <td colspan="2" valign="bottom" >
        <p>If false the plots cotrolled by allFigs, keyReefs, and the following do[plot type] options are all disabled.</p>
      </td>
    </tr>
    <tr>
      <td valign="bottom" >
        <p>allFigs</p>
      </td>
      <td valign="bottom" >
        <p>false</p>
      </td>
      <td colspan="2" valign="bottom" >
        <p>Output a MATLAB figure for each reef cell simulated.</p>
      </td>
    </tr>
    <tr>
      <td valign="bottom" >
        <p>keyReefs</p>
      </td>
      <td valign="bottom" >
        <p>[150 420 421 512]</p>
      </td>
      <td colspan="2" valign="bottom" >
        <p>A list of reefs to be included in the run, even if they would otherwise be skipped due to a value of everyx = 1. &nbsp;Also, figures are generated for these reefs even if allFigs is false.</p>
      </td>
    </tr>
    <tr>
      <td valign="bottom" >
        <p>doCoralCoverFigure</p>
      </td>
      <td valign="bottom" >
        <p>false</p>
      </td>
      <td colspan="2" valign="bottom" >
        <p>Produce a figure showing global coral cover over time</p>
      </td>
    </tr>
    <tr>
      <td valign="bottom" >
        <p>doCoralCoverMaps</p>
      </td>
      <td valign="bottom" >
        <p>false</p>
      </td>
      <td colspan="2" valign="bottom" >
        <p>Produce several maps with reefs colored by various health-related values</p>
      </td>
    </tr>
    <tr>
      <td valign="bottom" >
        <p>doDetailedStressStats</p>
      </td>
      <td valign="bottom" >
        <p>false</p>
      </td>
      <td colspan="2" valign="bottom" >
        <p>Save end-of-run statistics at 1-year resolution after 1950, otherwise just 6 years of interest are output.</p>
      </td>
    </tr>
    <tr>
      <td valign="bottom" >
        <p>doGenotypeFigure</p>
      </td>
      <td valign="bottom" >
        <p>false</p>
      </td>
      <td colspan="2" valign="bottom" >
        <p>Plot optimum temperature versus time for each key reef (see keyReefs)</p>
      </td>
    </tr>
    <tr>
      <td valign="bottom" >
        <p>doGrowthRateFigure</p>
      </td>
      <td valign="bottom" >
        <p>false</p>
      </td>
      <td colspan="2" valign="bottom" >
        <p>Plot growth versus temperature for each key reef (see keyReefs)</p>
      </td>
    </tr>
    <tr>
      <td valign="bottom" >
        <p>newMortYears</p>
      </td>
      <td valign="bottom" >
        <p>false</p>
      </td>
      <td colspan="2" valign="bottom" >
        <p>Generate a ".mat" file with the first time each reef experiences 5 years of mortality.</p>
      </td>
    </tr>
    <tr>
      <td valign="bottom" >
        <p>saveVarianceStats</p>
      </td>
      <td valign="bottom" >
        <p>false</p>
      </td>
      <td colspan="2" valign="bottom" >
        <p>Save data for comparing selectional variance and last year of coral cover. &nbsp;A diagnostic only.</p>
      </td>
    </tr>
    <tr>
      <td colspan="4" valign="bottom" >
        <p><strong>Paths</strong></p>
      </td>
    </tr>
    <tr>
      <td valign="bottom" >
        <p>codebase</p>
      </td>
      <td colspan="2" valign="bottom" >
        <p>D:/GitHub/Coral-Model/</p>
      </td>
      <td valign="bottom" >
        <p>Used only by the GUI, this is the location of the model.</p>
      </td>
    </tr>
    <tr>
      <td valign="bottom" >
        <p>m_mapPath</p>
      </td>
      <td colspan="2" valign="bottom" >
        <p>D:/GitHub/m_map/</p>
      </td>
      <td valign="bottom" >
        <p>Source directory for m_map code.</p>
      </td>
    </tr>
    <tr>
      <td valign="bottom" >
        <p>matPath</p>
      </td>
      <td colspan="2" valign="bottom" >
        <p>D:/GitHub/Coral-Model/mat_files/</p>
      </td>
      <td valign="bottom" >
        <p>Location of mat files for biological constants, proportionality constants and some other inputs.</p>
      </td>
    </tr>
    <tr>
      <td valign="bottom" >
        <p>outputBase</p>
      </td>
      <td colspan="2" valign="bottom" >
        <p>D:/CoralTest/ModelResults/</p>
      </td>
      <td valign="bottom" >
        <p>A directory for all output files. &nbsp;Subdirectories will be made to separate runs with different key parameters such as E, OA, and RCP.</p>
      </td>
    </tr>
    <tr>
      <td valign="bottom" >
        <p>omegaPath</p>
      </td>
      <td colspan="2" valign="bottom" >
        <p>D:/GitHub/Coral-Model/ClimateData/</p>
      </td>
      <td valign="bottom" >
        <p>Directory for ocean acidification input files.</p>
      </td>
    </tr>
    <tr>
      <td valign="bottom" >
        <p>sstPath</p>
      </td>
      <td colspan="2" valign="bottom" >
        <p>D:/GitHub/Coral-Model/ClimateData/</p>
      </td>
      <td valign="bottom" >
        <p>Location of the SST histories for each reef cell and climate scenario.</p>
      </td>
    </tr>
    <tr>
      <td >
        <br>
      </td>
      <td >
        <br>
      </td>
      <td >
        <br>
      </td>
      <td >
        <br>
      </td>
    </tr>
  </tbody>
</table>
<p>&nbsp;</p>
<p>&nbsp;</p>



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
