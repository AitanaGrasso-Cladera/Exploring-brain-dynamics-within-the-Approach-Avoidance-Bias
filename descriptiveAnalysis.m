%% Descriptive analysis
%dataFolder = [];
%plotFolder = [];
addpath(dataFolder)
addpath(plotFolder)
%% Parameters
firstActualTrial = 5; % after test trials
nValidTrials = 40; % not considering test trials
nTrials = 44;
%% What are you working on?
getValidTrials = 1;
prepForStats = 1;
%% Get valid trials
if getValidTrials
    % Load the data
    load('behavioralData.mat')
    
    congruentReactionTime = nan(nTrials,size(subjectsData.actualReaction,2));
    congruentPictureSequence = nan(nTrials,size(subjectsData.actualReaction,2));
    congruentErrorPictures = nan(nTrials,size(subjectsData.actualReaction,2));
    
    for i = firstActualTrial:nTrials
        for j = 1:size(subjectsData.actualReaction,2)
            if subjectsData.congruent.correctReaction(i,j) == subjectsData.congruent.actualReaction(i,j)
                congruentReactionTime(i,j) = subjectsData.congruent.reactionTime(i,j);
                congruentPictureSequence(i,j) = subjectsData.congruent.pictureSequence(i,j);
            else
                congruentErrorPictures(i,j) = subjectsData.congruent.pictureSequence(i,j);
                congruentReactionTime(i,j) = NaN;
                congruentPictureSequence(i,j) = NaN;
            end
        end
    end
    
    congruentReactionTime = congruentReactionTime(firstActualTrial:end,:);
    congruentPictureSequence = congruentPictureSequence(firstActualTrial:end,:);
    congruentErrorPictures = congruentErrorPictures(firstActualTrial:end,:);
    
    congruentInvoluntaryResponse = congruentReactionTime <= .150;
    congruentReactionTime(congruentInvoluntaryResponse) = NaN;
    congruentPictureSequence(congruentInvoluntaryResponse) = NaN;
    
    save(fullfile([dataFolder,filesep,'congruentTrials']),'congruentReactionTime','congruentPictureSequence',...
        'congruentErrorPictures','congruentInvoluntaryResponse')
    
    
    incongruentReactionTime = nan(nTrials,size(subjectsData.actualReaction,2));
    incongruentPictureSequence = nan(nTrials,size(subjectsData.actualReaction,2));
    incongruentErrorPictures = nan(nTrials,size(subjectsData.actualReaction,2));
    
    for i = firstActualTrial:nTrials
        for j = 1:size(subjectsData.actualReaction,2)
            if subjectsData.incongruent.correctReaction(i,j) == subjectsData.incongruent.actualReaction(i,j)
                incongruentReactionTime(i,j) = subjectsData.incongruent.reactionTime(i,j);
                incongruentPictureSequence(i,j) = subjectsData.incongruent.pictureSequence(i,j);
            else
                incongruentErrorPictures(i,j) = subjectsData.incongruent.pictureSequence(i,j);
                incongruentReactionTime(i,j) = NaN;
                incongruentPictureSequence(i,j) = NaN;
            end
        end
    end
    
    incongruentReactionTime = incongruentReactionTime(firstActualTrial:end,:);
    incongruentPictureSequence = incongruentPictureSequence(firstActualTrial:end,:);
    incongruentErrorPictures = incongruentErrorPictures(firstActualTrial:end,:);
    
    incongruentInvoluntaryResponse = incongruentReactionTime <= .150;
    incongruentReactionTime(incongruentInvoluntaryResponse) = NaN;
    incongruentPictureSequence(incongruentInvoluntaryResponse) = NaN;
    
    save(fullfile([dataFolder,filesep,'incongruentTrials']),'incongruentReactionTime','incongruentPictureSequence',...
        'incongruentErrorPictures','incongruentInvoluntaryResponse') 
end
%% Prepare data for running statistics
if prepForStats
    load('congruentTrials.mat')
    load('incongruentTrials.mat')
    
    nTrials = size(congruentReactionTime,2);
    nParticipants = size(congruentReactionTime,2);
    nPictures = 88;
    %% Get number of correct trials
    for i = 1:nParticipants
        correctTrialsCong(i) = nTrials - sum(isnan(congruentPictureSequence(:,i)));
        correctTrialsIncong(i) = nTrials - sum(isnan(incongruentPictureSequence(:,i)));
    end
    
    % Compute percentage
    perValidCong = (correctTrialsCong./nTrials)*100;
    minus90Cong = find(perValidCong < 90);
    
    perValidIncong = (correctTrialsIncong./nTrials)*100;
    minus90Incong = find(perValidIncong < 90);
    
    subjectToExclude = unique(cat(2,minus90Cong,minus90Incong));
    
    % Error distribution over pictures
    [freqCong,~] = histcounts(congruentErrorPictures,nPictures);
    idErrorPicCong = find(freqCong >= 3);
    [freqIncong,~] = histcounts(incongruentErrorPictures,nPictures);
    idErrorPicIncong = find(freqIncong >= 3);
    
    save(fullfile([dataFolder,filesep,'errorTrials']),'minus90Cong','minus90Incong',...
        'idErrorPicCong','idErrorPicIncong') 
    
    % Plot performance
    figure(1)
    subplot(2,1,1)
    b = bar(1:size(perValidCong,2),perValidCong,'FaceColor',[0.4660 0.6740 0.1880]);
    xlabel('Participant')
    ylabel('Percentage of correct trials')
    title('Performance - Congruent Trials')
    hline(90)
    xlim([0 44])
    subplot(2,1,2)
    b = bar(1:size(perValidIncong,2),perValidIncong,'FaceColor',[0.4660 0.6740 0.1880]);
    xlabel('Participant')
    ylabel('Percentage of correct trials')
    title('Performance - Incongruent Trials')
    hline(90)
    xlim([0 44])
    
    print([plotFolder,filesep,'performance.png'], '-dpng', '-r400');
    %% 2 STD Winsorzing
    cong = congruentReactionTime(:);
    meanCong = mean(cong,'omitmissing');
    stdCong = std(cong,'omitmissing');
    uppCong = meanCong + 2*stdCong;
    lowCong = meanCong - 2*stdCong;
    winzorzedCong = congruentReactionTime;
    winzorzedCong(winzorzedCong > uppCong) = uppCong;
    winzorzedCong(winzorzedCong < lowCong) = lowCong;
    histogram(cong)

    incong = incongruentReactionTime(:);
    meanIncong = mean(incong,'omitmissing');
    stdIncong = std(incong,'omitmissing');
    uppIncong = meanIncong + 2*stdIncong;
    lowIncong = meanIncong - 2*stdIncong;
    winzorzedIncong = incongruentReactionTime;
    winzorzedIncong(winzorzedIncong > uppIncong) = uppIncong;
    winzorzedIncong(winzorzedIncong < lowIncong) = lowIncong;
    histogram(winzorzedIncong)
    %% Log transform the reaction times
    logCongruentReactionTime = log10(winzorzedCong);
    logIncongruentReactionTime = log10(winzorzedIncong);
    
    % Plot distribution
    figure(2)
    subplot(2,1,1)
    histogram(congruentReactionTime,'facealpha',.7,'edgecolor','none')
    hold on
    histogram(logCongruentReactionTime,'facealpha',.7,'edgecolor','none')
    xlabel("Reaction Time (ms)")
    ylabel('Frequency')
    legend('Raw Data','Log Data')
    title('Reaction Time Distribution - Congruent Trials')
    subplot(2,1,2)
    histogram(incongruentReactionTime,'facealpha',.7,'edgecolor','none')
    hold on
    histogram(logIncongruentReactionTime,'facealpha',.7,'edgecolor','none')
    xlabel("Reaction Time (ms)")
    ylabel('Frequency')
    legend('Raw Data','Log Data')
    title('Reaction Time Distribution - Incongruent Trials')
 
    print([plotFolder,filesep,'RTdistribution.png'], '-dpng', '-r400');
    %% Separate the data into the four conditions of interest
    for i = 1:size(logCongruentReactionTime,1)
        for j = 1:size(logCongruentReactionTime,2)
            if congruentPictureSequence(i,j) <= nPictures/2
                congPosRT(i,j) = logCongruentReactionTime(i,j);
                congPosPic(i,j) = congruentPictureSequence(i,j);
            else
                congNegRT(i,j) = logCongruentReactionTime(i,j);
                congNegPic(i,j) = congruentPictureSequence(i,j);
            end
        end
    end
    congPosRT(congPosRT == 0) = NaN;
    congNegRT(congNegRT == 0) = NaN;
    
    congPosPic(congPosPic == 0) = NaN;
    congNegPic(congNegPic == 0) = NaN;
    
    for i = 1:size(logIncongruentReactionTime,1)
        for j = 1:size(logIncongruentReactionTime,2)
            if incongruentPictureSequence(i,j) <= nPictures/2
                incongPosRT(i,j) = logIncongruentReactionTime(i,j);
                incongPosPic(i,j) = incongruentPictureSequence(i,j);
            else
                incongNegRT(i,j) = logIncongruentReactionTime(i,j);
                incongNegPic(i,j) = incongruentPictureSequence(i,j);
            end
        end
    end
    incongPosRT(incongPosRT == 0) = NaN;
    incongNegRT(incongNegRT == 0) = NaN;
    
    incongPosPic(incongPosPic == 0) = NaN;
    incongNegPic(incongNegPic == 0) = NaN;
    
    save(fullfile([dataFolder,filesep,'transformedDataLog10']),'congPosRT','congPosPic',...
        'incongPosRT','incongPosPic','congNegRT','congNegPic',...
        'incongNegRT','incongNegPic')
end

rmpath(dataFolder)
rmpath(plotFolder)
rmpath(matlabFolder)