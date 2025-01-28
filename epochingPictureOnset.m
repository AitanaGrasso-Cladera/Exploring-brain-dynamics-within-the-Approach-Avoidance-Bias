%% Epoching the data
%eegDataFolder = [];
%behavDataFolder = [];
%saveFolder = [];

if ~exist(saveFolder,'dir')
    mkdir(saveFolder)
end

addpath(eegDataFolder)
addpath(behavDataFolder)
addpath(saveFolder)
%% Get information about files
participants = [];
tmp = dir(fullfile(eegDataFolder));
inx = 1;
for pId = 1:size(tmp,1)
    currentName = tmp(pId).name;
    if currentName(1) == '.' ||	~contains(currentName,'.set')
        continue
    end
    participants(inx).name = currentName;
    participants(inx).folder = tmp(pId).folder;
    participants(inx).date = tmp(pId).date;
    
    inx = inx + 1;
end
%% Parameters
epochLength = [-.8 1];
baseLine = [-150 0];
nTrials = 40;
maxPos = 44;
condNames = {'CongPos','CongNeg','IncongPos','IncongNeg'};
%% Load the data
load([behavDataFolder,filesep,'behavioralData.mat'])
load([behavDataFolder,filesep,'errorTrials.mat'],'minus90Cong','minus90Incong')
toExclude = unique(cat(1,minus90Cong,minus90Incong));
clear minus90Cong minus90Incong
load([behavDataFolder,filesep,'congruentTrials.mat'])
load([behavDataFolder,filesep,'incongruentTrials.mat'])
%% Epoch
for pIx = 1:size(participants,2)
    if ismember(pIx,toExclude)
        continue
    else
        
        % Determine block type
        % 1 and 3 = Congruent - Incongruent
        % 2 and 4 = Incongruent - Congruent
        
        if subjectsData.blockOrder(pIx) == 1 ||subjectsData.blockOrder(pIx) == 3 % 1 = Congruent; 0 = Incongruent
            block = logical([ones(1,nTrials),zeros(1,nTrials)]);
            %trials = ([congruentReactionTime(:,pIx);incongruentReactionTime(:,pIx)])';
            pictures = ([congruentPictureSequence(:,pIx);incongruentPictureSequence(:,pIx)])';
        elseif subjectsData.blockOrder(pIx) == 2 ||subjectsData.blockOrder(pIx) == 4
            block = logical([zeros(1,nTrials),ones(1,nTrials)]);
            %trials = ([incongruentReactionTime(:,pIx);congruentReactionTime(:,pIx)])';
            pictures = ([incongruentPictureSequence(:,pIx);congruentPictureSequence(:,pIx)])';
        end
        

        for i = 1:length(block)
            if block(i) == 1 && pictures(i) <= maxPos
                trialType(i) = {'CP'};
            elseif block(i) == 1 && pictures(i) > maxPos
                trialType(i) = {'CN'};
            elseif block(i) == 0 && pictures(i) <= maxPos
                trialType(i) = {'IP'};
            elseif block(i) == 0 && pictures(i) > maxPos
                trialType(i) = {'IN'};
            else
                trialType(i) = {'NonValid'};
            end
        end
        
        EEGtrials.label = trialType;
        
        thisFile = [eegDataFolder,filesep,participants(pIx).name];
        for cIdx = 1:size(condNames,2)
            EEG = pop_loadset(thisFile);
            % Change numbers to meaningful strings
            for j = 1:length(EEG.event)
                switch EEG.event(j).type
                    case '190'
                        EEG.event(j).type = 'push';
                    case '191'
                        EEG.event(j).type = 'pull';
                    case {'1','2','3','4','5','6','7','8','9','10','11','12','13','14','15',...
                            '16','17','18','19','20','21','22','23','24','25','26','27','28','29','30','31','32','33',...
                            '34','35','36','37','38','39','40'}
                        EEG.event(j).type = 'muscle';
                    case {'41','42','43','44','85','86','87','88'}
                        EEG.event(j).type = 'test';
                    case '255'
                        EEG.event(j).type = 'end';
                    case '200'
                        EEG.event(j).type = 'start';
                end
            end
            
            eventLabels = {EEG.event.type};
            boundaryIdx = [];
            boundaryIdx = find(strcmp(eventLabels,'boundary'));
            startr = [];
            start = find(strcmp(eventLabels,'start'));
            if isempty(start)
                start = 2;
            end
            final = find(strcmp(eventLabels,'end'));
            if isempty(final)
                final = length(eventLabels);
            end

            for i = 1:size(boundaryIdx,2)
                if boundaryIdx(i) > start && boundaryIdx(i) < final
                    if strcmp(eventLabels(boundaryIdx(i)-1),'pull') || strcmp(eventLabels(boundaryIdx(i)-1),'push')
                        eventLabels(boundaryIdx(i)) = {'pictureBoundary'};
                        EEG.event(boundaryIdx(i)).type = 'pictureBoundary';
                    elseif isnumeric(str2double(eventLabels{boundaryIdx(i)-1}))
                        eventLabels(boundaryIdx(i)) = {'muscleBoundary'};
                        EEG.event(boundaryIdx(i)).type = 'muscleBoundary';
                    elseif strcmp(eventLabels(boundaryIdx(i)+1),'pull') || strcmp(eventLabels(boundaryIdx(i)+1),'push')
                        eventLabels(boundaryIdx(i)) = {'pictureBoundary'};
                        EEG.event(boundaryIdx(i)).type = 'pictureBoundary';
                    elseif isnumeric(str2double(eventLabels{boundaryIdx(i)+1}))
                        eventLabels(boundaryIdx(i)) = {'muscleBoundary'};
                        EEG.event(boundaryIdx(i)).type = 'muscleBoundary';
                    end
                end
            end

            eventsIdx = [];
            eventsIdx = find(~strcmp(eventLabels,'push') & ~strcmp(eventLabels,'pull') &...
                ~strcmp(eventLabels,'muscle') & ~strcmp(eventLabels,'test') & ~strcmp(eventLabels,'0, Impedance') &...
                ~strcmp(eventLabels,'boundary') & ~strcmp(eventLabels,'end') & ~strcmp(eventLabels,'start'));
        
            EEGtarget = [];
            trial = [];
            EEGtrials.number = [45:84,89:128];
            eventLabels = {EEG.event.type};
            boundaryEvents = find(strcmp(eventLabels,'pictureBoundary') | strcmp(eventLabels,'muscleBoundary'));
            excluding = find(strcmp(eventLabels,'pictureBoundary'));

            indicesBoundary = find(ismember(eventsIdx, boundaryEvents));
            indicesExcluding = find(ismember(eventsIdx, excluding));

            for j = 1:length(eventsIdx)
                target = eventsIdx(j);
                if sum(ismember(excluding,target)) == 1
                    continue
                else
                    EEGtarget = str2double(EEG.event(target).type(EEG.event(target).type ~= ' '));
                    trial = find(EEGtrials.number == EEGtarget);
                    EEG.event(target).type = char(EEGtrials.label(1,trial));
                    %EEG.event(target+1).type = [EEG.event(target+1).type,char(EEGtrials.label(1,trial))];
                end
            end
            
            eventMarkerLabels = {EEG.event.type};
            
            if strcmp(condNames(cIdx),'CongPos')
                congruentPosTrials = contains(eventMarkerLabels,'CP');
                theseCodes = eventMarkerLabels(congruentPosTrials);
            elseif strcmp(condNames(cIdx),'CongNeg')
                congruentNegTrials = contains(eventMarkerLabels,'CN');
                theseCodes = eventMarkerLabels(congruentNegTrials);
            elseif strcmp(condNames(cIdx),'IncongPos')
                incongruentPosTrials = contains(eventMarkerLabels,'IP');
                theseCodes = eventMarkerLabels(incongruentPosTrials);
            elseif strcmp(condNames(cIdx),'IncongNeg')
                incongruentNegTrials = contains(eventMarkerLabels,'IN');
                theseCodes = eventMarkerLabels(incongruentNegTrials);
            end
            
            saveName = [participants(pIx).name(18:end-4),'_',condNames{cIdx},'.set'];
            EEG.setname = saveName;
            EEG = pop_epoch(EEG,theseCodes,epochLength,'newname',saveName,'epochinfo','yes');
            EEG = eeg_checkset(EEG);
            
            if ndims(EEG.data) == 2
                continue
            else
                try
                    EEG = pop_saveset(EEG,'filename',saveName,'filepath',saveFolder);
                catch ME
                end
            end
        end
    end
    clear block trials
end
%%
rmpath(eegDataFolder)
rmpath(behavDataFolder)
rmpath(saveFolder)















