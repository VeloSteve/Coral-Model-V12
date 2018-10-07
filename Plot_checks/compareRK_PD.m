% Plot old C versus Dormand-Prince C.

figure()
plot(time, C(:,1), 'DisplayName', 'Massive', 'Color', [1 0 1])
hold on;
plot(time, C(:,2), 'DisplayName', 'Branching', 'Color', [0 0 1])

% Time for PD is in months, but for old data it's in equally spaced double
% time values.  Convert, noting that both start at the same time.
%{
too coarse due to required rounding!
start = time(1);
for i = length(tPD):-1:1
    tConv(i) = addtodate(start, round(tPD(i)), 'month');
end
%}
start = time(1);
tEnd = time(end);
mmm = tPD(end)-tPD(1);
rat = (tEnd-start)/mmm;
for i = length(tPD):-1:1
    tConv(i) = tPD(i)*rat + start;
end

% what is this?
datenum(strcat(num2str(startYear),'-01-01'));

plot(tConv, CPD(:,1), 'DisplayName', 'D-P', 'Color', [0 0 0])
plot(tConv, CPD(:,2), 'DisplayName', 'D-P', 'Color', [0 0 0])
hold off;
datetick('x', 'keeplimits')
legend('show');
title('Corals - compare original R-K to Dormand-Prince, reef 366');

% Now the symbionts
figure()
plot(time, S(:,1), 'DisplayName', 'Massive', 'Color', [1 1 0])
hold on;
plot(time, S(:,2), 'DisplayName', 'Branching', 'Color', [0 1 0])



plot(tConv, SPD(:,1), 'DisplayName', 'D-P', 'Color', [0 0 0])
plot(tConv, SPD(:,2), 'DisplayName', 'D-P', 'Color', [0 0 0])
hold off;
datetick('x', 'keeplimits')
legend('show');
title('Symbionts - compare original R-K to Dormand-Prince, reef 366');
