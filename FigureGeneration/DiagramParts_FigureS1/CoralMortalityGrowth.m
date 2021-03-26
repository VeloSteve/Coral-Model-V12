% Separate coral mortality and growth curves for Figure S1
%
% From Runge-Kutta-2
%  dCk1 = dt .* (Cold .* (G .* SA./ (KSx .* Cold).* (KCx-(alpha*Cold')')./KCx - Mu ./(1+um .* SA./(KSx .* Cold))) );
load('../../mat_files/Coral_Sym_constants_4.mat', 'coralSymConstants');

% Take the equation above and turn it into a function of SA only, using massive
% as the example. SA is just the sum of all symbiont types.
G = coralSymConstants.Gm;
KS = coralSymConstants.KSm;
Cold = 1 * coralSymConstants.KCm; % a variable in the model, just assume it's at 0.5K
KC = coralSymConstants.KCm;
alpha = coralSymConstants.Am;
Mu = coralSymConstants.Mu_m;
um = coralSymConstants.um_m;
dt = 1/8;
S = linspace(1e13, 2e14, 200);
% Not that most vector related notation (.*, x') can be dropped from this version.
growth = G * S / (KS * Cold)* (KC-alpha*Cold)/KC;
mortality = Mu ./(1+um * S/(KS * Cold));
%  dCk1 = dt .* (Cold .* (growth - mortality) );


mainFig = figure('color', 'w');
set(gcf,...
    'Units', 'inches', ...
    'Position',[4  6 3.5 2.7]);


plot(S, growth, '--k', 'LineWidth', 2);
hold on;
plot(S, mortality, '-k', 'LineWidth', 2);
% System has Helvetica according to Matlab, but not Adobe Illustrator!
set(gca, 'FontSize', 14);
xlabel('Symbiont density (S{\it_i_m})');
ylabel('Rate');
yticks([]);
xticks([]);
box off
%title('Environmental effects', 'FontWeight', 'normal');
% Arrow across the middle of the curve.
annotation(mainFig,'arrow',[0.25 0.2], [0.85 0.6], 'LineWidth', 1.5); % Mortality
annotation(mainFig,'arrow',[0.32 0.4], [0.65 0.3], 'LineWidth', 1.5); % Growth
% Mort
annotation(gcf, 'textbox', ...
    [0.18, 0.92, 0.03, 0.03], ...
    'String', 'Coral Mortality (\mu, u, K_s)', ...
    'FontSize', 14, 'FitBoxToText', 'on', 'LineStyle', 'none');
% Growth
annotation(gcf, 'textbox', ...
    [0.25, 0.75, 0.03, 0.03], ...
    'String', ["Coral Growth"; "      (f(\Omega_{Arag}, \gamma, S, K_C, K_S, \alpha)"], ...
    'FontSize', 14, 'FitBoxToText', 'on', 'LineStyle', 'none');

saveCurrentFigure("C:\Users\Steve\Google Drive\Coral_Model_Steve\2021_FebruaryChanges\Mar2021_SimplerL2.6_0.5-1.5-0.32_Target5\VectorBlackWhite\GrowthMortality")
