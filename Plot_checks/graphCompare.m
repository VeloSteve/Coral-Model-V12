%% All inputs should be in pairs.  The first two are the x axis and a label.
%
% XXX Note - this function is out of production as of version 0.12.1.  If it is
% used, it must be called in parallelSetup in the same way as Plot_One_Reef()
% is, in order to initialize it properly for parallel used.
%
%  All subsequent argument pairs are a y value and a y label, all to be
%  plotted against the same x axis.
%  The function will attempt to plot all values in one figure for
%  comparison.  As a first cut, put any variable with a range greater than
%  0 to 1 on the left axis, and the rest on the right.
% Arguments:
% fig - figure number to use
% sub - which subplot this data goes on
% ofSubs - total subplots in figure
% add - add curve to previous subplot
% titleText - title
% x, xlab - x axis values and label
% vargin - pairs of y data and y title
function graphCompare(opt, isLast, reef, titleText, topTitle, x, xlab, varargin) 
    persistent fHandle;
    % firstPass refers to the first full figure, not just a single call.
    % Call before reefs with no arguments to set up a clean start.
    if nargin == 0
        % Clear variables for a clean start
        %disp('Clean start in Plot worker for comparision graphs.');
        close all;
        clearvars fHandle; 
        return;
    end
    
    % Save memory and time by limiting each curve to 4000 points - more
    % than enough to exceed what is visible in most graphs.  Only do this
    % if the reduction is substantial, so require 6000.
    %{ 
check before using
    factor = 0;
    if length(x) > 6000
        factor = round(length(x)/4000);
        if factor > 1
           x = decimate(x, factor, 'fir');
        end
    end
    %}
   
    fig = opt.figure;
    sub = opt.count;
    ofSubs = opt.panels;
    %cla;  Affects other figures?
    %clf;
    lv = length(varargin);
    if lv < 3 || mod(lv, 3)
        disp('graphCompare must have at least 10 arguments, flags, x axis values and then sets of arrays, labels and line/symbol flags.');
        return;
    end
    %booleanSpecs = {'*r', '+r', '.c', 'oc', '^k', 'hk'};
    booleanSpecs = {'or', '+r', 'hr', 'ob', '+b', 'hb', 'oy', '+y', 'hy'};
    %doubleSpecs = {'-r', '-b', '-c', '-g', '--r', '--b'};
    % Add lines for two symbiont versions.
    doubleSpecs = {'-r', '-b', '-c', '-g', '-m', '-y', '--r', '--b'};
    bc = 1;
    dc = 1;
    both = 1;
    if sub == 1
        % fprintf('Setting fHandle, subplot %d\n', sub);
        if opt.print
            % Re-use the figure handle, and ignore figure numbers after
            % the first.
            if isempty(fHandle) || (~verLessThan('matlab', '8.4') && ~isvalid(fHandle))
                % fprintf('gC print new handle %d\n', fig);
                fHandle = figure(fig);
                set(gcf,'Visible', 'off');  % Untested as of 1/12/17
            else
                figure(fHandle);
                clf; 
                %fprintf('gC print re-using and clearing handle %d, subplot %d\n', [fHandle.Number], sub);
            end
        else
            % New figure handle as specifed for each set.
            % fprintf('gC noprint new handle %d\n', fig);
            fHandle = figure(fig); 
            set(gcf, 'pos',[20 20 1920 1236]);
        end
        %set(gcf, 'pos',[20 20 1920 1236]);
        %clf;
    else
        % fprintf('gC re-using fHandle number %d, subplot %d\n', [fHandle.Number], sub);
        figure(fHandle);
    end
        
    sp = subplot(ofSubs, 1, sub); % , 'Color', [0.9 0.9 0.9]);
    pos = sp.Position;
    pos(1) = pos(1) + 0.11;
    pos(3) = pos(3) - 0.07;
    set(sp, 'Units', 'normalized', 'Position', pos); % left, bottom, width, height


    for i = 1:3:lv-2
        y = varargin{i};
        isLine = varargin{i+2};
        %if factor > 1
        %    y = decimate(y, factor, 'fir');
        %end
        % Only some callers set unwanted values negative.  Assume that zero
        % is also unwanted.
        y(y==0) = -1;
        %fprintf('gComp sees label %s for set %d with range %0.1f to %0.1f\n', varargin{i+1}, i, min(y), max(y));
        % Deduce what's being plotted.
        useLog = false;
        if ~isLine
            y = y + (bc-1)*0.04;
            yyaxis right;
            %disp('scaling y axis 0.1 to 1.3');
            ylim([0.1 1.3]);
            spec = booleanSpecs{bc};
            set(gca,'YTickLabel',{})
            set(gca,'YTick', [])
            
            bc = bc + 1;
        else
            %disp('double specs left');
            yyaxis left;
            spec = doubleSpecs{dc};
            dc = dc + 1;
            useLog = true;

        end
        %fprintf('Spec: %s\n', spec);

        title(titleText);

        if useLog
            ylim([1.0E4 1.0E9]);
            ax = gca;
            ax.YScale = 'log';
        end
        if i == 1
            if sub == ofSubs
                xlabel(xlab);
            end
            % HARDWIRED! ylabel(varargin{i+1});
            ylabel('Density');
        end
        leg{both} = varargin{i+1};

        if sub < ofSubs
            % xticklabels({}); % Only defined as of 2016b
            set(gca,'XTickLabel',{})
        end
        both = both + 1;
        if i==1, hold on, end
        
    end
    % lv kludge only works with (about) the same number of plotted lines,
    % of two types.
    legFont = 6;
    if lv > 16
        rect = [0.05, 0.44, .09, .15];
        if verLessThan('matlab', '9.1')
            lh = legend(leg);
            set(lh, 'Position', rect)
            set(lh, 'FontSize', legFont)
        else
            legend(leg, 'Position', rect, 'FontSize',legFont);% left, bottom, width, height or: 'location',  'eastoutside');
        end
    else
        %{
        Break flexibility of graphCompare, but second legend is unnecessary
        for 2-panel comparison plots.
        rect = [0.03, 0.094, .09, .104];
        if verLessThan('matlab', '9.1')
           lh = legend(leg);
           set(lh, 'Position', rect)
           set(lh, 'FontSize', legFont)
        else
           legend(leg, 'Position', rect, 'FontSize', legFont);% left, bottom, width, height or: 'location',  'eastoutside');
        end
        %}
    end

    % Subplots done, add an overall title with shared info.
    if isLast
        axes('Position',[0 0 1 1],'Visible','off');
        text(0.35,0.98, topTitle, 'FontSize',12);
        if opt.print
            set(fHandle,'PaperOrientation','portrait');
            % If there are 2 panels, there is one reef.  Otherwise more.
            if ofSubs == 2
                fullName = strcat(opt.out, 'bleachingComparison_', num2str(reef));
            else
                fullName = strcat(opt.out, 'bleachingComparison_to_', num2str(reef));
            end
            %print('-dpdf', fullName, '-fillpage'); 
            print('-dpng', fullName); 
            % Certain plots are also written to an extra directory
            % This only makes sense when there is one reef per plot,
            % because this function is only aware of one reef at a time.
            if ofSubs < 3 && any(reef == opt.keyReefs)
                fullName = strcat(opt.keyOut, 'bleachingComparison_', num2str(reef));
                print('-dpng', fullName);
                    % XXX temporary:
                    % doesn't work (from matlab forum) set(fig,'ResizeFcn','set(gcf,''visible'',''on'')');
                    set(fig, 'visible', 'on');
                    savefig(fullName);
                    delete(fig);
            end
            % delete(fHandle);  % try to solve a memory leak!  Just makes it worse!
        end
    end
    %hold off; % Don't affect other plots. (didn't have desired effect)
end
