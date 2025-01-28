%% Paths
root = [];
dataPath = [];
functionPath = [];

addpath(dataPath)
addpath(functionPath)
%% Load the data
load('JANUARY_TFCE_MovOnset_Unfold.mat','Data'); dataMov = Data;
load('JANUARY_TFCE_MovOnset_Unfold.mat','Info'); infoMov = Info;
load('JANUARY_TFCE_MovOnset_Unfold.mat','Results'); resultsMov = Results;
load('JANUARY_TFCE_MovOnset_Unfold.mat','S'); sMov = S;
load('JANUARY_TFCE_MovOnset_Unfold.mat','idxSC'); idxSCMov = idxSC;
load('JANUARY_TFCE_MovOnset_Unfold.mat','pValuesBelowThreshold'); pValuesMov = pValuesBelowThreshold;
load('JANUARY_TFCE_MovOnset_Unfold.mat','Ch'); chPic = Ch;

% Load time vector
load('unfoldResults_December_MovOnset.mat','time'); timeMov = time;

% Load channel locations
load([dataPath,filesep,'chanLocs'])

clear Data Info Results S idxSC pValuesBelowThreshold time Ch
%% Figure 7: 
posMov = squeeze(mean(dataMov{1,1},1)) + squeeze(mean(dataMov{2,1},1));
negMov = squeeze(mean(dataMov{1,2},1)) + squeeze(mean(dataMov{2,2},1));
difValMov = posMov-negMov;
% Color map for topoplots
numColors = 20; 
blue = [0.2567,0.4185,0.9962];  
white = [1, 1, 1]; 
red = [0.2291,0.7880,0.5757];   
cmaptopo = interp1([0, 0.5, 1], [blue; white; red], linspace(0, 1, numColors));
% Color map for ERPs
cmapERP = parula(20);

% Change the units of the time vector
timeMov = timeMov*1000;

% Define a smalled temporal window for plotting
idxStartMov = find(timeMov == -500);
ixdEndMov = find(timeMov == 400);

% Define parameters
x_posMov = (-500 + 30);
y_pos = -7;

% Compute Confidence Interval
alpha = 0.05;
[positiveMovCI,positiveMovERP] = compute_CI(dataMov{1,1}+dataMov{2,1},alpha);
[negativeMovCI,negativeMovERP] = compute_CI(dataMov{1,2}+dataMov{2,2},alpha);

% Define what to plot
[unique_S, ~, idx] = unique(sMov.B);
Ch_by_time = cell(length(unique_S), 1);

% Loop through each unique time point and gather corresponding Ch values
for i = 1:length(unique_S)
    % Find indices in S that match the current unique time
    corresponding_indices = (sMov.B == unique_S(i));
    % Get corresponding Ch values for the current time point
    Ch_by_time{i} = chPic.B(corresponding_indices);
end

figure('Renderer', 'painters', 'Position', [10 10 1000 650])
t = tiledlayout(5,4,'TileSpacing', 'compact', 'Padding', 'compact');
nexttile([1,4])
[~,~] = plotCI(squeeze(positiveMovERP(56,idxStartMov:ixdEndMov)),squeeze(positiveMovCI(56,idxStartMov:ixdEndMov,:)),timeMov(idxStartMov:ixdEndMov),cmapERP(10,:),14);
hold on
[~,~] = plotCI(squeeze(negativeMovERP(56,idxStartMov:ixdEndMov)),squeeze(negativeMovCI(56,idxStartMov:ixdEndMov,:)),timeMov(idxStartMov:ixdEndMov),cmapERP(1,:),14);
xlim([-500 400])
ylim([-11 11])
xlabel('Time (ms)')
ylabel('Amplitude (mV)')
legend('Positive','','Negative','','','Location','northwest','FontSize',14)
vline(0,'k')
hline(0,'k')
text(x_posMov, y_pos, sprintf(chanLocs(56).labels), 'HorizontalAlignment', 'left', 'VerticalAlignment', 'bottom', 'FontSize', 14);
c = xregion(-30,10);
c.FaceColor = [0.5 0.5 0.5 0.5];
c.FaceAlpha = 0.2;
c.HandleVisibility = 'off';
ylimits = ylim;
text(-530, ylimits(2), 'A', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', ...
    'FontSize', 14, 'FontWeight', 'bold', 'Rotation', 0);
nexttile([1,4])
[~,~] = plotCI(squeeze(positiveMovERP(30,idxStartMov:ixdEndMov)),squeeze(positiveMovCI(30,idxStartMov:ixdEndMov,:)),timeMov(idxStartMov:ixdEndMov),cmapERP(10,:),14);
hold on
[~,~] = plotCI(squeeze(negativeMovERP(30,idxStartMov:ixdEndMov)),squeeze(negativeMovCI(30,idxStartMov:ixdEndMov,:)),timeMov(idxStartMov:ixdEndMov),cmapERP(1,:),14);
xlim([-500 400])
ylim([-11 11])
xlabel('Time (ms)')
ylabel('Amplitude (mV)')
legend('Positive','','Negative','','','Location','northwest','FontSize',14)
vline(0,'k')
hline(0,'k')
text(x_posMov, y_pos, sprintf(chanLocs(30).labels), 'HorizontalAlignment', 'left', 'VerticalAlignment', 'bottom', 'FontSize', 14);
c = xregion(-30,10);
c.FaceColor = [0.5 0.5 0.5 0.5];
c.FaceAlpha = 0.2;
c.HandleVisibility = 'off';
ylimits = ylim; 
text(-530, ylimits(2), 'B', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', ...
    'FontSize', 14, 'FontWeight', 'bold', 'Rotation', 0); 
nexttile([1,4])
[~,~] = plotCI(squeeze(positiveMovERP(51,idxStartMov:ixdEndMov)),squeeze(positiveMovCI(51,idxStartMov:ixdEndMov,:)),timeMov(idxStartMov:ixdEndMov),cmapERP(10,:),14);
hold on
[~,~] = plotCI(squeeze(negativeMovERP(51,idxStartMov:ixdEndMov)),squeeze(negativeMovCI(51,idxStartMov:ixdEndMov,:)),timeMov(idxStartMov:ixdEndMov),cmapERP(1,:),14);
xlim([-500 400])
ylim([-11 11])
xlabel('Time (ms)')
ylabel('Amplitude (mV)')
legend('Positive','','Negative','','','Location','northwest','FontSize',14)
vline(0,'k')
hline(0,'k')
text(x_posMov, y_pos, sprintf(chanLocs(51).labels), 'HorizontalAlignment', 'left', 'VerticalAlignment', 'bottom', 'FontSize', 14);
c = xregion(-30,10);
c.FaceColor = [0.5 0.5 0.5 0.5];
c.FaceAlpha = 0.2;
c.HandleVisibility = 'off';
ylimits = ylim; 
text(-530, ylimits(2), 'C', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', ...
    'FontSize', 14, 'FontWeight', 'bold', 'Rotation', 0); 
nexttile([1,4])
[~,~] = plotCI(squeeze(positiveMovERP(25,idxStartMov:ixdEndMov)),squeeze(positiveMovCI(25,idxStartMov:ixdEndMov,:)),timeMov(idxStartMov:ixdEndMov),cmapERP(10,:),14);
hold on
[~,~] = plotCI(squeeze(negativeMovERP(25,idxStartMov:ixdEndMov)),squeeze(negativeMovCI(25,idxStartMov:ixdEndMov,:)),timeMov(idxStartMov:ixdEndMov),cmapERP(1,:),14);
xlim([-500 400])
ylim([-11 11])
xlabel('Time (ms)')
ylabel('Amplitude (mV)')
legend('Positive','','Negative','','','Location','northwest','FontSize',14)
vline(0,'k')
hline(0,'k')
text(x_posMov, y_pos, sprintf(chanLocs(25).labels), 'HorizontalAlignment', 'left', 'VerticalAlignment', 'bottom', 'FontSize', 14);
c = xregion(-30,10);
c.FaceColor = [0.5 0.5 0.5 0.5];
c.FaceAlpha = 0.2;
c.HandleVisibility = 'off';
ylimits = ylim; 
text(-530, ylimits(2), 'D', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', ...
    'FontSize', 14, 'FontWeight', 'bold', 'Rotation', 0); 
nexttile(17)
topoplot(difValMov(:,unique_S(5))', chanLocs, ...
    'electrodes',           'on',           ...         
    'whitebk',              'on',           ...
    'colormap',             cmaptopo,       ...
    'shading',              'interp',       ...         
    'style',                'map',          ...
    'numcontour',           6,              ...         
    'plotrad',              max(abs(cell2mat({chanLocs.radius}))), ...
    'maplimits',            [-2 2], ...
    'emarker2', {56,'o','k',5,1}); 
text(0, -0.8, sprintf('%d ms', timeMov(unique_S(5))), ...
    'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'center', 'FontSize', 14);
text(-1.34, 0.8, 'E', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', ...
    'FontSize', 14, 'FontWeight', 'bold', 'Rotation', 0); 
nexttile(18)
topoplot(difValMov(:,unique_S(13))', chanLocs,...
    'electrodes',           'on',           ...        
    'whitebk',              'on',           ...
    'colormap',             cmaptopo,            ...
    'shading',              'interp',       ...         
    'style',                'map',         ...
    'numcontour',           6,             ...         
    'plotrad',              max(abs(cell2mat({chanLocs.radius}))), ...
    'maplimits',[-2 2],...
    'emarker2', {30,'o','k',5,1}); 
text(0,-0.8,sprintf('%d ms',timeMov(unique_S(13))),'VerticalAlignment','bottom','HorizontalAlignment','center', 'FontSize', 14)
nexttile(19)
topoplot(difValMov(:,unique_S(21))', chanLocs,...
    'electrodes',           'on',           ...         
    'whitebk',              'on',           ...
    'colormap',             cmaptopo,            ...
    'shading',              'interp',       ...         
    'style',                'map',         ...
    'numcontour',           6,             ...         
    'plotrad',              max(abs(cell2mat({chanLocs.radius}))), ...
    'maplimits',[-2 2],...
    'emarker2', {51,'o','k',5,1});
text(0,-0.8,sprintf('%d ms',timeMov(unique_S(21))),'VerticalAlignment','bottom','HorizontalAlignment','center', 'FontSize', 14)
nexttile(20)
topoplot(difValMov(:,unique_S(25))', chanLocs,...
    'electrodes',           'on',           ...         
    'whitebk',              'on',           ...
    'colormap',             cmaptopo,            ...
    'shading',              'interp',       ...         
    'style',                'map',         ...
    'numcontour',           6,             ...        
    'plotrad',              max(abs(cell2mat({chanLocs.radius}))), ...
    'maplimits',[-2 2], ...
    'emarker2', {25,'o','k',5,1});
c = colorbar;
c.Limits = [-2 2];
c.FontSize = 14; 
c.Ticks = [-2 0 2]; 
c.Label.String = '\muV';
c.Label.Rotation = 90+90+90+90;
text(0,-0.8,sprintf('%d ms',timeMov(unique_S(25))),'VerticalAlignment','bottom','HorizontalAlignment','center','FontSize', 14)

fig = gcf;
exportgraphics(fig,'ResultsEEG1.MovementOnsetValence.png','Resolution',600)
clear f fig
%% Figure 8
fValues =  resultsMov.Obs.AB;
% Define parameters
x_posMov = (-500 + 30);
y_pos = -8;
% Define what to plot
[unique_S, ~, idx] = unique(sMov.AB);
Ch_by_time = cell(length(unique_S), 1);

% Loop through each unique time point and gather corresponding Ch values
for i = 1:length(unique_S)
    % Find indices in S that match the current unique time
    corresponding_indices = (sMov.AB == unique_S(i));
    % Get corresponding Ch values for the current time point
    Ch_by_time{i} = chPic.AB(corresponding_indices);
end

figure('Renderer', 'painters', 'Position', [10 10 800 850])
t = tiledlayout(1,6,'TileSpacing', 'none', 'Padding', 'none');
% Time 1
nexttile(1)
topoplot(fValues(:,unique_S(21))', chanLocs,...
    'electrodes',           'on',           ...         
    'whitebk',              'on',           ...
    'colormap',             cmaptopo,            ...
    'shading',              'interp',       ...         
    'style',                'map',         ...
    'numcontour',           6,             ...         
    'plotrad',              max(abs(cell2mat({chanLocs.radius}))), ...
    'maplimits',[-10 30], ...
    'emarker2', {[cell2mat(Ch_by_time(21))],'o','k',5,1}); 
text(0,-0.8,sprintf('%d ms',timeMov(unique_S(21))),'VerticalAlignment','bottom','HorizontalAlignment','center','FontSize', 14)
nexttile(2)
topoplot(fValues(:,unique_S(35))', chanLocs,...
    'electrodes',           'on',           ...        
    'whitebk',              'on',           ...
    'colormap',             cmaptopo,            ...
    'shading',              'interp',       ...         
    'style',                'map',         ...
    'numcontour',           6,             ...         
    'plotrad',              max(abs(cell2mat({chanLocs.radius}))), ...
    'maplimits',[-10 30], ...
    'emarker2', {[cell2mat(Ch_by_time(35))],'o','k',5,1}); 
text(0,-0.8,sprintf('%d ms',timeMov(unique_S(35))),'VerticalAlignment','bottom','HorizontalAlignment','center','FontSize', 14)
nexttile(3)
topoplot(fValues(:,unique_S(41))', chanLocs,...
    'electrodes',           'on',           ...         
    'whitebk',              'on',           ...
    'colormap',             cmaptopo,            ...
    'shading',              'interp',       ...         
    'style',                'map',         ...
    'numcontour',           6,             ...         
    'plotrad',              max(abs(cell2mat({chanLocs.radius}))), ...
    'maplimits',[-10 30], ...
    'emarker2', {[cell2mat(Ch_by_time(41))],'o','k',5,1}); 
text(0,-0.8,sprintf('%d ms',timeMov(unique_S(41))),'VerticalAlignment','bottom','HorizontalAlignment','center','FontSize', 14)
nexttile(4)
topoplot(fValues(:,unique_S(55))', chanLocs,...
    'electrodes',           'on',           ...         
    'whitebk',              'on',           ...
    'colormap',             cmaptopo,            ...
    'shading',              'interp',       ...         
    'style',                'map',         ...
    'numcontour',           6,             ...         
    'plotrad',              max(abs(cell2mat({chanLocs.radius}))), ...
    'maplimits',[-10 30], ...
    'emarker2', {[cell2mat(Ch_by_time(55))],'o','k',5,1}); 
text(0,-0.8,sprintf('%d ms',timeMov(unique_S(55))),'VerticalAlignment','bottom','HorizontalAlignment','center','FontSize', 14)
nexttile(5)
topoplot(fValues(:,unique_S(61))', chanLocs,...
    'electrodes',           'on',           ...         
    'whitebk',              'on',           ...
    'colormap',             cmaptopo,            ...
    'shading',              'interp',       ...         
    'style',                'map',         ...
    'numcontour',           6,             ...         
    'plotrad',              max(abs(cell2mat({chanLocs.radius}))), ...
    'maplimits',[-10 30], ...
    'emarker2', {[cell2mat(Ch_by_time(61))],'o','k',5,1}); 
c = colorbar;
c.Limits = [-10 30];
c.FontSize = 14; 
c.Ticks = [-10 10 30]; 
c.Label.String = 'F Value';
c.Label.Rotation = 90;
text(0,-0.8,sprintf('%d ms',timeMov(unique_S(61))),'VerticalAlignment','bottom','HorizontalAlignment','center','FontSize', 14)

fig = gcf;
exportgraphics(fig,'ResultsEEG1.MovementOnsetInteraction.png','Resolution',600)
