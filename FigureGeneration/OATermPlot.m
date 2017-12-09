% WARNING: must import CSV file as a numeric matrix before running.  IF
% there's an existing matrix with the same name the new one will be renamed
% and you won't see it here!

ttt = 'RCP 4.5, Reef 144, Moorea';
figure()

subplot(6,1,1)
plot(OADiagnostic(:, 1), OADiagnostic(:, 4), 'DisplayName', 'OA Factor');
ylabel('OA Factor')
legend('Location', 'west')
ax = gca;
ax.XAxis.TickLabelFormat = '%5.0f';
ax.XAxis.Exponent = 0;

subplot(6,1,2)
plot(OADiagnostic(:, 1), OADiagnostic(:, 9), 'DisplayName', 'G mass');
hold on;
plot(OADiagnostic(:, 1), OADiagnostic(:, 10), 'DisplayName', 'G bran');
plot(OAoffDiagnostic(:, 1), OAoffDiagnostic(:, 9), 'DisplayName', 'G mass, no OA');
plot(OAoffDiagnostic(:, 1), OAoffDiagnostic(:, 10), 'DisplayName', 'G bran, no OA');
ylabel('OA effect on growth')
legend('Location', 'west')
ax = gca;
ax.XAxis.TickLabelFormat = '%5.0f';
ax.XAxis.Exponent = 0;

subplot(6,1,3)
plot(OADiagnostic(:, 1), OADiagnostic(:, 11), 'DisplayName', 'FAC mass');
hold on;
plot(OADiagnostic(:, 1), OADiagnostic(:, 12), 'DisplayName', 'FAC bran');
plot(OAoffDiagnostic(:, 1), OAoffDiagnostic(:, 11), 'DisplayName', 'FAC mass, no OA');
plot(OAoffDiagnostic(:, 1), OAoffDiagnostic(:, 12), 'DisplayName', 'FAC bran, no OA');
ylabel('Symbiont effect')
legend('Location', 'west')
ax = gca;
ax.XAxis.TickLabelFormat = '%5.0f';
ax.XAxis.Exponent = 0;

subplot(6,1,4)
plot(OADiagnostic(:, 1), OADiagnostic(:, 7), 'DisplayName', 'KC mass');
hold on;
plot(OADiagnostic(:, 1), OADiagnostic(:, 8), 'DisplayName', 'KC bran');
plot(OAoffDiagnostic(:, 1), OAoffDiagnostic(:, 7), 'DisplayName', 'KC mass, no OA');
plot(OAoffDiagnostic(:, 1), OAoffDiagnostic(:, 8), 'DisplayName', 'KC bran, no OA');
ylabel('K effect')
legend('Location', 'west')
ax = gca;
ax.XAxis.TickLabelFormat = '%5.0f';
ax.XAxis.Exponent = 0;

subplot(6,1,5)
plot(OADiagnostic(:, 1), OADiagnostic(:, 13), 'DisplayName', 'MU mass');
hold on;
plot(OADiagnostic(:, 1), OADiagnostic(:, 14), 'DisplayName', 'MU bran');
plot(OAoffDiagnostic(:, 1), OAoffDiagnostic(:, 13), 'DisplayName', 'MU mass, no OA');
plot(OAoffDiagnostic(:, 1), OAoffDiagnostic(:, 14), 'DisplayName', 'MU bran, no OA');
ylabel('Mortality')
legend('Location', 'west')
ax = gca;
ax.XAxis.TickLabelFormat = '%5.0f';
ax.XAxis.Exponent = 0;

subplot(6,1,6)
plot(OADiagnostic(:, 1), OADiagnostic(:, 15), 'DisplayName', 'dCk mass');
hold on;
plot(OADiagnostic(:, 1), OADiagnostic(:, 16), 'DisplayName', 'dCk bran');
plot(OAoffDiagnostic(:, 1), OAoffDiagnostic(:, 15), 'DisplayName', 'dCk mass, no OA');
plot(OAoffDiagnostic(:, 1), OAoffDiagnostic(:, 16), 'DisplayName', 'dCk bran, no OA');
plot(xlim, [0 0], 'k', 'DisplayName', 'Zero');

ylabel('delta Coral')
xlabel('Time Step');
legend('Location', 'west')
ax = gca;
ax.XAxis.TickLabelFormat = '%5.0f';
ax.XAxis.Exponent = 0;

annotation(gcf,'textbox',...
    [0.280 0.134 0.278 0.04],...
    'String',{'dCk = dt * C * (GFAC * KC - MU)'},...
    'FontSize',24,...
    'FitBoxToText','off');

annotation(gcf,'textbox',...
    [0.369459962756052 0.947329376854599 0.260707635009311 0.0370919881305638],...
    'String',{ttt},...
    'FontWeight','bold',...
    'FontSize',24,...
    'FitBoxToText','off');

%%
% Now reduce number of subplots and zoom in.
figure()

subplot(2,1,1)
plot(OADiagnostic(:, 1), OADiagnostic(:, 9).*OADiagnostic(:, 11), 'DisplayName', 'G*FAC mass');
hold on;
plot(OADiagnostic(:, 1), OADiagnostic(:, 10).*OADiagnostic(:, 12), 'DisplayName', 'G*FAC bran');
plot(OAoffDiagnostic(:, 1), OAoffDiagnostic(:, 9).*OAoffDiagnostic(:, 11), 'DisplayName', 'G*FAC mass, no OA');
plot(OAoffDiagnostic(:, 1), OAoffDiagnostic(:, 10).*OAoffDiagnostic(:,12), 'DisplayName', 'G*FAC bran, no OA');
ylabel('OA & Symbiont effect')
legend('Location', 'west')
xlim([14000 22000])
ax = gca;
ax.XAxis.TickLabelFormat = '%5.0f';
ax.XAxis.Exponent = 0;

subplot(2,1,2)
plot(OADiagnostic(:, 1), OADiagnostic(:, 7), 'DisplayName', 'KC mass');
hold on;
plot(OADiagnostic(:, 1), OADiagnostic(:, 8), 'DisplayName', 'KC bran');
plot(OAoffDiagnostic(:, 1), OAoffDiagnostic(:, 7), 'DisplayName', 'KC mass, no OA');
plot(OAoffDiagnostic(:, 1), OAoffDiagnostic(:, 8), 'DisplayName', 'KC bran, no OA');
ylabel('K effect')
xlabel('Time Step');
legend('Location', 'west')
xlim([14000 22000]);
ax = gca;
ax.XAxis.TickLabelFormat = '%5.0f';
ax.XAxis.Exponent = 0;


annotation(gcf,'textbox',...
    [0.280 0.334 0.278 0.04],...
    'String',{'dCk = dt * C * (GFAC * KC - MU)'},...
    'FontSize',24,...
    'FitBoxToText','off');


annotation(gcf,'textbox',...
    [0.369459962756052 0.947329376854599 0.260707635009311 0.0370919881305638],...
    'String',{ttt},...
    'FontWeight','bold',...
    'FontSize',24,...
    'FitBoxToText','off');