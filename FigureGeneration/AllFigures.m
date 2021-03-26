%% One figures script to rule them all.
%  Set the run directory and output directory, and then call as many current
%  diagnostic and publication scripts as possible.
%  The big saving here will be not having to set the input paths in each script
%  by hand.
clear; close all; 
% MATLAB docs say "clear all" is a performance killer, but it seems to help one
% of the scripts, which otherwise picks up an occasional wrong input image.
clear all;

% Check all 4 lines for correct data and labeling!
runDateString = '20210306';
runLabel = 'SimplerL2.6 y=0.32, min=0.5';
runOutputs = 'C:\CoralTest\Mar2021_SimplerL2.6_0.5-1.5-0.32_Target5\';
figureDir = 'C:\Users\Steve\Google Drive\Coral_Model_Steve\2021_FebruaryChanges\Mar2021_SimplerL2.6_0.5-1.5-0.32_Target5\VectorColor\';

extras = false; % any thing not a publication figure

if ~isfolder(figureDir)
    mkdir(figureDir);
end
runID = replace(runLabel, ',', ' ');
runID = replace(runID, '  ', ' ');
runID = replace(runID, {' '}, '_');
runID = replace(runID, '__', '_');
runID = replace(runID, {'[', ']'}, '');

% Table of cover and health stats.
if extras; Table1_S1; end
% SelV correlation figure.  This also puts a text table of bleaching percentages
% in BleachingPercent.txt
if extras; Cover_CWB_SelV_comparison; end
% Bleaching over time (a really ugly script - clean it up!)
if extras; ColdBleachingCheck; end
% Figure 1.  Healthy reefs over time.
%GOOD BleachingHistory_Subplots_WithDT_Row_direct(runOutputs, figureDir, runID)
% The next two scripts run from FigureManipulation, as they combine existing
% figures.
addpath('../FigureManipulation');
% Figure 2. Coral cover subplots
close all;  % This one tends to fail unpredicatably:
%GOOD MergeCoverPlots_TwelveCases_direct
% Figure 3. Coral health maps.
MergeSelectedLastYearMaps_shuffle_direct
return;
close all;

% Copy the per-reef figures for just our favorite "keyReefs" set.
% Why does copyfile require 'f' when the save functions can write with no
% special permission?
copyfile(strcat(runOutputs, 'ESM2M.rcp45.E0.OA0.sM9.sA1.0.', runDateString, '_figs\', 'SDC*.png'), figureDir, 'f');

% Open an example symbiont dominance figure and save as png.  Also copy the fig.
domFn = strcat(runOutputs, 'ESM2M.rcp45.E0.OA0.sM9.sA1.0.', runDateString, '_maps\SymbiontDominance.fig');
open(domFn);
saveCurrentFigure(strcat(figureDir, 'SymbiontDominance_rcp45_E0_Shuffling'));
copyfile(domFn, figureDir, 'f');


close all;