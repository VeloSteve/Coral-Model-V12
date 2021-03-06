function [dataset, RCP, E, OA, superMode, superAdvantage, superGrowthPenalty, superStart, ...
          outputPath, sstPath, matPath, m_mapPath, ...
          architecture, useThreads, everyx, specialSubset, ...
          keyReefs, skipPostProcessing, doPlots, ...
          doCoralCoverMaps, doCoralCoverFigure, doGrowthRateFigure, ...
          doGenotypeFigure, doDetailedStressStats, allFigs, ...
          saveVarianceStats, newMortYears, optimizerMode, bleachingTarget] = explodeVariables(p)
%EXPLODEVARIABLES Extract parameter structure to program variables.
%   
% Note that assigning these programatically is tempting, and there are
% ways. However, MATLAB code is parsed before any such code, possibly
% causing confusion between functions and variables with the same name.
% Just do it the verbose but simple way:

    % Science variables
    dataset = p.dataset;
    RCP = p.RCP;
    E = p.E;
    OA = p.OA;
    superMode = p.superMode;
    superAdvantage = p.superAdvantage;
    superGrowthPenalty = p.superGrowthPenalty;
    superStart = p.superStart;
    % Bookkeeping variables
    outputPath = p.outputBase;  % Note name change.
    sstPath = p.sstPath;
    matPath = p.matPath;
    m_mapPath = p.m_mapPath;
    % Computing variables
    architecture = p.architecture;
    useThreads = p.useThreads; % Note name change
    everyx = p.everyx;
    specialSubset = p.specialSubset;
    % Output variables
    keyReefs = p.keyReefs;
    skipPostProcessing = p.skipPostProcessing;
    doPlots = p.doPlots;
    doCoralCoverMaps = p.doCoralCoverMaps;
    doCoralCoverFigure = p.doCoralCoverFigure;
    doGrowthRateFigure = p.doGrowthRateFigure;
    doGenotypeFigure = p.doGenotypeFigure;
    doDetailedStressStats = p.doDetailedStressStats;
    allFigs = p.allFigs;
    saveVarianceStats = p.saveVarianceStats;
    newMortYears = p.newMortYears;
    optimizerMode = p.optimizerMode;
    bleachingTarget = p.bleachingTarget;
end

