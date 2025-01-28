%% Paths
% root = [];
% dataPath = [];
% functionPath = [];
% EEGLABfolder = [];
addpath(dataPath)
addpath(functionPath)
addpath(EEGLABfolder)
%% Load the data
load('DEC_TFCE_MovOnset_Unfold.mat','Data'); dataMov = Data;
load('DEC_TFCE_MovOnset_Unfold.mat','Info'); infoMov = Info;
load('DEC_TFCE_MovOnset_Unfold.mat','Results'); resultsMov = Results;
load('DEC_TFCE_MovOnset_Unfold.mat','S'); sMov = S;
load('DEC_TFCE_MovOnset_Unfold.mat','idxSC'); idxSCMov = idxSC;
load('DEC_TFCE_MovOnset_Unfold.mat','pValuesBelowThreshold'); pValuesMov = pValuesBelowThreshold;
load('DEC_TFCE_MovOnset_Unfold.mat','Ch'); chMov = Ch;
load('DEC_TFCE_MovOnset_Unfold.mat','chanLocs');
load('JANUARY_TFCE_PicOnset_Unfold.mat','Data'); dataPic = Data;
load('JANUARY_TFCE_PicOnset_Unfold.mat','Info'); infoPic = Info;
load('JANUARY_TFCE_PicOnset_Unfold.mat','Results'); resultsPic = Results;
load('JANUARY_TFCE_PicOnset_Unfold.mat','S'); sPic = S;
load('JANUARY_TFCE_PicOnset_Unfold.mat','idxSC'); idxSCPic = idxSC;
load('JANUARY_TFCE_PicOnset_Unfold.mat','pValuesBelowThreshold'); pValuesPic = pValuesBelowThreshold;
load('JANUARY_TFCE_PicOnset_Unfold.mat','Ch'); chPic = Ch;
% Load time vector
load('unfoldResults_December_MovOnset.mat','time'); timeMov = time;
load('unfoldResults_December_PicOnset.mat','time'); timePic = time;

clear Data Info Results S idxSC pValuesBelowThreshold time Ch
%% Figure 3
cmap = parula(20);
% Compute Confidence Interval
alpha = 0.05;
% For movement onset
[CPmovCI,CPmovERP] = compute_CI(dataMov{1,1},alpha);
[CNmovCI,CNmovERP] = compute_CI(dataMov{1,2},alpha);
[IPmovCI,IPmovERP] = compute_CI(dataMov{2,1},alpha);
[INmovCI,INmovERP] = compute_CI(dataMov{2,2},alpha);
% For picture onset
[CPpicCI,CPpicERP] = compute_CI(dataPic{1,1},alpha);
[CNpicCI,CNpicERP] = compute_CI(dataPic{1,2},alpha);
[IPpicCI,IPpicERP] = compute_CI(dataPic{2,1},alpha);
[INpicCI,INpicERP] = compute_CI(dataPic{2,2},alpha);

% Target channels:
% Picture onset: Valence = 19; Interaction = 54
% Movement onset = Valence = 51; Interaction = 29
% Change the units of the time vector
timeMov = timeMov*1000;
timePic = timePic*1000;
% Define a smalled temporal window for plotting
idxStartPic = find(timePic == -400);
ixdEndPic = find(timePic == 600);
idxStartMov = find(timeMov == -500);
idxEndMov = find(timeMov ==  400);
% Define parameters
x_posPic = (-400 + 30);
x_posMov = (-500 + 30);
y_pos = -6;

figure(figure('Renderer', 'painters', 'Position', [10 10 1000 800]))
t = tiledlayout(4,1,'TileSpacing', 'Compact', 'Padding', 'Compact');
nexttile(1)
[~,~] = plotCI(squeeze(CPpicERP(19,idxStartPic:ixdEndPic)),...
    squeeze(CPpicCI(19,idxStartPic:ixdEndPic,:)),timePic(idxStartPic:ixdEndPic),cmap(1,:),13);
hold on
[~,~] = plotCI(squeeze(CNpicERP(19,idxStartPic:ixdEndPic)),...
    squeeze(CNpicCI(19,idxStartPic:ixdEndPic,:)),timePic(idxStartPic:ixdEndPic),cmap(5,:),13);
[~,~] = plotCI(squeeze(IPpicERP(19,idxStartPic:ixdEndPic)),...
    squeeze(IPpicCI(19,idxStartPic:ixdEndPic,:)),timePic(idxStartPic:ixdEndPic),cmap(10,:),13);
[~,~] = plotCI(squeeze(INpicERP(19,idxStartPic:ixdEndPic)),...
    squeeze(INpicCI(19,idxStartPic:ixdEndPic,:)),timePic(idxStartPic:ixdEndPic),cmap(15,:),13);
xlim([-400 600])
ylim([-11 11])
xlabel('Time (ms)')
ylabel('Amplitude (mV)')
legend('CP','','CN','','IP','','IN','','location','northwest','FontSize',13)
xline = 86; % x-coordinate of the vertical line
h = line([xline xline], ylim, 'Color', [0.5 0.5 0.5 0.5], 'LineWidth', 2,'HandleVisibility', 'off'); % Gray with transparency
vline(0,'k');
hline(0,'k')
ax = gca; % Get current axes
ax.FontSize = 13; % Set font size for x and y ticks
text(x_posPic, y_pos, sprintf(chanLocs(19).labels), 'HorizontalAlignment', 'left', 'VerticalAlignment', 'bottom', 'FontSize', 13);
ylimits = ylim; % Get current y-axis limits
text(-435, ylimits(2), 'A', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', ...
    'FontSize', 14, 'FontWeight', 'bold', 'Rotation', 0); % Adjust position as needed

nexttile(2)
[~,~] = plotCI(squeeze(CPpicERP(54,idxStartPic:ixdEndPic)),...
    squeeze(CPpicCI(54,idxStartPic:ixdEndPic,:)),timePic(idxStartPic:ixdEndPic),cmap(1,:),13);
hold on
[~,~] = plotCI(squeeze(CNpicERP(54,idxStartPic:ixdEndPic)),...
    squeeze(CNpicCI(54,idxStartPic:ixdEndPic,:)),timePic(idxStartPic:ixdEndPic),cmap(5,:),13);
[~,~] = plotCI(squeeze(IPpicERP(54,idxStartPic:ixdEndPic)),...
    squeeze(IPpicCI(54,idxStartPic:ixdEndPic,:)),timePic(idxStartPic:ixdEndPic),cmap(10,:),13);
[~,~] = plotCI(squeeze(INpicERP(54,idxStartPic:ixdEndPic)),...
    squeeze(INpicCI(54,idxStartPic:ixdEndPic,:)),timePic(idxStartPic:ixdEndPic),cmap(15,:),13);
xlim([-400 600])
ylim([-11 11])
xlabel('Time (ms)')
ylabel('Amplitude (mV)')
legend('CP','','CN','','IP','','IN','location','northwest','FontSize',13)
vline(0,'k')
hline(0,'k')
xline = 582; % x-coordinate of the vertical line
h = line([xline xline], ylim, 'Color', [0.5 0.5 0.5 0.5], 'LineWidth', 2,'HandleVisibility', 'off'); % Gray with transparency
ax = gca; % Get current axes
ax.FontSize = 13; % Set font size for x and y ticks
text(x_posPic, y_pos, sprintf(chanLocs(54).labels), 'HorizontalAlignment', 'left', 'VerticalAlignment', 'bottom', 'FontSize', 13);
ylimits = ylim; % Get current y-axis limits
text(-435, ylimits(2), 'B', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', ...
    'FontSize', 14, 'FontWeight', 'bold', 'Rotation', 0); % Adjust position as needed

nexttile(3)
[~,~] = plotCI(squeeze(CPmovERP(51,idxStartMov:idxEndMov)),...
    squeeze(CPmovCI(51,idxStartMov:idxEndMov,:)),timeMov(idxStartMov:idxEndMov),cmap(1,:),13);
hold on
[~,~] = plotCI(squeeze(CNmovERP(51,idxStartMov:idxEndMov)),...
    squeeze(CNmovCI(51,idxStartMov:idxEndMov,:)),timeMov(idxStartMov:idxEndMov),cmap(5,:),13);
[~,~] = plotCI(squeeze(IPmovERP(51,idxStartMov:idxEndMov)),...
    squeeze(IPmovCI(51,idxStartMov:idxEndMov,:)),timeMov(idxStartMov:idxEndMov),cmap(10,:),13);
[~,~] = plotCI(squeeze(INmovERP(51,idxStartMov:idxEndMov)),...
    squeeze(INmovCI(51,idxStartMov:idxEndMov,:)),timeMov(idxStartMov:idxEndMov),cmap(15,:),13);
xlim([-500 400])
ylim([-11 11])
xlabel('Time (ms)')
ylabel('Amplitude (mV)')
legend('CP','','CN','','IP','','IN','location','northwest','FontSize',13)
vline(0,'k')
hline(0,'k')
xline = 2; % x-coordinate of the vertical line
h = line([xline xline], ylim, 'Color', [0.5 0.5 0.5 0.5], 'LineWidth', 2,'HandleVisibility', 'off'); % Gray with transparency
ax = gca; % Get current axes
ax.FontSize = 13; % Set font size for x and y ticks
text(x_posMov, y_pos, sprintf(chanLocs(51).labels), 'HorizontalAlignment', 'left', 'VerticalAlignment', 'bottom', 'FontSize', 13);
ylimits = ylim; % Get current y-axis limits
text(-530, ylimits(2), 'C', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', ...
    'FontSize', 14, 'FontWeight', 'bold', 'Rotation', 0); % Adjust position as needed

nexttile(4)
[~,~] = plotCI(squeeze(CPmovERP(29,idxStartMov:idxEndMov)),...
    squeeze(CPmovCI(29,idxStartMov:idxEndMov,:)),timeMov(idxStartMov:idxEndMov),cmap(1,:),13);
hold on
[~,~] = plotCI(squeeze(CNmovERP(29,idxStartMov:idxEndMov)),...
    squeeze(CNmovCI(29,idxStartMov:idxEndMov,:)),timeMov(idxStartMov:idxEndMov),cmap(5,:),13);
[~,~] = plotCI(squeeze(IPmovERP(29,idxStartMov:idxEndMov)),...
    squeeze(IPmovCI(29,idxStartMov:idxEndMov,:)),timeMov(idxStartMov:idxEndMov),cmap(10,:),13);
[~,~] = plotCI(squeeze(INmovERP(29,idxStartMov:idxEndMov)),...
    squeeze(INmovCI(29,idxStartMov:idxEndMov,:)),timeMov(idxStartMov:idxEndMov),cmap(15,:),13);
xlim([-500 400])
ylim([-11 11])
xlabel('Time (ms)')
ylabel('Amplitude (mV)')
legend('CP','','CN','','IP','','IN','location','northwest','FontSize',13)
vline(0,'k')
hline(0,'k')
xline = 108; % x-coordinate of the vertical line
h = line([xline xline], ylim, 'Color', [0.5 0.5 0.5 0.5], 'LineWidth', 2,'HandleVisibility', 'off'); % Gray with transparency
ax = gca; % Get current axes
ax.FontSize = 13; % Set font size for x and y ticks
text(x_posMov, y_pos, sprintf(chanLocs(29).labels), 'HorizontalAlignment', 'left', 'VerticalAlignment', 'bottom', 'FontSize', 13);
ylimits = ylim; % Get current y-axis limits
text(-530, ylimits(2), 'D', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', ...
    'FontSize', 14, 'FontWeight', 'bold', 'Rotation', 0); % Adjust position as needed


fig = gcf;
exportgraphics(fig,'ResultsEEG1.ERPs_allPeaks.png','Resolution',600)
clear t
%% Figure 4:
posPic = squeeze(mean(dataPic{1,1},1)) + squeeze(mean(dataPic{2,1},1));
negPic = squeeze(mean(dataPic{1,2},1)) + squeeze(mean(dataPic{2,2},1));
difValPic = posPic-negPic;
numColors = 20; % Total number of colors in the colormap
blue = [0.2567,0.4185,0.9962];   % RGB for blue
white = [1, 1, 1];  % RGB for white
red = [0.2291,0.7880,0.5757];    % RGB for red
% Interpolate the colors with equal distribution
cmaptopo = interp1([0, 0.5, 1], [blue; white; red], linspace(0, 1, numColors));

[min_P, ID] = min(resultsPic.P_Values.B(:));
[ChanMax, SMAx]      = ind2sub(size(resultsPic.P_Values.B),ID);
[unique_S, ~, idx] = unique(sPic.B);
Ch_by_time = cell(length(unique_S), 1);

% Loop through each unique time point and gather corresponding Ch values
for i = 1:length(unique_S)
    % Find indices in S that match the current unique time
    corresponding_indices = (sPic.B == unique_S(i));
    % Get corresponding Ch values for the current time point
    Ch_by_time{i} = chPic.B(corresponding_indices);
end
chXtime = find(unique_S == 444);

figure('Renderer', 'painters', 'Position', [10 10 1000 650])
t = tiledlayout(2,7,'TileSpacing', 'none', 'Padding', 'compact');
nexttile
current_channels = Ch_by_time{chXtime};
labels = arrayfun(@(x) chanLocs(x).labels, current_channels, 'UniformOutput', false);
topoplot(difValPic(:,SMAx)', chanLocs,...
    'electrodes',           'on',           ...         % display markers ("labels" shows electrode names
    'whitebk',              'on',           ...
    'colormap',             cmaptopo,            ...
    'shading',              'interp',       ...         % (flat or interp) useless with style is "fill"
    'style',                'map',         ...
    'numcontour',           6,             ...         % Increase for more contour details
    'plotrad',              max(abs(cell2mat({chanLocs.radius}))),...
    'maplimits',[-1 1]); % 'map' 'contour' 'both' 'fill' 'blank'
% Adjust the colorbar position
%cbPos = c.Position; % Get the current position of the colorbar
%cbPos(1) = cbPos(1) - 0.05; % Move it closer to the plot (decrease horizontal spacing)
%c.Position = cbPos; % Apply the new position
text(0, -0.8, sprintf('%d ms', timePic(unique_S(chXtime))), ...
    'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'center','FontSize',14);
title('Positive - Negative','FontSize',14)
set(get(gca,'title'),'Position',[0 0.9 1.00011])
ylimits = ylim; % Get current y-axis limits
text(-0.75, ylimits(2)+.5, 'A', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', ...
    'FontSize', 14, 'FontWeight', 'bold', 'Rotation', 0); % Adjust position as needed


clear min_P ID ChanMax SMAx unique_S Ch_by_time
% Compute ERP difference for interaction (Picture onset)
CN_CP_pic = squeeze(mean(dataPic{1,2},1)) - squeeze(mean(dataPic{1,1},1));
CN_IP_pic = squeeze(mean(dataPic{1,2},1)) - squeeze(mean(dataPic{2,1},1));
CN_IN_pic = squeeze(mean(dataPic{1,2},1)) - squeeze(mean(dataPic{2,2},1));
CP_IP_pic = squeeze(mean(dataPic{1,1},1)) - squeeze(mean(dataPic{2,1},1));
CP_IN_pic = squeeze(mean(dataPic{1,1},1)) - squeeze(mean(dataPic{2,2},1));
IP_IN_pic = squeeze(mean(dataPic{2,1},1)) - squeeze(mean(dataPic{2,2},1));

[min_P, ID] = min(resultsPic.P_Values.AB(:));
[ChanMax, SMAx]      = ind2sub(size(resultsPic.P_Values.AB),ID);
[unique_S, ~, idx] = unique(sPic.AB);
Ch_by_time = cell(length(unique_S), 1);

% Loop through each unique time point and gather corresponding Ch values
for i = 1:length(unique_S)
    % Find indices in S that match the current unique time
    corresponding_indices = (sPic.AB == unique_S(i));
    % Get corresponding Ch values for the current time point
    Ch_by_time{i} = chPic.AB(corresponding_indices);
end
chXtime = find(unique_S == 692);

nexttile
current_channels = Ch_by_time{chXtime};
labels = arrayfun(@(x) chanLocs(x).labels, current_channels, 'UniformOutput', false);
topoplot(CN_CP_pic(:,SMAx)', chanLocs,...
    'electrodes',           'on',           ...         % display markers ("labels" shows electrode names
    'whitebk',              'on',           ...
    'colormap',             cmaptopo,            ...
    'shading',              'interp',       ...         % (flat or interp) useless with style is "fill"
    'style',                'map',         ...
    'numcontour',           6,             ...         % Increase for more contour details
    'plotrad',              max(abs(cell2mat({chanLocs.radius}))),...
    'maplimits',[-1 1]); % 'map' 'contour' 'both' 'fill' 'blank'
text(0, -0.8, sprintf('%d ms', timePic(unique_S(chXtime))), ...
    'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'center','FontSize',14);
title('CN - CP','FontSize',14)
set(get(gca,'title'),'Position',[0 0.9 1.00011])
ylimits = ylim; % Get current y-axis limits
text(-0.5, ylimits(2)+.5, 'B', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', ...
    'FontSize', 14, 'FontWeight', 'bold', 'Rotation', 0); % Adjust position as needed

nexttile
current_channels = Ch_by_time{chXtime};
labels = arrayfun(@(x) chanLocs(x).labels, current_channels, 'UniformOutput', false);
topoplot(CN_IP_pic(:,SMAx)', chanLocs,...
    'electrodes',           'on',           ...         % display markers ("labels" shows electrode names
    'whitebk',              'on',           ...
    'colormap',             cmaptopo,            ...
    'shading',              'interp',       ...         % (flat or interp) useless with style is "fill"
    'style',                'map',         ...
    'numcontour',           6,             ...         % Increase for more contour details
    'plotrad',              max(abs(cell2mat({chanLocs.radius}))),...
    'maplimits',[-1 1]); % 'map' 'contour' 'both' 'fill' 'blank'
text(0, -0.8, sprintf('%d ms', timePic(unique_S(chXtime))), ...
    'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'center','FontSize',14);
title('CN - IP','FontSize',14)
set(get(gca,'title'),'Position',[0 0.9 1.00011])

nexttile
current_channels = Ch_by_time{chXtime};
labels = arrayfun(@(x) chanLocs(x).labels, current_channels, 'UniformOutput', false);
topoplot(CN_IN_pic(:,SMAx)', chanLocs,...
    'electrodes',           'on',           ...         % display markers ("labels" shows electrode names
    'whitebk',              'on',           ...
    'colormap',             cmaptopo,            ...
    'shading',              'interp',       ...         % (flat or interp) useless with style is "fill"
    'style',                'map',         ...
    'numcontour',           6,             ...         % Increase for more contour details
    'plotrad',              max(abs(cell2mat({chanLocs.radius}))),...
    'maplimits',[-1 1]); % 'map' 'contour' 'both' 'fill' 'blank'
text(0, -0.8, sprintf('%d ms', timePic(unique_S(chXtime))), ...
    'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'center','FontSize',14);
title('CN - IN','FontSize',14);
set(get(gca,'title'),'Position',[0 0.9 1.00011])

nexttile
current_channels = Ch_by_time{chXtime};
labels = arrayfun(@(x) chanLocs(x).labels, current_channels, 'UniformOutput', false);
topoplot(CP_IP_pic(:,SMAx)', chanLocs,...
    'electrodes',           'on',           ...         % display markers ("labels" shows electrode names
    'whitebk',              'on',           ...
    'colormap',             cmaptopo,            ...
    'shading',              'interp',       ...         % (flat or interp) useless with style is "fill"
    'style',                'map',         ...
    'numcontour',           6,             ...         % Increase for more contour details
    'plotrad',              max(abs(cell2mat({chanLocs.radius}))),...
    'maplimits',[-1 1]); % 'map' 'contour' 'both' 'fill' 'blank'
text(0, -0.8, sprintf('%d ms', timePic(unique_S(chXtime))), ...
    'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'center','FontSize',14);
title('CP - IP','FontSize',14)
set(get(gca,'title'),'Position',[0 0.9 1.00011])

nexttile
current_channels = Ch_by_time{chXtime};
labels = arrayfun(@(x) chanLocs(x).labels, current_channels, 'UniformOutput', false);
topoplot(CP_IN_pic(:,SMAx)', chanLocs,...
    'electrodes',           'on',           ...         % display markers ("labels" shows electrode names
    'whitebk',              'on',           ...
    'colormap',             cmaptopo,            ...
    'shading',              'interp',       ...         % (flat or interp) useless with style is "fill"
    'style',                'map',         ...
    'numcontour',           6,             ...         % Increase for more contour details
    'plotrad',              max(abs(cell2mat({chanLocs.radius}))),...
    'maplimits',[-1 1]); % 'map' 'contour' 'both' 'fill' 'blank'
text(0, -0.8, sprintf('%d ms', timePic(unique_S(chXtime))), ...
    'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'center','FontSize',14);
title('CP - IN','FontSize',14)
set(get(gca,'title'),'Position',[0 0.9 1.00011])

nexttile
current_channels = Ch_by_time{chXtime};
labels = arrayfun(@(x) chanLocs(x).labels, current_channels, 'UniformOutput', false);
topoplot(IP_IN_pic(:,SMAx)', chanLocs,...
    'electrodes',           'on',           ...         % display markers ("labels" shows electrode names
    'whitebk',              'on',           ...
    'colormap',             cmaptopo,            ...
    'shading',              'interp',       ...         % (flat or interp) useless with style is "fill"
    'style',                'map',         ...
    'numcontour',           6,             ...         % Increase for more contour details
    'plotrad',              max(abs(cell2mat({chanLocs.radius}))),...
    'maplimits',[-1 1]); % 'map' 'contour' 'both' 'fill' 'blank'
c= colorbar;
c.Limits= ([-1 1]);
c.Label.String = '\muV';
c.Label.Rotation = 90+90+90+90;
c.Ticks = [-1 0 1];
c.FontSize = 14;
text(0, -0.8, sprintf('%d ms', timePic(unique_S(chXtime))), ...
    'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'center','FontSize',14);
title('IP - IN','FontSize',14)
set(get(gca,'title'),'Position',[0 0.9 1.00011])

clear min_P ID ChanMax SMAx unique_S Ch_by_time
% For the same figure, add topoplots with the activation map for Movement Onset
% Compute ERP difference for valence (Picture onset)
posMov = squeeze(mean(dataMov{1,1},1)) + squeeze(mean(dataMov{2,1},1));
negMov = squeeze(mean(dataMov{1,2},1)) + squeeze(mean(dataMov{2,2},1));
difValMov = posMov-negMov;

[min_P, ID] = min(resultsMov.P_Values.B(:));
[ChanMax, SMAx]      = ind2sub(size(resultsMov.P_Values.B),ID);
[unique_S, ~, idx] = unique(sMov.B);
Ch_by_time = cell(length(unique_S), 1);

% Loop through each unique time point and gather corresponding Ch values
for i = 1:length(unique_S)
    % Find indices in S that match the current unique time
    corresponding_indices = (sMov.B == unique_S(i));
    % Get corresponding Ch values for the current time point
    Ch_by_time{i} = chMov.B(corresponding_indices);
end
chXtime = find(unique_S == 402);

nexttile
current_channels = Ch_by_time{chXtime};
labels = arrayfun(@(x) chanLocs(x).labels, current_channels, 'UniformOutput', false);
topoplot(difValMov(:,SMAx)', chanLocs,...
    'electrodes',           'on',           ...         % display markers ("labels" shows electrode names
    'whitebk',              'on',           ...
    'colormap',             cmaptopo,            ...
    'shading',              'interp',       ...         % (flat or interp) useless with style is "fill"
    'style',                'map',         ...
    'numcontour',           6,             ...         % Increase for more contour details
    'plotrad',              max(abs(cell2mat({chanLocs.radius}))),...
    'maplimits',[-2 2]); % 'map' 'contour' 'both' 'fill' 'blank'
% Adjust the colorbar position
% cbPos = c.Position; % Get the current position of the colorbar
% cbPos(1) = cbPos(1) - 0.05; % Move it closer to the plot (decrease horizontal spacing)
% c.Position = cbPos; % Apply the new position
text(0, -0.8, sprintf('%d ms', timeMov(unique_S(chXtime))), ...
    'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'center','FontSize',14);
title('Positive - Negative','FontSize',14)
set(get(gca,'title'),'Position',[0 0.9 1.00011])
text(-0.75, ylimits(2)+.5, 'D', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', ...
    'FontSize', 14, 'FontWeight', 'bold', 'Rotation', 0); % Adjust position as needed


clear min_P ID ChanMax SMAx unique_S Ch_by_time
% Compute ERP difference for interaction (Picture onset)
CN_CP_Mov = squeeze(mean(dataMov{1,2},1)) - squeeze(mean(dataMov{1,1},1));
CN_IP_Mov = squeeze(mean(dataMov{1,2},1)) - squeeze(mean(dataMov{2,1},1));
CN_IN_Mov = squeeze(mean(dataMov{1,2},1)) - squeeze(mean(dataMov{2,2},1));
CP_IP_Mov = squeeze(mean(dataMov{1,1},1)) - squeeze(mean(dataMov{2,1},1));
CP_IN_Mov = squeeze(mean(dataMov{1,1},1)) - squeeze(mean(dataMov{2,2},1));
IP_IN_Mov = squeeze(mean(dataMov{2,1},1)) - squeeze(mean(dataMov{2,2},1));

[min_P, ID] = min(resultsMov.P_Values.AB(:));
[ChanMax, SMAx]      = ind2sub(size(resultsMov.P_Values.AB),ID);
[unique_S, ~, idx] = unique(sMov.AB);
Ch_by_time = cell(length(unique_S), 1);

% Loop through each unique time point and gather corresponding Ch values
for i = 1:length(unique_S)
    % Find indices in S that match the current unique time
    corresponding_indices = (sMov.AB == unique_S(i));
    % Get corresponding Ch values for the current time point
    Ch_by_time{i} = chMov.AB(corresponding_indices);
end
chXtime = find(unique_S == 455);

nexttile
current_channels = Ch_by_time{chXtime};
labels = arrayfun(@(x) chanLocs(x).labels, current_channels, 'UniformOutput', false);
topoplot(CN_CP_Mov(:,SMAx)', chanLocs,...
    'electrodes',           'on',           ...         % display markers ("labels" shows electrode names
    'whitebk',              'on',           ...
    'colormap',             cmaptopo,            ...
    'shading',              'interp',       ...         % (flat or interp) useless with style is "fill"
    'style',                'map',         ...
    'numcontour',           6,             ...         % Increase for more contour details
    'plotrad',              max(abs(cell2mat({chanLocs.radius}))),...
    'maplimits',[-2 2]); % 'map' 'contour' 'both' 'fill' 'blank'
text(0, -0.8, sprintf('%d ms', timeMov(unique_S(chXtime))), ...
    'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'center','FontSize',14);
title('CN - CP','FontSize',14)
set(get(gca,'title'),'Position',[0 0.9 1.00011])
ylimits = ylim; % Get current y-axis limits
text(-0.5, ylimits(2)+.5, 'E', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', ...
    'FontSize', 14, 'FontWeight', 'bold', 'Rotation', 0); % Adjust position as needed


nexttile
current_channels = Ch_by_time{chXtime};
labels = arrayfun(@(x) chanLocs(x).labels, current_channels, 'UniformOutput', false);
topoplot(CN_IP_Mov(:,SMAx)', chanLocs,...
    'electrodes',           'on',           ...         % display markers ("labels" shows electrode names
    'whitebk',              'on',           ...
    'colormap',             cmaptopo,            ...
    'shading',              'interp',       ...         % (flat or interp) useless with style is "fill"
    'style',                'map',         ...
    'numcontour',           6,             ...         % Increase for more contour details
    'plotrad',              max(abs(cell2mat({chanLocs.radius}))),...
    'maplimits',[-2 2]); % 'map' 'contour' 'both' 'fill' 'blank'
text(0, -0.8, sprintf('%d ms', timeMov(unique_S(chXtime))), ...
    'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'center','FontSize',14);
title('CN - IP','FontSize',14)
set(get(gca,'title'),'Position',[0 0.9 1.00011])

nexttile
current_channels = Ch_by_time{chXtime};
labels = arrayfun(@(x) chanLocs(x).labels, current_channels, 'UniformOutput', false);
topoplot(CN_IN_Mov(:,SMAx)', chanLocs,...
    'electrodes',           'on',           ...         % display markers ("labels" shows electrode names
    'whitebk',              'on',           ...
    'colormap',             cmaptopo,            ...
    'shading',              'interp',       ...         % (flat or interp) useless with style is "fill"
    'style',                'map',         ...
    'numcontour',           6,             ...         % Increase for more contour details
    'plotrad',              max(abs(cell2mat({chanLocs.radius}))),...
    'maplimits',[-2 2]); % 'map' 'contour' 'both' 'fill' 'blank'
text(0, -0.8, sprintf('%d ms', timeMov(unique_S(chXtime))), ...
    'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'center','FontSize',14);
title('CN - IN','FontSize',14)
set(get(gca,'title'),'Position',[0 0.9 1.00011])

nexttile
current_channels = Ch_by_time{chXtime};
labels = arrayfun(@(x) chanLocs(x).labels, current_channels, 'UniformOutput', false);
topoplot(CP_IP_Mov(:,SMAx)', chanLocs,...
    'electrodes',           'on',           ...         % display markers ("labels" shows electrode names
    'whitebk',              'on',           ...
    'colormap',             cmaptopo,            ...
    'shading',              'interp',       ...         % (flat or interp) useless with style is "fill"
    'style',                'map',         ...
    'numcontour',           6,             ...         % Increase for more contour details
    'plotrad',              max(abs(cell2mat({chanLocs.radius}))),...
    'maplimits',[-2 2]); % 'map' 'contour' 'both' 'fill' 'blank'
text(0, -0.8, sprintf('%d ms', timeMov(unique_S(chXtime))), ...
    'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'center','FontSize',14);
title('CP - IP','FontSize',14)
set(get(gca,'title'),'Position',[0 0.9 1.00011])

nexttile
current_channels = Ch_by_time{chXtime};
labels = arrayfun(@(x) chanLocs(x).labels, current_channels, 'UniformOutput', false);
topoplot(CP_IN_Mov(:,SMAx)', chanLocs,...
    'electrodes',           'on',           ...         % display markers ("labels" shows electrode names
    'whitebk',              'on',           ...
    'colormap',             cmaptopo,            ...
    'shading',              'interp',       ...         % (flat or interp) useless with style is "fill"
    'style',                'map',         ...
    'numcontour',           6,             ...         % Increase for more contour details
    'plotrad',              max(abs(cell2mat({chanLocs.radius}))),...
    'maplimits',[-2 2]); % 'map' 'contour' 'both' 'fill' 'blank'
text(0, -0.8, sprintf('%d ms', timeMov(unique_S(chXtime))), ...
    'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'center','FontSize',14);
title('CP - IN', 'FontSize', 14) % Create the title and store its handle
set(get(gca,'title'),'Position',[0 0.9 1.00011])

nexttile
current_channels = Ch_by_time{chXtime};
labels = arrayfun(@(x) chanLocs(x).labels, current_channels, 'UniformOutput', false);
topoplot(IP_IN_Mov(:,SMAx)', chanLocs,...
    'electrodes',           'on',           ...         % display markers ("labels" shows electrode names
    'whitebk',              'on',           ...
    'colormap',             cmaptopo,            ...
    'shading',              'interp',       ...         % (flat or interp) useless with style is "fill"
    'style',                'map',         ...
    'numcontour',           6,             ...         % Increase for more contour details
    'plotrad',              max(abs(cell2mat({chanLocs.radius}))),...
    'maplimits',[-2 2]); % 'map' 'contour' 'both' 'fill' 'blank'
c= colorbar;
c.Limits= ([-2 2]);
c.Label.String = '\muV';
c.Label.Rotation = 90+90+90+90;
c.Ticks = [-2 0 2];
c.FontSize = 14;
text(0, -0.8, sprintf('%d ms', timeMov(unique_S(chXtime))), ...
    'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'center','FontSize',14);
title('IP - IN','FontSize',14)
set(get(gca,'title'),'Position',[0 0.9 1.00011])

fig = gcf;
exportgraphics(fig,'ResultsEEG1.AllTopoplotsSignificantPeaks.png','Resolution',600)
clear f fig
%% Remove path
rmpath(dataPath)
rmpath(functionPath)
rmpath(EEGLABfolder)
