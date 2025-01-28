%% PREPROCESSING BEHAVIORAL DATA
%dataFolder = [];
%saveFolder = [];

if ~exist(saveFolder,'dir')
    mkdir(saveFolder)
end

addpath(dataFolder)
addpath(saveFolder)
%% Get files in folder
tmp = dir(fullfile(dataFolder));
participants = [];
inx = 1;

for pId = 1:size(tmp,1)
    if tmp(pId).name(1) == '.' || ~contains(tmp(pId).name,'SUB') || contains(tmp(pId).name,'._')
        continue
    else
        participants(inx).name = tmp(pId).name;
        participants(inx).folder = tmp(pId).folder;
        participants(inx).date = tmp(pId).date;
        inx = inx + 1;
    end
end
clear tmp
%% Run preprocessing
filesInFolder = dir(fullfile(participants(1).folder,'*.mat'));
filesInFolder = filesInFolder(44:end);
% Define parameters
firstTrial = 41;
nTrials = 88;
nMuscle = 40;
subjectsData = [];
for pIx = 1:size(filesInFolder,1)
    
    load(filesInFolder(pIx).name);
    
    subjectsData.age(pIx,:) = obj.age;
    subjectsData.gender(pIx,:) = {obj.gender};
    subjectsData.hand(pIx,:) = {obj.hand};
    
    subjectsData.pictureSequence(:,pIx) = obj.sequence(firstTrial:end);
    subjectsData.correctReaction(:,pIx) = obj.correct_reaction(firstTrial:end);
    subjectsData.actualReaction(:,pIx) = obj.actual_reaction(firstTrial:end);
    subjectsData.reactionTime(:,pIx) = obj.r_time(firstTrial:end);
    
    if obj.block_order == 'a'
        subjectsData.blockOrder(:,pIx) = 1; % Congruent - Incongruent
    elseif obj.block_order == 'b'
        subjectsData.blockOrder(:,pIx) = 2; % Incongruent - Congruent
    elseif obj.block_order == 'c'
        subjectsData.blockOrder(:,pIx) = 3; % Congruent - Incongruent
    elseif obj.block_order == 'd'
        subjectsData.blockOrder(:,pIx) = 4; % Incongruent - Congruent
    end
    subjectsData.blockLabel = {'1 and 3 = Congruent - Incongruent'; '2 and 4 = Incongruent - Congruent'};

    
    if subjectsData.blockOrder(:,pIx) == 1 || subjectsData.blockOrder(:,pIx) == 3 % First 44 are Congruent
        subjectsData.congruent.pictureSequence(:,pIx) = subjectsData.pictureSequence(1:nTrials/2,pIx);
        subjectsData.congruent.correctReaction(:,pIx) = subjectsData.correctReaction(1:nTrials/2,pIx);
        subjectsData.congruent.actualReaction(:,pIx) = subjectsData.actualReaction(1:nTrials/2,pIx);
        subjectsData.congruent.reactionTime(:,pIx) = subjectsData.reactionTime(1:nTrials/2,pIx);
        
        subjectsData.incongruent.pictureSequence(:,pIx) = subjectsData.pictureSequence(((nTrials/2)+1):nTrials,pIx);
        subjectsData.incongruent.correctReaction(:,pIx) = subjectsData.correctReaction(((nTrials/2)+1):nTrials,pIx);
        subjectsData.incongruent.actualReaction(:,pIx) = subjectsData.actualReaction(((nTrials/2)+1):nTrials,pIx);
        subjectsData.incongruent.reactionTime(:,pIx) = subjectsData.reactionTime(((nTrials/2)+1):nTrials,pIx);
    elseif subjectsData.blockOrder(:,pIx) == 2 || subjectsData.blockOrder(:,pIx) == 4 % First 44 are Incongruent
        subjectsData.incongruent.pictureSequence(:,pIx) = subjectsData.pictureSequence(1:nTrials/2,pIx);
        subjectsData.incongruent.correctReaction(:,pIx) = subjectsData.correctReaction(1:nTrials/2,pIx);
        subjectsData.incongruent.actualReaction(:,pIx) = subjectsData.actualReaction(1:nTrials/2,pIx);
        subjectsData.incongruent.reactionTime(:,pIx) = subjectsData.reactionTime(1:nTrials/2,pIx);
        
        subjectsData.congruent.pictureSequence(:,pIx) = subjectsData.pictureSequence(((nTrials/2)+1):nTrials,pIx);
        subjectsData.congruent.correctReaction(:,pIx) = subjectsData.correctReaction(((nTrials/2)+1):nTrials,pIx);
        subjectsData.congruent.actualReaction(:,pIx) = subjectsData.actualReaction(((nTrials/2)+1):nTrials,pIx);
        subjectsData.congruent.reactionTime(:,pIx) = subjectsData.reactionTime(((nTrials/2)+1):nTrials,pIx);
    end
    
    % Get all the data related to muscle trials
    if subjectsData.blockOrder(:,pIx) == 1 || subjectsData.blockOrder(:,pIx) == 3 % First 20 are Pushing
        subjectsData.pushing.correctReaction(:,pIx) = subjectsData.correctReaction(1:nMuscle/2,pIx);
        subjectsData.pushing.actualReaction(:,pIx) = subjectsData.actualReaction(1:nMuscle/2,pIx);
        subjectsData.pushing.reactionTime(:,pIx) = subjectsData.actualReaction(1:nMuscle/2,pIx);
        
        subjectsData.pulling.correctReaction(:,pIx) = subjectsData.correctReaction(((nMuscle/2)+1):nMuscle,pIx);
        subjectsData.pulling.actualReaction(:,pIx) = subjectsData.actualReaction(((nMuscle/2)+1):nMuscle,pIx);
        subjectsData.pulling.reactionTime(:,pIx) = subjectsData.reactionTime(((nMuscle/2)+1):nMuscle,pIx);
    elseif subjectsData.blockOrder(:,pIx) == 2 || subjectsData.blockOrder(:,pIx) == 4 % First 20 are Pulling
        subjectsData.pulling.correctReaction(:,pIx) = subjectsData.correctReaction(1:nMuscle/2,pIx);
        subjectsData.pulling.actualReaction(:,pIx) = subjectsData.actualReaction(1:nMuscle/2,pIx);
        subjectsData.pulling.reactionTime(:,pIx) = subjectsData.actualReaction(1:nMuscle/2,pIx);
      
        subjectsData.pushing.correctReaction(:,pIx) = subjectsData.correctReaction(((nMuscle/2)+1):nMuscle,pIx);
        subjectsData.pushing.actualReaction(:,pIx) = subjectsData.actualReaction(((nMuscle/2)+1):nMuscle,pIx);
        subjectsData.pushing.reactionTime(:,pIx) = subjectsData.reactionTime(((nMuscle/2)+1):nMuscle,pIx);
    end
end
% Save the data
save(fullfile(saveFolder,'behavioralData'),'subjectsData')

rmpath(dataFolder)
rmpath(saveFolder)













