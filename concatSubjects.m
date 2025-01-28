%% Concatenate data from all participants in a single matrix per condition
% Remove participants with low number of trials
%dataFolder = [];
%saveFolder = [];
%plottingFolder = [];

if ~exist(saveFolder,'dir')
    mkdir(saveFolder)
elseif ~exist(plottingFolder,'dir')
    mkdir(plottingFolder)
end
addpath(dataFolder)
addpath(saveFolder)
addpath(plottingFolder)
%% Get information about files
participants = [];
tmp = dir(fullfile(dataFolder));
inx = 1;
for pId = 1:size(tmp, 1)
    currentName = tmp(pId).name;
    if currentName(1) == '.' || ~contains(currentName,'.mat') || ~contains(currentName,'SUB')
        continue;
    end

    participants(inx).name = currentName;
    participants(inx).folder = tmp(pId).folder;
    participants(inx).date = tmp(pId).date;
    inx = inx + 1;
end
%% Get index from each file, concatenate relevant data and get number of trials
files = {participants.name};
CN = find(contains(files,'CongNeg'));
for i = 1:length(CN)
    load(participants(CN(i)).name,'logAlphaF3','logAlphaF4','logAlphaLeft','logAlphaRight','EEG')
    congNegF3(i,:) = logAlphaF3;
    congNegF4(i,:) = logAlphaF4;
    congNegLeft(i,:) = logAlphaLeft;
    congNegRight(i,:) = logAlphaRight;
    nTrialsCongNeg(i,:) = size(EEG.data,3);
end

CP = find(contains(files,'CongPos'));
for i = 1:length(CP)
    load(participants(CP(i)).name,'logAlphaF3','logAlphaF4','logAlphaLeft','logAlphaRight','EEG')
    congPosF3(i,:) = logAlphaF3;
    congPosF4(i,:) = logAlphaF4;
    congPosLeft(i,:) = logAlphaLeft;
    congPosRight(i,:) = logAlphaRight;
    nTrialsCongPos(i,:) = size(EEG.data,3);
end

IN = find(contains(files,'IncongNeg'));
for i = 1:length(IN)
    load(participants(IN(i)).name,'logAlphaF3','logAlphaF4','logAlphaLeft','logAlphaRight','EEG')
    incongNegF3(i,:) = logAlphaF3;
    incongNegF4(i,:) = logAlphaF4;
    incongNegLeft(i,:) = logAlphaLeft;
    incongNegRight(i,:) = logAlphaRight;
    nTrialsIncongNeg(i,:) = size(EEG.data,3);
end

IP = find(contains(files,'IncongPos'));
for i = 1:length(IP)
    load(participants(IP(i)).name,'logAlphaF3','logAlphaF4','logAlphaLeft','logAlphaRight','EEG')
    incongPosF3(i,:) = logAlphaF3;
    incongPosF4(i,:) = logAlphaF4;
    incongPosLeft(i,:) = logAlphaLeft;
    incongPosRight(i,:) = logAlphaRight;
    nTrialsIncongPos(i,:) = size(EEG.data,3);
end
%% Determine which participants we are excluding due to low number of trials
nMaxTrials = 80;
totalTrials = (nTrialsCongNeg+nTrialsCongPos+nTrialsIncongNeg+nTrialsIncongPos);
perTrials = (totalTrials*100)/nMaxTrials;

figure(1)
subplot(3,2,1)
bar(nTrialsCongNeg)
xlabel('Participants')
ylabel('Number of Valid Trials')
title('CongNeg')

subplot(3,2,2)
bar(nTrialsCongPos)
xlabel('Participants')
ylabel('Number of Valid Trials')
title('CongPos')

subplot(3,2,3)
bar(nTrialsIncongNeg)
xlabel('Participants')
ylabel('Number of Valid Trials')
title('IncongNeg')

subplot(3,2,4)
bar(nTrialsIncongPos)
xlabel('Participants')
ylabel('Number of Valid Trials')
title('IncongPos')

subplot(3,2,[5,6])
bar(perTrials)
xlabel('Participants')
ylabel('Percentage of Valid trials')
title('Valid Trials over Conditions')
xlim([0 42])
hline(90,'k-')

% Save the plot here
print([plottingFolder,filesep,'nEEGtrialsBP.png'], '-dpng', '-r400');

under90 = find(perTrials < 90);
under80 = find(perTrials < 80);
under70 = find(perTrials < 70);
under60 = find(perTrials < 60);
under50 = find(perTrials < 50);

toExclude = table(length(under50),length(under60),length(under70),length(under80),length(under90),'VariableNames',{'50%','60%','70%','80%','90%'});

% Plot the table
% Get the table in string form.
TString = evalc('disp(toExclude)');
% Use TeX Markup for bold formatting and underscores.
TString = strrep(TString,'<strong>','\bf');
TString = strrep(TString,'</strong>','\rm');
TString = strrep(TString,'_','\_');
% Get a fixed-width font.
FixedWidth = get(0,'FixedWidthFontName');
% Output the table using the annotation command.
annotation(gcf,'Textbox','String',TString,'Interpreter','Tex',...
    'FontName',FixedWidth,'Units','Normalized','Position',[0 0 1 1]);

print([plottingFolder,filesep,'nToExcludeBP.png'], '-dpng', '-r400');

save([saveFolder,filesep,'participants2excludeBP.mat'],'toExclude','under50','under60','under70','under80','under90','-v7.3')
%% Remove participants, from bigges index to smalles (FOR NOW, APPLYING 50%)
congPosF3(under90(1),:,:) = [];
congPosF4(under90(1),:,:) = [];
congPosLeft(under90(1),:,:) = [];
congPosRight(under90(1),:,:) = [];

incongPosF3(under90(1),:,:) = [];
incongPosF4(under90(1),:,:) = [];
incongPosLeft(under90(1),:,:) = [];
incongPosRight(under90(1),:,:) = [];

congNegF3(under90(1),:,:) = [];
congNegF4(under90(1),:,:) = [];
congNegLeft(under90(1),:,:) = [];
congNegRight(under90(1),:,:) = [];

incongNegF3(under90(1),:,:) = [];
incongNegF4(under90(1),:,:) = [];
incongNegLeft(under90(1),:,:) = [];
incongNegRight(under90(1),:,:) = [];

save([saveFolder,filesep,'January_allMeasures_PicOnset.mat'],'congPosF3','congPosF4','congPosLeft','congPosRight',...
    'incongPosF3','incongPosF4','incongPosLeft','incongPosRight','congNegF3','congNegF4','congNegLeft','congNegRight',...
    'incongNegF3','incongNegF4','incongNegLeft','incongNegRight','-v7.3')
%% Remove path
rmpath(dataFolder)
rmpath(plottingFolder)