% Table 1 is made of cover and health stats from a collection of console.txt
% files.  This has been done manually, but perhaps it can be automated.

% Support calls from the multi-plot script
if (exist('runOutputs', 'var') == 1) && (length(runOutputs) > 0)
    base = runOutputs;
else
    % Edit to match the current run.
    base = 'C:\CoralTest\Mar2021_SimplerL2.6_0.5-1.5-0.32_Target5\';
    runDateString = '20210306';
end

% Output from this script:
if ~exist('figureDir', 'var') || isempty(figureDir)
    % For safety, set the variable externally, rather than editing it here.
    figureDir = './';
end

%% For Table 1
outfile = strcat(figureDir, 'Table1ValuesOutput.txt');
oid = fopen(outfile,'w');
fprintf(oid, "RCP      No adapt       E=1            Shuffling      Both\n");
fprintf(oid, "         c    h    b    c    h    b    c    h    b    c    h    b\n");
% We want to find console.txt for all 4 RCPs and 4 adaptations, but always OA=0
% The loops are ordered to collect values in the order they are printed.
for rrr = {'rcp26', 'rcp45', 'rcp60', 'rcp85'};
    fprintf(oid, '%s', rrr{1});
    for adv = ["0.0", "1.0"]
        for eee = ['0' '1']
            % ESM2M.rcp26.E0.OA0.sM9.sA0.0.20210227_maps
            dn = strcat('ESM2M.', rrr{1}, '.E', eee, '.OA0.sM9.sA', adv, '.', runDateString, '_maps\');
            fn = strcat(base, dn, 'console.txt');
            fid = fopen(fn, 'r');
            if fid == -1
                error("Could not open file %s", fn);
            end
            % Read file into cells, skipping 39 lines.  That is not an exact
            % number, but will reduce the amount of data stored.
            c=textscan(fid, '%s', 'HeaderLines', 39, 'delimiter', '\n');
            pos = find(~cellfun(@isempty, strfind(c{1}, 'All Reefs')));
            parts = split(strtrim(c{1}{pos}));
            unhealthy = str2double(parts(end-1));
            % Get rid of unneeded lines.
            c = c{1}(pos+1:end, 1);
            pos = find(~cellfun(@isempty, strfind(c, 'Global average')));
            parts = split(strtrim(c(pos)));
            cover = str2double(parts(end));
            % Get rid of unneeded lines.
            c = c(pos+1:end);
            pos = find(~cellfun(@isempty, strfind(c, 'Fraction of reefs dominated by branching')));
            parts = split(strtrim(c(pos)));
            branching = str2double(parts(end));
            fclose(fid);
            fprintf(oid, ', %3.0f, %3.0f, %3.0f', cover, (100-unhealthy), 100*(branching));
        end
    end
    fprintf(oid, "\n");
end
fclose(oid);

%% Repeat for Table S1, which adds shuffling at 0.5 and 1.5 C advantages. Many
%  values are repeated from Table 1, but just get them again.
outfile = strcat(figureDir, 'TableS1ValuesOutput.txt');
oid = fopen(outfile,'w');
fprintf(oid, "         No adapt       E=1                           Shuffling                                    Both\n");
fprintf(oid, "RCP                                       +0.5           +1.0           +1.5           +0.5           +1.0           +1.5\n");
fprintf(oid, "         c    h    b    c    h    b    c    h    b    c    h    b    c    h    b    c    h    b    c    h    b    c    h    b\n");
% We want to find console.txt for all 4 RCPs and 8 adaptations, but always OA=0.
% The loops are ordered to collect values in the order they are printed, which
% is a little different than for Table 1.
for rrr = {'rcp26', 'rcp45', 'rcp60', 'rcp85'};
    fprintf(oid, '%s', rrr{1});
    for adv = ["0.0"]
        for eee = ['0' '1']
            % ESM2M.rcp26.E0.OA0.sM9.sA0.0.20210227_maps
            dn = strcat('ESM2M.', rrr{1}, '.E', eee, '.OA0.sM9.sA', adv, '.', runDateString, '_maps\');
            fn = strcat(base, dn, 'console.txt');
            fid = fopen(fn, 'r');
            if fid == -1
                error("Could not open file %s", fn);
            end
            % Read file into cells, skipping 39 lines.  That is not an exact
            % number, but will reduce the amount of data stored.
            c=textscan(fid, '%s', 'HeaderLines', 39, 'delimiter', '\n');
            pos = find(~cellfun(@isempty, strfind(c{1}, 'All Reefs')));
            parts = split(strtrim(c{1}{pos}));
            unhealthy = str2double(parts(end-1));
            % Get rid of unneeded lines.
            c = c{1}(pos+1:end, 1);
            pos = find(~cellfun(@isempty, strfind(c, 'Global average')));
            parts = split(strtrim(c(pos)));
            cover = str2double(parts(end));
            % Get rid of unneeded lines.
            c = c(pos+1:end);
            pos = find(~cellfun(@isempty, strfind(c, 'Fraction of reefs dominated by branching')));
            parts = split(strtrim(c(pos)));
            branching = str2double(parts(end));
            fclose(fid);
            fprintf(oid, ', %3.0f, %3.0f, %3.0f', cover, (100-unhealthy), 100*(branching));
        end
    end
    % The 3 non-zero advantage values are consecutive, grouped by E value.
    for eee = ['0' '1']
        for adv = ["0.5", "1.0", "1.5"]
            % ESM2M.rcp26.E0.OA0.sM9.sA0.0.20210227_maps
            dn = strcat('ESM2M.', rrr{1}, '.E', eee, '.OA0.sM9.sA', adv, '.', runDateString, '_maps\');
            fn = strcat(base, dn, 'console.txt');
            fid = fopen(fn, 'r');
            if fid == -1
                error("Could not open file %s", fn);
            end
            % Read file into cells, skipping 39 lines.  That is not an exact
            % number, but will reduce the amount of data stored.
            c=textscan(fid, '%s', 'HeaderLines', 39, 'delimiter', '\n');
            pos = find(~cellfun(@isempty, strfind(c{1}, 'All Reefs')));
            parts = split(strtrim(c{1}{pos}));
            unhealthy = str2double(parts(end-1));
            % Get rid of unneeded lines.
            c = c{1}(pos+1:end, 1);
            pos = find(~cellfun(@isempty, strfind(c, 'Global average')));
            parts = split(strtrim(c(pos)));
            cover = str2double(parts(end));
            % Get rid of unneeded lines.
            c = c(pos+1:end);
            pos = find(~cellfun(@isempty, strfind(c, 'Fraction of reefs dominated by branching')));
            parts = split(strtrim(c(pos)));
            branching = str2double(parts(end));
            fclose(fid);
            fprintf(oid, ', %3.0f, %3.0f, %3.0f', cover, (100-unhealthy), 100*(branching));
        end
    end
    
    fprintf(oid, "\n");
end
fclose(oid);