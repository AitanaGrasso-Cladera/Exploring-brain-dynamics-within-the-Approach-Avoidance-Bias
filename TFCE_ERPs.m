%% Compute TFCE for ERPs
% dataFolder = [];
% eegDataFolder = [];
% saveFolder = [];
% plottingFolder = [];

if ~exist(saveFolder,'dir')
    mkdir(saveFolder)
elseif ~exist(plottingFolder,'dir')
    mkdir(plottingFolder)
end
addpath(dataFolder)
addpath(eegDataFolder)
addpath(saveFolder)
addpath(plottingFolder)
addpath(TFCEfolder)
addpath(EEGLABfolder)
%% Load the ERP data
load([dataFolder,filesep,'unfoldResults_January_PicOnset.mat'],'CN','CP','IN','IP','time')
EEG = pop_loadset([eegDataFolder,filesep,'SUB001_CongNeg.set']);
chanLocs = EEG.chanlocs;
clear EEG
%% Format the data data
Data{1,1} = double(CP);
Data{1,2} = double(CN);
Data{2,1} = double(IP);
Data{2,2} = double(IN);
%% Set random stream depending on the clock value
myRand = RandStream('mt19937ar','Seed',sum(100*clock));
RandStream.setGlobalStream(myRand);

nP = cell2mat(cellfun(@(x) size(x,1), Data, 'UniformOutput', false)); 

display ('Checking Data...')
if numel(unique(nP)) > 1
    error('All datsets must have the same number of participants (Balanced Design)');
end

nP   = unique(nP);
nCh  = size(Data{1},2);
nS   = size(Data{1},3);

% Error Checking
if ~isequal(nCh, length(chanLocs))
    error ('Number of channels in data does not equal that of locations file')
end
display ('Done.')
%% Calculate the channels neighbours using the modified version ChN2
display ('Calculating Channel Neighbours...')
ChN = ept_ChN2(chanLocs);
display ('Done.')
%% Define parameters
nPerm = 10000;
E_H = [0.666, 1];
alpha = 0.05;
%% Create all variables in loop at their maximum size to increase performance
maxTFCE.A  = zeros(nPerm,1);
maxTFCE.B  = zeros(nPerm,1);
maxTFCE.AB = zeros(nPerm,1);
%% Calculate the actual T values of all data
% Calculate different T-values for mixed and repeated measures ANOVA
display ('Calculating Observed Statistics...')

F_Obs = ept_rmANOVA(Data);

TFCE_Obs.A  = ept_mex_TFCE2D(F_Obs.A,  ChN, E_H);
TFCE_Obs.B  = ept_mex_TFCE2D(F_Obs.B,  ChN, E_H);
TFCE_Obs.AB = ept_mex_TFCE2D(F_Obs.AB, ChN, E_H);
display ('Done.')
%% Calculating the T value and TFCE enhancement of each different permutation
display ('Calculating Permutations...')

for i   = 1:nPerm

    F_Perm = ept_rmANOVA(Data,1);

    TFCE_Perm.A  = ept_mex_TFCE2D(F_Perm.A,  ChN, E_H);
    TFCE_Perm.B  = ept_mex_TFCE2D(F_Perm.B,  ChN, E_H);
    TFCE_Perm.AB = ept_mex_TFCE2D(F_Perm.AB, ChN, E_H);

    maxTFCE.A(i)  = max(max(abs(TFCE_Perm.A)));
    maxTFCE.B(i)  = max(max(abs(TFCE_Perm.B)));
    maxTFCE.AB(i) = max(max(abs(TFCE_Perm.AB)));
end

display ('Done.')
%% Calculating the p value from the permutation distribution
display ('Calculating Final Statistics...')

% add observed maximum
edges.A  = [maxTFCE.A;  max(max(abs(TFCE_Obs.A)))];
edges.B  = [maxTFCE.B;  max(max(abs(TFCE_Obs.B)))];
edges.AB = [maxTFCE.AB; max(max(abs(TFCE_Obs.AB)))];

[~,bin.A]      = histc(abs(TFCE_Obs.A),sort(edges.A));
P_Values.A     = 1-bin.A./(nPerm+2);
[~,bin.B]      = histc(abs(TFCE_Obs.B),sort(edges.B));
P_Values.B     = 1-bin.B./(nPerm+2);
[~,bin.AB]     = histc(abs(TFCE_Obs.AB),sort(edges.AB));
P_Values.AB    = 1-bin.AB./(nPerm+2);

display ('Done.')
%% Save the data
Info.Parameters.E_H         = E_H;
Info.Parameters.nPerm       = nPerm;
Info.Parameters.rSample     = 500;
Info.Parameters.type        = 'm';
Info.Parameters.nChannels   = nCh;
Info.Parameters.nSamples    = nS;

Info.Parameters.GroupSizes  = [size(Data{1,1}, 1); size(Data{2,1}, 1)];

Info.Electrodes.e_loc               = chanLocs;
Info.Electrodes.ChannelNeighbours   = ChN;

Results.Obs                 = F_Obs;
Results.TFCE_Obs            = TFCE_Obs;
Results.maxTFCE             = maxTFCE;
Results.P_Values            = P_Values;
Results.TFCE_Perm           = TFCE_Perm;
%% Before, we only looked at the maximum cluster. Now, we want to find all 
% the significant clusters
% Find all indicies of significant clusters
idxSC.A = find(Results.P_Values.A < alpha);
idxSC.B = find(Results.P_Values.B < alpha);
idxSC.AB = find(Results.P_Values.AB < alpha);
% Convert linear indices to row and column subscripts
[Ch.A, S.A] = ind2sub(size(Results.P_Values.A), idxSC.A);
[Ch.B, S.B] = ind2sub(size(Results.P_Values.B), idxSC.B);
[Ch.AB, S.AB] = ind2sub(size(Results.P_Values.AB), idxSC.AB);
% Extract the corresponding p-values
pValuesBelowThreshold.A = Results.P_Values.A(idxSC.A);
pValuesBelowThreshold.B = Results.P_Values.B(idxSC.B);
pValuesBelowThreshold.AB = Results.P_Values.AB(idxSC.AB);
%% Here to display specific characteristics of the maximum and the total number of
% significant clusters
[min_P, ID] = min(Results.P_Values.A(:));
[ChanMax, SMAx]      = ind2sub(size(Results.P_Values.A),ID);
max_Obs      = Results.Obs.A(ID);

if min_P < 0.05
    display(['Peak significance Factor A found at channel ', num2str(ChanMax), ' at sample ', num2str(SMAx), ': T(', num2str(size(Data{1},1)-1), ') = ', num2str(max_Obs), ', p = ', num2str(min_P)]);
    display(['Number of significant clusters Factor A ',num2str(size(idxSC.A,1))])

else
    display('No siginificant clusters found in Factor A!')
end

% FactorB
[min_P, ID] = min(resultsMov.P_Values.B(:));
[ChanMax, SMAx]      = ind2sub(size(resultsMov.P_Values.B),ID);
max_Obs      = resultsMov.Obs.B(ID);

if min_P < 0.05
    display(['Peak significance Factor B found at channel ', num2str(ChanMax), ' at sample ', num2str(SMAx), ': T(', num2str(size(dataMov{1,1},1)-1), ') = ', num2str(max_Obs), ', p = ', num2str(min_P)]);
    display(['Number of significant clusters Factor B ',num2str(size(idxSCMov.B,1))])

else
    display('No siginificant clusters found in Factor B!')
end

% Interaction
[min_P, ID] = min(resultsMov.P_Values.AB(:));
[ChanMax, SMAx]      = ind2sub(size(resultsMov.P_Values.AB),ID);
max_Obs      = resultsMov.Obs.AB(ID);

if min_P < 0.05
    display(['Peak significance Interaction found at channel ', num2str(ChanMax), ' at sample ', num2str(SMAx), ': T(', num2str(size(dataMov{1},1)-1), ') = ', num2str(max_Obs), ', p = ', num2str(min_P)]);
    display(['Number of significant clusters Interaction ',num2str(size(idxSC,1))])

else
    display('No siginificant clusters found in Interaction!')
end

save([saveFolder,filesep,'JANUARY_TFCE_PicOnset_Unfold.mat'],'Info','Results','chanLocs','idxSC','Ch','S','pValuesBelowThreshold','Data')
%%
x = Results.TFCE_Obs.B;
x(Results.P_Values.B>0.05) = 0;
Cp = ept_ClusRes(x,ChN,0.01);
xn = x;
xn(x>0) = 0;
xn = abs(xn);
Cn = ept_ClusRes(xn,ChN,0.01);
C = Cn-Cp;
assignin('base','current_clusters',C);
b = unique(C);
b(b==0) = [];

if numel(b) == 0
    disp(['There are not cluster of significant data at the p = ' num2str(0.05) ' threshold']);
    return
else
    ClusRes = cell(size(b,1),11);
    for i = 1:size(b,1)
        x = Results.TFCE_Obs.B;
        x(C~=b(i))=0;
        idPeak          = find(abs(x)==max(abs(x(:))));
        [PeakC, PeakS]  = ind2sub(size(x),idPeak);
        idSize          = find(C== b(i)); % find the rows and columns that are significant
        [SizeC, SizeS]  = ind2sub(size(C),idSize);
        ClusRes{i,1}    = PeakC(1); % peak channel (just the first of many possible peak channels (but averaging may result in a channel in between two that is not significant)!
        ClusRes{i,2}    = PeakS(1);
        ClusRes{i,3}    = Results.Obs.B(PeakC(1),PeakS(1));
        ClusRes{i,4}    = Results.P_Values.B(PeakC(1),PeakS(1));
        ClusRes{i,5}    = numel(idSize);
        ClusRes{i,6}    = numel(unique(SizeC));
        ClusRes{i,7}    = numel(unique(SizeS));
        ClusRes{i,8}   = [num2str(min(SizeS)), ' - ', num2str(max(SizeS))];
        % electrode:
        ClusRes{i,9}   = chanLocs(PeakC(1)).labels;
        % time interval
        %ClusRes{i,10}   = [num2str(timePic(min(SizeS))), ':', num2str(timePic(max(SizeS))),'ms'];
        % Electrodes of the cluster
        % Preallocate the cell array for performance
        electrodes = cell(1, length(SizeC));

        % Populate the electrodes cell array
        for j = 1:length(SizeC)
            electrodes{j} = chanLocs(SizeC(j)).labels;
        end
        ClusRes{i,11} = unique(electrodes);
    end
    [ClusRes{15,:}] = deal ('idxChan','idx,Time','Fval','pval','nrRowsColSig','nrChan','nrTime','timeIntlIdx','ChanName','timeInterval','channInCluster');
end
