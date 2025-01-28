%% What are you working on?
step1 = 0;
step2 = 0;
step3 = 0;
step4 = 0;
step5 = 1;
%% Paths
%root = [];
%eegLab = [];
chanLocsName = 'chanLocs.mat';
projectFolder = root;
if step1
    dataFolder = [root,filesep,'RAW_DATA'];
    saveFolder = [projectFolder,filesep,'Step_1'];
elseif step2
    dataFolder = [projectFolder,filesep,'Step_1'];
    saveFolder = [projectFolder,filesep,'Step_2'];
elseif step3
    dataFolder = [projectFolder,filesep,'Step_2'];
    saveFolder = [projectFolder,filesep,'Step_3',filesep,'noBurst'];
elseif step4
    dataFolder = [projectFolder,filesep,'Step_3',filesep,'noBurst'];
    saveFolder = [projectFolder,filesep,'Step_4',filesep,'noBurst'];
elseif step5
    dataFolder = [projectFolder,filesep,'Step_4',filesep,'noBurst'];
    saveFolder = [projectFolder,filesep,'Step_5',filesep,'noBurst'];
end
addpath(root)
addpath(dataFolder)
addpath(eegLab)
%% Save Folder
if ~exist(saveFolder)
    mkdir(saveFolder);
end
%% Information about files
tmp = dir(fullfile(dataFolder));
participants = [];
inx = 1;
for pId = 1:size(tmp,1)
    if tmp(pId).name(1) == '.' || ~contains(tmp(pId).name,'.set')
        continue
    else
        participants(inx).name = tmp(pId).name;
        participants(inx).folder = tmp(pId).folder;
        participants(inx).date = tmp(pId).date;
        inx=inx+1;
    end
end
folderName = participants(1).folder;
files2load = participants;
%% Step 1: Removing non-empirical data, electrode renaming and rejection of empty channels
eeglab
load(chanLocsName)
for fIx = 1:size(files2load,2)
    thisFile = [participants(fIx).folder,filesep,participants(fIx).name];
    EEGOUT = pop_loadeep_v4(thisFile);
    if fIx == size(files2load,2)
        EEGOUT.setname = 'EEG_AAT_SUB029';
    else
        EEGOUT.setname = participants(fIx).name(1:end-4);
    end
    EEGOUT.filepath = files2load(fIx).folder;
    % Get channel names and the ones to remove (in this case, all non brain channels)
    channels = {EEGOUT.chanlocs.labels};
    bipChans = find(contains(channels, 'BIP'));
    auxChans = find(contains(channels, 'AUX'));
    chans2remove = [bipChans,auxChans];
    EEGOUT = pop_select(EEGOUT,'nochannel',chans2remove);
    EEGOUT.chanlocs = chanLocs;
    % Get the time from the start and end of the task
    eventMark = {EEGOUT.event.type}';
    taskStart = find(strcmp(eventMark, '200'));
    taskEnd = find(strcmp(eventMark, '255'));
    EEGOUT.srate = 512;
    if length(taskStart) > 1
        taskStart = taskStart(2,1);
    end
    if length(taskEnd) > 1
        taskEnd = taskEnd(2,1);
    end
    % Remove non experimental portions of the data
    EEGOUT = pop_select(EEGOUT,'point',EEGOUT.event(taskStart).latency:EEGOUT.event(taskEnd).latency);
    EEGOUT = eeg_checkset(EEGOUT);
    EEGOUT.etc.Step_1 = 'Channel locations addedd. Non-empirical data removed. Rejection empty channels.';
    % save the data: always add an 'a' behind the number of automated
    EEGOUT = pop_saveset(EEGOUT, 'filename',sprintf('1a_rawChanNames_%s',EEGOUT.setname),'filepath',fullfile(saveFolder));
    clear eventMark
    clear taskStart
    clear taskEnd
end
rmpath(dataFolder)
%% Step 2: Filtering the data
% Filter the data parameters adapted from Czeszumski, 2023 (Hyperscanning
% Maastricht)
lowPass = 128; 
highPass = .5;
for fIx = 1:size(files2load,2)
    EEGOUT = pop_loadset([files2load(fIx).folduf_continuousArtifactExcludeer,filesep,files2load(fIx).name]);
    EEGOUT.filepath = files2load(fIx).folder;
    EEGOUT = pop_eegfiltnew(EEGOUT, highPass, []); % 0.5 is the lower edge
    EEGOUT = pop_eegfiltnew(EEGOUT, [], lowPass); % 128 is the upper edge
    % Lower sampling rate from 1024Hz to 512Hz 
    % EEG = pop_resample(EEG, 512); - In the original NBP pipeline, but
    % ZapLine recommends 500 Hz for optimal functioning
    EEGOUT = pop_resample(EEGOUT, 500);
    % Remove line noise with zapline
    zaplineConfig = [];
    zaplineConfig.noisefreqs = 49.97:.01:50.03; %Alternative: 'line'
    zaplineConfig.plotResults = 0;
    EEGOUT = clean_data_with_zapline_plus_eeglab_wrapper(EEGOUT,zaplineConfig); 
    EEGOUT.etc.zapline
    
    EEGOUT = eeg_checkset(EEGOUT);
    EEGOUT.etc.Step_2 = 'Filtering the data and applying Zapline.';
    EEGOUT = pop_saveset(EEGOUT, 'filename',sprintf('2a_filtering_%s',EEGOUT.setname),'filepath',fullfile(saveFolder));
end
rmpath(dataFolder)
%% Step 3: Channel removal, data cleaning
eeglab
for fIx = 1:size(files2load,2)
    EEGOUT = pop_loadset([files2load(fIx).folder,filesep,files2load(fIx).name]);
    EEGOUT.setname = [files2load(fIx).name(1:end-14),'_resampled'];
    EEGOUT.filename = EEGOUT.setname;
    EEGOUT.filepath = files2load(fIx).folder;
    fullChanlocs = EEGOUT.chanlocs;
    % Compute average reference
    EEGOUT = pop_reref(EEGOUT,[]);
    BUR = EEGOUT;
    % Clean data using the clean_rawdata plugin
    EEGOUT = pop_clean_rawdata(EEGOUT,'BurstCriterion',20);
    % Recompute average reference
    EEGOUT = pop_reref(EEGOUT,[]);
    Zr = find(EEGOUT.etc.clean_sample_mask == 0); % Find all rejected elements
    if ~isempty(Zr)
        starts = Zr(1);
        ends = [];
        for z = 2:length(Zr)
            if Zr(z-1) + 1 ~= Zr(z)
                starts = [starts, Zr(z)];
                ends = [ends, Zr(z-1)];
            end
        end
        ends = [ends, Zr(z)];
        tmprej = [starts;ends]'; % Save the noisy segments (beginning & end)
        % Save the removed intervals
        save(fullfile(saveFolder,sprintf('removed_intervals_%s.mat',EEGOUT.setname(22:27))),'tmprej');
    end
    % Save removed channels
    removedChannels = ~ismember({fullChanlocs.labels},{EEGOUT.chanlocs.labels});
    EEGOUT.removedChannels = {fullChanlocs(removedChannels).labels};
    % Save the removed channels
    save(fullfile(saveFolder,sprintf('removed_channels_%s.mat',EEGOUT.setname(22:27))),'removedChannels');
    % Save the data: always add an 'a' behind the number of automated
    EEGOUT.etc.Step_3 = 'Data cleaning and channel removal.';
    EEGOUT = eeg_checkset(EEGOUT);
    EEGOUT = pop_saveset(EEGOUT, 'filename',sprintf('3a_cleanDataChannels_%s',EEGOUT.setname(22:27)),'filepath',fullfile(saveFolder));
    % save the data without the time interval rejection (for Unfold)
    BUR = pop_select(BUR, 'nochannel', EEGOUT.removedChannels);
    BUR = eeg_checkset(BUR);
    BUR.etc.Step_3 = 'Channel removal, no time interval rejection.';
    BUR = pop_saveset(BUR, 'filename',sprintf('3a_cleanDataChannels_noRejection_%s',EEGOUT.setname(22:27)),'filepath',fullfile(saveFolder));
end
rmpath(dataFolder)
%% Step 4: ICA
%eeglab
for fIx = 32:size(files2load,2)
    EEGOUT = pop_loadset([files2load(fIx).folder,filesep,files2load(fIx).name]);
    EEGOUT.setname = ['4a_ICA_',files2load(fIx).name(22:end-4),'.set'];
    EEGOUT.filepath = files2load(fIx).folder;
    % Highpass-filter the data at 2 Hz to not include slow drifts in the ICA
    tmp = pop_eegfiltnew(EEGOUT, 2, []);
    dataRank = rank(double(tmp.data'));
    ICAfolder = [saveFolder,filesep,['ICA_',EEGOUT.setname(8:end-4)]];
    if ~exist(ICAfolder,'dir')
        mkdir(ICAfolder);
    end
    runamica15(tmp.data,'num_chans',tmp.nbchan,'outdir',ICAfolder,... 
        'numprocs',1,'max_threads',8,'pcakeep',dataRank,'num_models',1);
    mod = loadmodout15(ICAfolder);
    % Apply ICA weights to data
    EEGOUT.icasphere = mod.S;
    EEGOUT.icaweights = mod.W;
    EEGOUT.icawinv = [];
    EEGOUT.icaact = [];
    EEGOUT.icachansind = [];
    EEGOUT = eeg_checkset(EEGOUT);
    % Use iclabel to determine which ICs to reject
    EEGOUT = iclabel(EEGOUT);
    % List components that should be rejected
    components2remove = [];
    for component = 1:length(EEGOUT.chanlocs)-1
        % Muscle
        if EEGOUT.etc.ic_classification.ICLabel.classifications(component,2) > .80
            components2remove = [components2remove component];
        end
        % Eye
        if EEGOUT.etc.ic_classification.ICLabel.classifications(component,3) > .9
            components2remove = [components2remove component];
        end
        % Heart
        if EEGOUT.etc.ic_classification.ICLabel.classifications(component,4) > .9
            components2remove = [components2remove component];
        end
        % Line noise
        if EEGOUT.etc.ic_classification.ICLabel.classifications(component,5) > .9
            components2remove = [components2remove component];
        end
        % Channel noise
        if EEGOUT.etc.ic_classification.ICLabel.classifications(component,6) > .9
            components2remove = [components2remove component];
        end
    end      
    % Remove components
    EEGOUT = pop_subcomp(EEGOUT, components2remove, 0);
    % Save removed components in struct
    EEGOUT.removedComponents = components2remove;
    % Save the removed components
    save(fullfile(saveFolder,sprintf('removed_components_%s.mat',EEGOUT.setname)),'components2remove');
    EEGOUT.etc.Step_4 = 'ICA.';
    EEGOUT = eeg_checkset(EEGOUT);
    EEGOUT = pop_saveset(EEGOUT, 'filename',sprintf('4a_ICA_%s',EEGOUT.setname),'filepath',fullfile(saveFolder));
end
rmpath(dataFolder)
%% Step 5: Interpolating missing channels
for fIx = 1:(size(files2load,2)/2)
    EEGOUT = pop_loadset([files2load(fIx).folder,filesep,files2load(fIx).name]);
    % Get all channels that need to be interpolated
    EEGchan = pop_loadset(sprintf('2a_filtering_EEG_AAT_%s resampled.set',EEGOUT.setname(8:13)),fullfile([projectFolder,filesep,'Step_2'])); % this needs to change format
    fullChanlocs = EEGchan.chanlocs; % Used for data cleaning and interpolation
    clear EEGchan
    EEGOUT = pop_interp(EEGOUT,fullChanlocs,'spherical');
    EEGOUT = eeg_checkset(EEGOUT);
    % check if duplicate channel label
    if isfield(EEGOUT.chanlocs, 'labels')
        if length({ EEGOUT.chanlocs.labels}) > length(unique({EEGOUT.chanlocs.labels}))
            disp('Warning: some channels have the same label');
        end
    end
    % Save the results
    EEGOUT = eeg_checkset(EEGOUT);
    EEGOUT = pop_saveset(EEGOUT, 'filename',sprintf('5a_interpolation_%s',EEGOUT.setname(8:13)),'filepath',fullfile(saveFolder));
end
rmpath(dataFolder)
rmpath(root)