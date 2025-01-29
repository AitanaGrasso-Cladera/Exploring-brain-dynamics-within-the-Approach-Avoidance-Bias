%% Unfold for movement onset
eeglab;
init_unfold
%% Get information about files
participants = [];
tmp = dir(fullfile(dataPath,filesep,'preprocessedData',filesep,'Step_5'));
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
%% Load behavioral data
load([behavDataFolder,filesep,'behavioralData.mat'])
load([behavDataFolder,filesep,'errorTrials.mat'],'minus90Cong','minus90Incong')
toExclude = unique(cat(1,minus90Cong,minus90Incong));
toExclude = [toExclude; 25];
clear minus90Cong minus90Incong
load([behavDataFolder,filesep,'congruentTrials.mat'])
load([behavDataFolder,filesep,'incongruentTrials.mat'])
%% Define parameters
epochLength = [-.8, .8];
baseLine = [-150 0];
nTrials = 40;
maxPos = 44;
%% Load the data
cnt = 1;

CN = nan(size(participants,2)-length(toExclude),64,800);
CP = nan(size(participants,2)-length(toExclude),64,800);
IN = nan(size(participants,2)-length(toExclude),64,800);
IP = nan(size(participants,2)-length(toExclude),64,800);
Mov = nan(size(participants,2)-length(toExclude),64,800);

for pIx = 1:size(participants,2)
    if ismember(pIx,toExclude)
        continue
    else

        if subjectsData.blockOrder(pIx) == 1 ||subjectsData.blockOrder(pIx) == 3 % 1 = Congruent; 0 = Incongruent
            block = logical([ones(1,nTrials),zeros(1,nTrials)]);
            pictures = ([congruentPictureSequence(:,pIx);incongruentPictureSequence(:,pIx)])';
        elseif subjectsData.blockOrder(pIx) == 2 ||subjectsData.blockOrder(pIx) == 4
            block = logical([zeros(1,nTrials),ones(1,nTrials)]);
            pictures = ([incongruentPictureSequence(:,pIx);congruentPictureSequence(:,pIx)])';
        end


        for i = 1:length(block)
            if block(i) == 1 && pictures(i) <= maxPos
                trialType(i) = {'Picture'};
                valenceType(i) = {'Positive'};
                conditionType(i) = {'Congruent'};
                currentType(i) = {'CP'};
            elseif block(i) == 1 && pictures(i) > maxPos
                trialType(i) = {'Picture'};
                valenceType(i) = {'Negative'};
                conditionType(i) = {'Congruent'};
                  currentType(i) = {'CN'};
            elseif block(i) == 0 && pictures(i) <= maxPos
                trialType(i) = {'Picture'};
                valenceType(i) = {'Positive'};
                conditionType(i) = {'Incongruent'};
                  currentType(i) = {'IP'};
            elseif block(i) == 0 && pictures(i) > maxPos
                trialType(i) = {'Picture'};
                valenceType(i) = {'Negative'};
                conditionType(i) = {'Incongruent'};
                  currentType(i) = {'IN'};
            else
                trialType(i) = {'NonValid'};
                valenceType(i) = {'NonValid'};
                conditionType(i) = {'NonValid'};
                  currentType(i) = {'NonValid'};
            end
        end

        EEGtrials.trialType = trialType;
        EEGtrials.valenceType = valenceType;
        EEGtrials.conditionType = conditionType;
        EEGtrials.currentType = currentType;

        % Load EEG data
        thisEEGFile = [dataPath,filesep,'preprocessedData',filesep,'Step_5',filesep,'noBurst',filesep,participants(pIx).name];
        EEG = pop_loadset(thisEEGFile);

        for j = 1:length(EEG.event)
            switch EEG.event(j).type
                case '190'
                    EEG.event(j).type = 'Joystick';
                case '191'
                    EEG.event(j).type = 'Joystick';
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
        for i = 1:length(eventLabels)
            if strcmp(eventLabels(i),'muscle') || strcmp(eventLabels(i),'test')
                EEG.event(i+1).type = 'nonValidMuscle';
            end
        end

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
        eventsIdx = find(~strcmp(eventLabels,'Joystick') & ...
            ~strcmp(eventLabels,'muscle') & ~strcmp(eventLabels,'test') & ~strcmp(eventLabels,'0, Impedance') &...
            ~strcmp(eventLabels,'boundary') & ~strcmp(eventLabels,'end') & ~strcmp(eventLabels,'start') &...
            ~strcmp(eventLabels,'nonValidMuscle'));

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
                EEG.event(target).type = char(EEGtrials.trialType(1,trial));
                EEG.event(target+1).valenceType = (EEGtrials.valenceType(1,trial));
                EEG.event(target+1).conditionType = (EEGtrials.conditionType(1,trial));
                EEG.event(target+1).currentType = (EEGtrials.currentType(1,trial));
            end
           
        end

        for j = 1:length(EEG.event)-1
            if strcmp(EEG.event(j).type, 'NonValid') && strcmp(EEG.event(j+1).type,'Joystick')
                EEG.event(j+1).type = 'NonValid';
            end
        end
        
        empty_events = false(size(EEG.event));
        for j = 1:length(EEG.event)
            event_fileds = fieldnames(EEG.event(1));
            if isempty(EEG.event(j).type)
                    empty_events(j) = true;
            end       
        end
        EEG.event(empty_events) = [];

        to_Remove = false(size(EEG.event));
        for j = 1:length(EEG.event)
            if strcmp(EEG.event(j).type,'Joystick') && strcmp(EEG.event(j+1).type,'Joystick')
                to_Remove(j+1) = true;
            elseif strcmp(EEG.event(j).type,'Picture') && strcmp(EEG.event(j+1).type,'Picture')
                to_Remove(j) = true;
            end
        end
        EEG.event(to_Remove) = [];

        EEG = eeg_checkset(EEG);
        %% Create design matrix
        cfgDesign = [];
        cfgDesign.eventtypes = {'Joystick','Picture'};
        cfgDesign.codingschema = 'effects';
        cfgDesign.formula = {'y ~ 1 + cat(currentType)','y ~ 1'};

        EEG = uf_designmat(EEG,cfgDesign);
        cfgTimeshift = [];
        cfgTimeshift.timelimits = epochLength;

        EEG = uf_timeexpandDesignmat(EEG,cfgTimeshift);
        %% Fit the modell
        cfgFit                  = [];
        cfgFit.precondition     = 1;
        cfgFit.lsmriterations   = 1500; % steps iterative solver should reach
        cfgFit.channel          = 1:length(EEG.chanlocs); % all channels

        EEG= uf_glmfit(EEG,cfgFit); % this method is fast but needs lots of ram
        %% Make a massive uni-variate fit without de-convolution (Gert et al., 2022)
        EEGepoch = uf_epoch(EEG,'timelimits',cfgTimeshift.timelimits);
        
        EEGepoch = uf_glmfit_nodc(EEGepoch);
        %% Get the betas
        % results condensed in new structure
        ufresult = uf_condense(EEGepoch);
        ufresultEp = uf_condense(EEGepoch);
        
        ufresultEp = uf_predictContinuous(ufresultEp); % only overlap
        ufresultEp = uf_addmarginal(ufresultEp);

        paramNames={ufresultEp.param.name};

        [~,paramPos_IP]=find(ismember(paramNames,'(Intercept)'));
        [~,paramPos_CN]=find(ismember(paramNames,'currentType_CN'));
        [~,paramPos_CP]=find(ismember(paramNames,'currentType_CP'));
        [~,paramPos_IN]=find(ismember(paramNames,'currentType_IN'));
        [~,paramPos_Joystick]=find(ismember(paramNames,'2_(Intercept)'));

        IP(cnt,:,:) = ufresultEp.beta(:,:,paramPos_IP);
        CN(cnt,:,:)  = ufresultEp.beta(:,:,paramPos_CN);
        CP(cnt,:,:)  = ufresultEp.beta(:,:,paramPos_CP);
        IN(cnt,:,:)  = ufresultEp.beta(:,:,paramPos_IN);

        time = ufresultEp.times;
        cnt = cnt+1;
    end
end

% % Exclude this participant because it has less than 50% of correct data
 CN(23,:,:) = [];
 CP(23,:,:) = [];
 IN(23,:,:) = [];
 IP(23,:,:) = [];
 Mov(23,:,:) = [];
% 
save([saveFolder,filesep,'unfoldResults_January_MovOnset.mat'],"time","IP","IN","CP","CN")
% 
rmpath(eegLabFolder)
rmpath(dataPath)
rmpath(unfoldFolder)
rmpath([unfoldFolder,filesep,'gramm'])
rmpath(saveFolder)
rmpath(behavDataFolder)