%% Convert back to Reaction Times, no log transform
CP = 10.^congPosRT;
CN = 10.^congNegRT;
IP = 10.^incongPosRT;
IN = 10.^incongNegRT;
%% Calculate Standard Error
allSTD = [std(CP(:),0,'omitmissing'), std(CN(:),0,'omitmissing');...
    std(IP(:),0,'omitmissing'), std(IN(:),0,'omitmissing')];
validTrials = [sum(~isnan(CP),'all'),sum(~isnan(CN),'all');sum(~isnan(IP),'all'),sum(~isnan(IN),'all')];

allSE = [(allSTD(1,1)/sqrt(validTrials(1,1))), (allSTD(1,2)/sqrt(validTrials(1,2)));...
    (allSTD(2,1)/sqrt(validTrials(2,1))),(allSTD(2,2)/sqrt(validTrials(2,2)))];

allMEAN = [mean(CP,'all','omitmissing'), mean(CN,'all','omitmissing');...
    mean(IP,'all','omitmissing'), mean(IN,'all','omitmissing')]; % Two groups with two bars each

% Create a categorical array for x-axis labels
groupLabels = categorical({'Congruent', 'Incongruent'});
% Define color palette
cmap = parula(20);
cmapHSV = rgb2hsv(cmap); % Convert to HSV
cmapHSV(:, 2) = cmapHSV(:, 2) * 0.6; % Reduce saturation (0.5 = less vivid)
cmap = hsv2rgb(cmapHSV); % Convert back to RGB
%% Create bar plot
figure(1)
barHandle = bar(groupLabels, allMEAN);
hold on
barHandle(1).FaceColor = cmap(5,:);
barHandle(2).FaceColor = cmap(12,:);
legend(barHandle, {'Pleasurable', 'Unpleasurable'}, 'Location', 'northeast', 'FontSize', 14); % Increased legend font size
ylabel('Reaction Time (s)', 'FontSize', 14); % Increased y-axis label font size
xlabel('Conditions', 'FontSize', 14); % Increased x-axis label font size
ylim([0 1.2]); 

% Increase font size of x and y ticks
ax = gca; % Get current axes
ax.FontSize = 14; % Set font size for x and y ticks

% Add errorbar (SE in this case)
numGroups = size(allMEAN, 1);
numBars = size(allMEAN, 2);
groupWidth = min(0.8, numBars/(numBars + 1.5)); % Width of each group
for i = 1:numBars
    % Calculate the x positions for each bar
    x = (1:numGroups) - groupWidth/2 + (2*i-1) * groupWidth / (2*numBars);
    errorbar(x, allMEAN(:, i), allSE(:, i), 'k', 'linestyle', 'none', 'LineWidth', 1, 'HandleVisibility', 'off');
end

% Add significance
% Between Positive and Negative (within conditions)
yMax = max(allMEAN(:)) + max(allSE(:)); % Position for the significance line
for i = 1:numGroups
    % Get x positions of the bars
    x1 = (1:numGroups) - groupWidth/2 + groupWidth / (2*numBars);
    x2 = x1 + groupWidth / numBars;
    % Draw significance line and add asterisk
    plot([x1(i), x2(i)], [yMax+.05 yMax+.05], 'k-', 'LineWidth', 1.2, 'HandleVisibility', 'off'); % Line
    text(mean([x1(i), x2(i)]), yMax+.03 + 0.04, '**', 'HorizontalAlignment', 'center', 'FontSize', 13); % Increased font size for asterisks
end

% Between Congruent and Incongruent (across groups)
xGroup1 = mean((1:numGroups) - groupWidth/2 + groupWidth / (2*numBars)); % Midpoint of group 1
xGroup2 = mean((1:numGroups) + groupWidth/2 - groupWidth / (2*numBars)); % Midpoint of group 2
yMaxBetween = yMax + 0.1; % Slightly higher than the previous significance lines
plot([xGroup1-.6, xGroup2+.6], [yMaxBetween yMaxBetween], 'k-', 'LineWidth', 1.2, 'HandleVisibility', 'off'); % Line
text(mean([xGroup1, xGroup2]), yMaxBetween + 0.02, '****', 'HorizontalAlignment', 'center', 'FontSize', 13); % Increased font size for asterisks


exportgraphics(gcf,'ResultsBehavioral.png','Resolution',600)
