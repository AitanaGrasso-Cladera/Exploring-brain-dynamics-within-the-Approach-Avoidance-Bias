%% Compute ERPs and Power for analyses
%dataFolder = [];
%saveFolder = [];

if ~exist(saveFolder,'dir')
    mkdir(saveFolder)
end
addpath(dataFolder)
addpath(saveFolder)
%% Get information about files
participants = [];
tmp = dir(fullfile(dataFolder));
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
% Channel numbers:
% AF3 = 43
% F5 = 37
% F1 = 38
% F3 = 5
% FC3 = 41
% FC5 = 9
% FC1 = 10
% AF4 = 35
% F2 = 39
% F6 = 40
% F4 = 7
% FC2 = 11
% FC4 = 44
% FC6 = 12
chans2work = [43,37,38,5,41,9,10,35,39,40,7,11,44,12];
freqs = [2,50,70];
sr = 500;
window = hamming(500);
noverlap = 250; % 50% overlap
nfft = 1024; % Number of FFT points
baselineTime = [-500 -200];
lin = 0;
%% Compute ERPs and Power
for pIx = 1:size(participants,2)
    thisFile = [dataFolder,filesep,participants(pIx).name];
    EEG = pop_loadset(thisFile);
    [TFpower,rawTFpower,~,channelID,frequencies,timeVector,measureInfo] = Compute_TFpower(EEG,...
        chans2work,freqs,1,baselineTime,1,0);
    start = find(EEG.times == 0);
    eeg_signal = EEG.data(:,start:end,:); % EEG data after event onset
    [n_channels,n_samples,n_epochs] = size(eeg_signal);

    % Preallocate space for PSD across epochs
    pxx_all = zeros(nfft/2+1,n_epochs);

    % Loop through each channel
    for i = 1:length(chans2work)
        % Loop through each epoch
        for epoch = 1:n_epochs
            % Get the current epoch (assuming single-channel analysis; adjust for multi-channel if needed)
            eeg_epoch = eeg_signal(chans2work(i),:,epoch); 

            % Compute PSD for the current epoch
            [pxx, f] = pwelch(eeg_epoch,window,noverlap,nfft,sr);

            % Store the PSD
            pxx_all(:, epoch) = pxx;
        end
        ALL(i,:,:) = pxx_all;
    end
    %% Compute FAA only for F3 - F4
    % Average PSD across epochs
    pxx_avgF3 = squeeze(mean(ALL(4,:,:),3));
    pxx_avgF4 = squeeze(mean(ALL(11,:,:),3));
    % Extract alpha power (8–12 Hz)
    alpha_range = (f >= 8 & f <= 12);
    alpha_powerF3 = trapz(f(alpha_range),pxx_avgF3(alpha_range)); % Integrate PSD over alpha range for F3
    alpha_powerF4 = trapz(f(alpha_range),pxx_avgF4(alpha_range)); % Integrate PSD over alpha range for F4
    % Computing natural log
    logAlphaF3 = log(alpha_powerF3);
    logAlphaF4 = log(alpha_powerF4);
    %% Compute FAA averaging for left and right
    % Average PSD across epochs
    pxx_avgRight = squeeze(mean(ALL(1:7,:,:),3));
    pxx_avgLeft = squeeze(mean(ALL(8:14,:,:),3));
    % Average over channels
    pxx_avgRight = mean(pxx_avgRight,1);
    pxx_avgLeft = mean(pxx_avgLeft,1);
    % Extract alpha power
    alpha_powerRight = trapz(f(alpha_range),pxx_avgRight(alpha_range)); % Integrate PSD over alpha range for Right
    alpha_powerLeft = trapz(f(alpha_range),pxx_avgLeft(alpha_range)); % Integrate PSD over alpha range for Left
    % Computing natural log
    logAlphaRight = log(alpha_powerRight);
    logAlphaLeft = log(alpha_powerLeft);
    %%
    ERP = mean(EEG.data,3);
    fprintf('Saving file... %s with ERP and TF computation\n',[participants(pIx).name(1:end-4),'.mat']);
    %save([saveFolder,filesep,participants(pIx).name(1:end-4),'.mat'],'logAlphaF3','logAlphaF4','logAlphaRight','logAlphaLeft','ERP','EEG','-v7.3')
    clear ALL
end
%% Remove path
rmpath(dataFolder)
rmpath(saveFolder)
