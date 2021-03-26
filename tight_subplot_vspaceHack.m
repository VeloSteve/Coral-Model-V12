function [ha, pos] = tight_subplot_vspaceHack(Nh, Nw, gap, marg_h, marg_w, ratio_w, ratio_h, vGap)

% tight_subplot creates "subplot" axes with adjustable gaps and margins
%
% [ha, pos] = tight_subplot(Nh, Nw, gap, marg_h, marg_w, ratio_w)
%
%   in:  Nh      number of axes in hight (vertical direction)
%        Nw      number of axes in width (horizontaldirection)
%        gap     gaps between the axes in normalized units (0...1)
%                   or [gap_h gap_w] for different gaps in height and width 
%        marg_h  margins in height in normalized units (0...1)
%                   or [lower upper] for different lower and upper margins 
%        marg_w  margins in width in normalized units (0...1)
%                   or [left right] for different left and right margins 
%        ratio_w relative width of the axes in a single row.  For example if
%                axes use the same units but show different ranges, this is
%                useful.  Defaults to an array of ones.
%        ratio_h relative height of the axes in a single column. Defaults to
%                an array of ones.
%        vGap    if given, overrides vertical gap with the provided list of gaps
%
%  out:  ha     array of handles of the axes objects
%                   starting from upper left corner, going row-wise as in
%                   subplot
%        pos    positions of the axes objects
%
%  Example: ha = tight_subplot(3,2,[.01 .03],[.1 .01],[.01 .01])
%           for ii = 1:6; axes(ha(ii)); plot(randn(10,ii)); end
%           set(ha(1:4),'XTickLabel',''); set(ha,'YTickLabel','')

% Pekka Kumpulainen 21.5.2012   @tut.fi
% Tampere University of Technology / Automation Science and Engineering


if nargin<3; gap = .02; end
if nargin<4 || isempty(marg_h); marg_h = .05; end
if nargin<5 || isempty(marg_w); marg_w = .05; end
if nargin<6 || isempty(ratio_w); ratio_w = ones([Nh, Nw]); end
if nargin<7 || isempty(ratio_h); ratio_h = ones([Nh, 1]); end
% if nargin<8 || isempty(vGap); newGap = gap(1) * ones([Nh-1, 1]); end
ratioWTotal = sum(ratio_w(1, :));
ratioHTotal = sum(ratio_h(1, :));

if isempty(vGap) && numel(gap)==1; 
    newGap = gap * ones([Nh-1, 1]);
else
    newGap = vGap;
end
if numel(marg_w)==1; 
    marg_w = [marg_w marg_w];
end
if numel(marg_h)==1; 
    marg_h = [marg_h marg_h];
end

axh = (1-sum(marg_h)-sum(newGap))/Nh; % v size of average plot, e.g. 0.0630
axhUnit = Nh * axh / ratioHTotal;  % total axes height / total of ratio values  e.g. 0.0875

axw = (1-sum(marg_w)-(Nw-1)*gap(2))/Nw;
axwUnit = Nw * axw / ratioWTotal;

py = 1-marg_h(2)-axhUnit * ratio_h(1); % Position of bottom of first row.

ha = zeros(Nh*Nw,1);
ii = 0;
for ih = 1:Nh
    px = marg_w(1);
    
    for ix = 1:Nw
        ii = ii+1;
        ha(ii) = axes('Units','normalized', ...
            'Position',[px py axwUnit*ratio_w(ix) axhUnit*ratio_h(ih)], ...
            'XTickLabel','', ...
            'YTickLabel','');
        px = px+axwUnit*ratio_w(ix)+gap(2);
    end
    if ih < Nh
        py = py-axhUnit*ratio_h(min(ih+1, Nh))-newGap(ih);
    end
end
if nargout > 1
    pos = get(ha,'Position');
end
ha = ha(:);
