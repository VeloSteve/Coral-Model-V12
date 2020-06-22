figure();
[ha, pos] = tight_subplot(3,2,[.01 .03],[.5 .01],[.01 .01])
for ii = 1:6; axes(ha(ii)); plot(randn(10,ii)); end
set(ha(1:4),'XTickLabel',''); set(ha,'YTickLabel','')
% numbers in brackets are
% 1) Vertical gap between axes.
% 3) Lower vertical margin (for the whole figure)
% 5) Left overall margin

% Units are fraction of figure size.