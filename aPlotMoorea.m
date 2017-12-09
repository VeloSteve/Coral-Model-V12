load('MooreaRCP45E1OA1');
t1 = datenum('1995-01-01');
t2 = datenum('2000-01-01');
% plot with our usual units
subplot(5,1,1);
plot(time, temp);
xlim([t1 t2]);
datetick('x', 'keeplimits');
ylabel('degrees C');

title('Bahamas, Lee Stocking Island');

subplot(5,1,2);
plot(time, C(:,1));
xlim([t1 t2]);
datetick('x', 'keeplimits');
ylabel([' Massive Coral  '; 'cm^2 per 625 m^2']);

subplot(5,1,3);
plot(time, C(:,2));
xlim([t1 t2]);
datetick('x', 'keeplimits');
ylabel(['Branching Coral '; 'cm^2 per 625 m^2']);

subplot(5,1,4);
plot(time, S(:,1)./C(:,1));
xlim([t1 t2]);
datetick('x', 'keeplimits');
ylabel([' Massive symb '; 'cells per cm^2']);

subplot(5,1,5);
plot(time, S(:,2)./C(:,2));
xlim([t1 t2]);
datetick('x', 'keeplimits');
ylabel(['Branching symb'; 'cells per cm^2']);