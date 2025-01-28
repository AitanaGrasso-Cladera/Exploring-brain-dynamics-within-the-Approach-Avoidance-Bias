%% Paths
% root = [];
% dataPath = [];
% functionPath = [];

addpath(dataPath)
addpath(functionPath)
%% Load the data
load('JANUARY_TFCE_PicOnset_Unfold.mat','Data'); dataPic = Data;
load('JANUARY_TFCE_PicOnset_Unfold.mat','Info'); infoPic = Info;
load('JANUARY_TFCE_PicOnset_Unfold.mat','Results'); resultsPic = Results;
load('JANUARY_TFCE_PicOnset_Unfold.mat','S'); sPic = S;
load('JANUARY_TFCE_PicOnset_Unfold.mat','idxSC'); idxSCPic = idxSC;
load('JANUARY_TFCE_PicOnset_Unfold.mat','pValuesBelowThreshold'); pValuesPic = pValuesBelowThreshold;
load('JANUARY_TFCE_PicOnset_Unfold.mat','Ch'); chPic = Ch;

% Load time vector
load('unfoldResults_December_PicOnset.mat','time'); timePic = time;

% Load channel locations
load([dataPath,filesep,'chanLocs'])

clear Data Info Results S idxSC pValuesBelowThreshold time Ch
%% Figure 5: 
% Compute ERP difference for valence (Picture onset)
posPic = squeeze(mean(dataPic{1,1},1)) + squeeze(mean(dataPic{2,1},1));
negPic = squeeze(mean(dataPic{1,2},1)) + squeeze(mean(dataPic{2,2},1));
difValPic = posPic-negPic;
% Color map for topoplots
numColors = 20; 
blue = [0.2567,0.4185,0.9962]; 
white = [1, 1, 1];
red = [0.2291,0.7880,0.5757];
cmaptopo = interp1([0, 0.5, 1], [blue; white; red], linspace(0, 1, numColors));
% Color map for ERPs
cmapERP = parula(20);

% Change the units of the time vector
timePic = timePic*1000;

% Define a smalled temporal window for plotting
idxStartPic = find(timePic == -400);
ixdEndPic = find(timePic == 600);

% Define parameters
x_posPic = (-400 + 30);
x_posMov = (-400 + 30);
y_pos = -7;

% Compute Confidence Interval
alpha = 0.05;
[positivePicCI,positivePicERP] = compute_CI(dataPic{1,1}+dataPic{2,1},alpha);
[negativePicCI,negativePicERP] = compute_CI(dataPic{1,2}+dataPic{2,2},alpha);

% Define what to plot
[unique_S, ~, idx] = unique(sPic.B);
Ch_by_time = cell(length(unique_S), 1);

% Loop through each unique time point and gather corresponding Ch values
for i = 1:length(unique_S)
    % Find indices in S that match the current unique time
    corresponding_indices = (sPic.B == unique_S(i));
    % Get corresponding Ch values for the current time point
    Ch_by_time{i} = chPic.B(corresponding_indices);
end

figure('Renderer', 'painters', 'Position', [10 10 1000 650])
t = tiledlayout(5,4,'TileSpacing', 'compact', 'Padding', 'compact');
nexttile([1,4])
[~,~] = plotCI(squeeze(positivePicERP(15,idxStartPic:ixdEndPic)),squeeze(positivePicCI(15,idxStartPic:ixdEndPic,:)),timePic(idxStartPic:ixdEndPic),cmapERP(10,:),14);
hold on
[~,~] = plotCI(squeeze(negativePicERP(15,idxStartPic:ixdEndPic)),squeeze(negativePicCI(15,idxStartPic:ixdEndPic,:)),timePic(idxStartPic:ixdEndPic),cmapERP(1,:),14);
xlim([-400 600])
ylim([-11 11])
xlabel('Time (ms)')
ylabel('Amplitude (mV)')
legend('Positive','','Negative','','','Location','northwest','FontSize',14)
vline(0,'k')
hline(0,'k')
text(x_posPic, y_pos, sprintf(chanLocs(15).labels), 'HorizontalAlignment', 'left', 'VerticalAlignment', 'bottom', 'FontSize', 14);
c = xregion(30,126);
c.FaceColor = [0.5 0.5 0.5 0.5];
c.FaceAlpha = 0.2;
c.HandleVisibility = 'off';
ylimits = ylim; 
text(-435, ylimits(2), 'A', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', ...
    'FontSize', 14, 'FontWeight', 'bold', 'Rotation', 0); 
nexttile([1,4])
[~,~] = plotCI(squeeze(positivePicERP(19,idxStartPic:ixdEndPic)),squeeze(positivePicCI(19,idxStartPic:ixdEndPic,:)),timePic(idxStartPic:ixdEndPic),cmapERP(10,:),14);
hold on
[~,~] = plotCI(squeeze(negativePicERP(19,idxStartPic:ixdEndPic)),squeeze(negativePicCI(19,idxStartPic:ixdEndPic,:)),timePic(idxStartPic:ixdEndPic),cmapERP(1,:),14);
xlim([-400 600])
ylim([-11 11])
xlabel('Time (ms)')
ylabel('Amplitude (mV)')
legend('Positive','','Negative','','','Location','northwest','FontSize',14)
vline(0,'k')
hline(0,'k')
text(x_posPic, y_pos, sprintf(chanLocs(19).labels), 'HorizontalAlignment', 'left', 'VerticalAlignment', 'bottom', 'FontSize', 14);
c = xregion(30,126);
c.FaceColor = [0.5 0.5 0.5 0.5];
c.FaceAlpha = 0.2;
c.HandleVisibility = 'off';
ylimits = ylim; 
text(-435, ylimits(2), 'B', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', ...
    'FontSize', 14, 'FontWeight', 'bold', 'Rotation', 0); 
nexttile([1,4])
[~,~] = plotCI(squeeze(positivePicERP(41,idxStartPic:ixdEndPic)),squeeze(positivePicCI(41,idxStartPic:ixdEndPic,:)),timePic(idxStartPic:ixdEndPic),cmapERP(10,:),14);
hold on
[~,~] = plotCI(squeeze(negativePicERP(41,idxStartPic:ixdEndPic)),squeeze(negativePicCI(41,idxStartPic:ixdEndPic,:)),timePic(idxStartPic:ixdEndPic),cmapERP(1,:),14);
xlim([-400 600])
ylim([-11 11])
xlabel('Time (ms)')
ylabel('Amplitude (mV)')
legend('Positive','','Negative','','','Location','northwest','FontSize',14)
vline(0,'k')
hline(0,'k')
text(x_posPic, y_pos, sprintf(chanLocs(41).labels), 'HorizontalAlignment', 'left', 'VerticalAlignment', 'bottom', 'FontSize', 14);
c = xregion(30,126);
c.FaceColor = [0.5 0.5 0.5 0.5];
c.FaceAlpha = 0.2;
c.HandleVisibility = 'off';
ylimits = ylim; 
text(-435, ylimits(2), 'C', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', ...
    'FontSize', 14, 'FontWeight', 'bold', 'Rotation', 0); 
nexttile([1,4])
[~,~] = plotCI(squeeze(positivePicERP(2,idxStartPic:ixdEndPic)),squeeze(positivePicCI(2,idxStartPic:ixdEndPic,:)),timePic(idxStartPic:ixdEndPic),cmapERP(10,:),14);
hold on
[~,~] = plotCI(squeeze(negativePicERP(2,idxStartPic:ixdEndPic)),squeeze(negativePicCI(2,idxStartPic:ixdEndPic,:)),timePic(idxStartPic:ixdEndPic),cmapERP(1,:),14);
xlim([-400 600])
ylim([-11 11])
xlabel('Time (ms)')
ylabel('Amplitude (mV)')
legend('Positive','','Negative','','','Location','northwest','FontSize',14)
vline(0,'k')
hline(0,'k')
text(x_posPic, y_pos, sprintf(chanLocs(24).labels), 'HorizontalAlignment', 'left', 'VerticalAlignment', 'bottom', 'FontSize', 14);
c = xregion(30,126);
c.FaceColor = [0.5 0.5 0.5 0.5];
c.FaceAlpha = 0.2;
c.HandleVisibility = 'off';
ylimits = ylim;
text(-435, ylimits(2), 'D', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', ...
    'FontSize', 14, 'FontWeight', 'bold', 'Rotation', 0);
nexttile(17)
topoplot(difValPic(:,unique_S(20))', chanLocs, ...
    'electrodes',           'on',           ...         
    'whitebk',              'on',           ...
    'colormap',             cmaptopo,       ...
    'shading',              'interp',       ...        
    'style',                'map',          ...
    'numcontour',           6,              ...        
    'plotrad',              max(abs(cell2mat({chanLocs.radius}))), ...
    'maplimits',            [-2 2], ...
    'emarker2', {15,'o','k',5,1});
text(0, -0.8, sprintf('%d ms', timePic(unique_S(20))), ...
    'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'center', 'FontSize', 14);
text(-1.34, 0.8, 'E', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', ...
    'FontSize', 14, 'FontWeight', 'bold', 'Rotation', 0); 
nexttile(18)
topoplot(difValPic(:,unique_S(29))', chanLocs,...
    'electrodes',           'on',           ...         
    'whitebk',              'on',           ...
    'colormap',             cmaptopo,            ...
    'shading',              'interp',       ...         
    'style',                'map',         ...
    'numcontour',           6,             ...         
    'plotrad',              max(abs(cell2mat({chanLocs.radius}))), ...
    'maplimits',[-2 2], ...
    'emarker2', {19,'o','k',5,1}); 
text(0,-0.8,sprintf('%d ms',timePic(unique_S(29))),'VerticalAlignment','bottom','HorizontalAlignment','center', 'FontSize', 14)
nexttile(19)
topoplot(difValPic(:,unique_S(40))', chanLocs,...
    'electrodes',           'on',           ...         
    'whitebk',              'on',           ...
    'colormap',             cmaptopo,            ...
    'shading',              'interp',       ...         
    'style',                'map',         ...
    'numcontour',           6,             ...         
    'plotrad',              max(abs(cell2mat({chanLocs.radius}))), ...
    'maplimits',[-2 2], ...
    'emarker2', {41,'o','k',5,1});
text(0,-0.8,sprintf('%d ms',timePic(unique_S(40))),'VerticalAlignment','bottom','HorizontalAlignment','center', 'FontSize', 14)
nexttile(20)
topoplot(difValPic(:,unique_S(49))', chanLocs,...
    'electrodes',           'on',           ...         
    'whitebk',              'on',           ...
    'colormap',             cmaptopo,            ...
    'shading',              'interp',       ...         
    'style',                'map',         ...
    'numcontour',           6,             ...        
    'plotrad',              max(abs(cell2mat({chanLocs.radius}))), ...
    'maplimits',[-2 2], ...
    'emarker2', {2,'o','k',5,1}); 
c = colorbar;
c.Limits = [-2 2];
c.FontSize = 14; 
c.Ticks = [-2 0 2];
c.Label.String = '\muV';
c.Label.Rotation = 90+90+90+90;
text(0,-0.8,sprintf('%d ms',timePic(unique_S(49))),'VerticalAlignment','bottom','HorizontalAlignment','center','FontSize', 14)

fig = gcf;
exportgraphics(fig,'ResultsEEG1.PictureOnsetValence.png','Resolution',600)
clear f fig
%% Figure 6
fValues =  resultsPic.Obs.AB;
% Define parameters
x_posMov = (-500 + 30);
y_pos = -8;

% Define what to plot
[unique_S, ~, idx] = unique(sPic.AB);
Ch_by_time = cell(length(unique_S), 1);

% Loop through each unique time point and gather corresponding Ch values
for i = 1:length(unique_S)
    % Find indices in S that match the current unique time
    corresponding_indices = (sPic.AB == unique_S(i));
    % Get corresponding Ch values for the current time point
    Ch_by_time{i} = chPic.AB(corresponding_indices);
end

figure('Renderer', 'painters', 'Position', [10 10 800 850])
t = tiledlayout(1,6,'TileSpacing', 'none', 'Padding', 'none');
nexttile(1)
topoplot(fValues(:,unique_S(25))', chanLocs,...
    'electrodes',           'on',           ...         
    'whitebk',              'on',           ...
    'colormap',             cmaptopo,            ...
    'shading',              'interp',       ...         
    'style',                'map',         ...
    'numcontour',           6,             ...         
    'plotrad',              max(abs(cell2mat({chanLocs.radius}))), ...
    'maplimits',[-10 20], ...
    'emarker2', {[cell2mat(Ch_by_time(25))],'o','k',5,1}); 
text(0,-0.8,sprintf('%d ms',timePic(unique_S(25))),'VerticalAlignment','bottom','HorizontalAlignment','center','FontSize', 14)
nexttile(2)
topoplot(fValues(:,unique_S(35))', chanLocs,...
    'electrodes',           'on',           ...         
    'whitebk',              'on',           ...
    'colormap',             cmaptopo,            ...
    'shading',              'interp',       ...         
    'style',                'map',         ...
    'numcontour',           6,             ...         
    'plotrad',              max(abs(cell2mat({chanLocs.radius}))), ...
    'maplimits',[-10 20], ...
    'emarker2', {[cell2mat(Ch_by_time(35))],'o','k',5,1}); 
text(0,-0.8,sprintf('%d ms',timePic(unique_S(35))),'VerticalAlignment','bottom','HorizontalAlignment','center','FontSize', 14)
nexttile(3)
topoplot(fValues(:,unique_S(45))', chanLocs,...
    'electrodes',           'on',           ...         
    'whitebk',              'on',           ...
    'colormap',             cmaptopo,            ...
    'shading',              'interp',       ...        
    'style',                'map',         ...
    'numcontour',           6,             ...         
    'plotrad',              max(abs(cell2mat({chanLocs.radius}))), ...
    'maplimits',[-10 20], ...
    'emarker2', {[cell2mat(Ch_by_time(45))],'o','k',5,1}); 
text(0,-0.8,sprintf('%d ms',timePic(unique_S(45))),'VerticalAlignment','bottom','HorizontalAlignment','center','FontSize', 14)
nexttile(4)
topoplot(fValues(:,unique_S(55))', chanLocs,...
    'electrodes',           'on',           ...         
    'whitebk',              'on',           ...
    'colormap',             cmaptopo,            ...
    'shading',              'interp',       ...         
    'style',                'map',         ...
    'numcontour',           6,             ...         
    'plotrad',              max(abs(cell2mat({chanLocs.radius}))), ...
    'maplimits',[-10 20], ...
    'emarker2', {[cell2mat(Ch_by_time(55))],'o','k',5,1}); 
text(0,-0.8,sprintf('%d ms',timePic(unique_S(55))),'VerticalAlignment','bottom','HorizontalAlignment','center','FontSize', 14)
nexttile(5)
topoplot(fValues(:,unique_S(65))', chanLocs,...
    'electrodes',           'on',           ...         
    'whitebk',              'on',           ...
    'colormap',             cmaptopo,            ...
    'shading',              'interp',       ...         
    'style',                'map',         ...
    'numcontour',           6,             ...         
    'plotrad',              max(abs(cell2mat({chanLocs.radius}))), ...
    'maplimits',[-10 20], ...
    'emarker2', {[cell2mat(Ch_by_time(65))],'o','k',5,1}); 
c = colorbar;
c.Limits = [-10 20];
c.FontSize = 14; 
c.Ticks = [-10 5 20];
c.Label.String = 'F Value';
c.Label.Rotation = 90;
text(0,-0.8,sprintf('%d ms',timePic(unique_S(65))),'VerticalAlignment','bottom','HorizontalAlignment','center','FontSize', 14)

fig = gcf;
exportgraphics(fig,'ResultsEEG1.PictureOnsetInteraction.png','Resolution',600)
clear fig 