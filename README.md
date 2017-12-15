# Coral-Model-V12
This version of the coral model will focus on data management changes.  Details
may change as development goes on, but here are some initial goals and ideas.
 
Goals
•	Know what cases have already been run.
•	Find subsets of completed cases easily.
•	Associate code versions with results so it is possible to tell whether
    results computed days or months apart are comparable.  Have only the selected
    parameters changed, or have there been bug fixes or other changes that affect results.
•	Maintain a set of reference results to show when the model has changed in a way that affects results.
•	Keep metadata in a form which is
    o	Easily machine-readable
    o	Human-readable
    o	Complete enough to reproduce runs
•	When a new significant code version is made, archive it so results can be reproduced
    or new parameter variations can be added.
•	Keep results in at least two independent places, at least when they have been used for publications.
•	Apply compression when it makes sense.
•	Give each dataset a unique but small tag which can be used in place of long directory or file names.
•	Use a well-thought-out set of directory and file names.
•	Anticipate what public data repositories we are likely to use and make our metadata
    compatible or easily converted.
•	Use a metadata approach which is easily extended when a new parameter is added.  
    When this is done, the previous default should be made available so it can be applied
    retroactively to old runs.  For example, if macroalgae competition becomes an option, and an on/off
    flag is define, we should automatically know that the value was “off” for older runs.
•	Generate as much metadata automatically as possible.
•	Prompt the user for timely entry of additional metadata which can’t be automated
    (e.g. Why was this run done?).
•	Integrate metadata creation with the GUI and with optimization runs.
•	Isolate input adjustments and all outputs from the code directories.  Parameter adjustments and
    test runs should never trigger a GitHub putback of the code.  At the same time, isolate
    GUI development – the only connection should be the set of available parameters, treated as an API.
•	Pull out the m_map code which isn't ours so it's not in our repository!

Approach
•	As of code version 12, have 3 or more GitHub repositories
    o	GUI
    o	Optimization code
    o	Model code
    o	Post-processing code for figure generation (?)
•	Consider directory organization for these uses:
    o	GitHub local repositories
    o	A run directory which is NOT the repository
    o	Program outputs
    o	Derived outputs such as figures generated from multiple runs and/or for papers.
•	Establish a dictionary of parameters in the model code which can be output as a web page.
•	Reflect all model parameters in the GUI, and require a full set when running the model.
•	Send parameters to the model in a single structure or JSON string, and use the same
    one for optimization.
•	Ensure that output from a unique run goes to a unique directory, possibly using a limited hierarchy.
•	Re-think the “useComputer” code from scratch so it’s less confusing.  Same for
    file and directory name generation.
•	In the GUI, add a feature to see all completed runs which have any data stored, with the
    ability to filter by at least some parameters including
    o	Date range
    o	Code version
    o	RCP scenario
    o	Super symbionts in use?
    o	Evolution
•	Add a one-button option to generate, store base cases for any major code change.  Ideally automate a
    comparison of old to new results and flag differences.


File and directory names.
For the run, possibly include: run date, code version, RCP, E, OA, SuperSymbiont info, climate model...
For individual reefs, could have lat, lon, cell number, psw2, ...
Should these be in the top directory only?  In subdirs or file names?  In V11, a figure path looks like:
D:\CoralTest\V11Test\ESM2Mrcp45.E1.OA0_NF1_sM0_sA0_20171206_figs\SDC_20171206_1_normSSTrcp45_-19_-180_prop0.71_NF1_E1.fig
Try
D:\CoralTest\V11Test\ESM2Mrcp45.E1.OA0_NF1_sM0_sA0_20171206_figs\SDC_20171206_1_normSSTrcp45_-19_-180_prop0.71_NF1_E1.fig
