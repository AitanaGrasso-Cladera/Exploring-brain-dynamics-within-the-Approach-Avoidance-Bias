%% Doing linear mixed model
%dataFolder = [];
%plotFolder = [];

addpath(dataFolder)
addpath(plotFolder)
%% What are you working on?
descriptives = 1;
inferential = 1;
%% Load the data
load('transformedDataLog10.mat')
load('errorTrials.mat','minus90Cong','minus90Incong')
%% Descriptive statistics
if descriptives
   % Central tendency
   meanCP_perParticipant = mean(congPosRT,'omitnan');
   meanCP = mean(congPosRT,'all','omitnan');
   
   meanCN_perParticipant = mean(congNegRT,'omitnan');
   meanCN = mean(congNegRT,'all','omitnan');
   
   meanIP_perParticipant = mean(incongPosRT,'omitnan');
   meanIP = mean(incongPosRT,'all','omitnan');
   
   meanIN_perParticipant = mean(incongNegRT,'omitnan');
   meanIN = mean(incongNegRT,'all','omitnan');
   
   % Plotting
   [cb] = cbrewer2('qual','Set3',12,'pchip');
   figure(1)
   subplot(2,2,1)
   h = raincloud_plot(meanCP_perParticipant,'box_on',1,'box_dodge_amount',...
       0,'dot_dodge_amount',.3,'color',cb(1,:),'cloud_edge_col',cb(1,:));
   title('Congruent - Positive (Reaction Times)')
   xlabel('Reaction Time')
   box off
   
   subplot(2,2,2)
   h = raincloud_plot(meanCN_perParticipant,'box_on',1,'box_dodge_amount',...
       0,'dot_dodge_amount',.3,'color',cb(3,:),'cloud_edge_col',cb(3,:));
   title('Congruent - Negative (Reaction Times)')
   xlabel('Reaction Time')
   box off
   
   subplot(2,2,3)
   h = raincloud_plot(meanIP_perParticipant,'box_on',1,'box_dodge_amount',...
       0,'dot_dodge_amount',.3,'color',cb(6,:),'cloud_edge_col',cb(6,:));
   title('Incongruent - Positive (Reaction Times)')
   xlabel('Reaction Time')
   box off
   
   subplot(2,2,4)
   h = raincloud_plot(meanIN_perParticipant,'box_on',1,'box_dodge_amount',...
       0,'dot_dodge_amount',.3,'color',cb(9,:),'cloud_edge_col',cb(9,:));
   title('Incongruent - Negative (Reaction Times)')
   xlabel('Reaction Time')
   box off
   
   print([plotFolder,filesep,'RTcomparison.png'], '-dpng', '-r400');
end
%% Linear Mixed Model
if inferential
    % Remove participants with performance under 90%
    toExclude = unique(cat(1,minus90Cong,minus90Incong));
    congPosRT(:,toExclude(2)) = [];
    congPosRT(:,toExclude(1)) = [];
    congPosPic(:,toExclude(2)) = [];
    congPosPic(:,toExclude(1)) = [];
    
    congNegRT(:,toExclude(2)) = [];
    congNegRT(:,toExclude(1)) = [];
    congNegPic(:,toExclude(2)) = [];
    congNegPic(:,toExclude(1)) = [];
    
    incongPosRT(:,toExclude(2)) = [];
    incongPosRT(:,toExclude(1)) = [];
    incongPosPic(:,toExclude(2)) = [];
    incongPosPic(:,toExclude(1)) = [];
    
    incongNegRT(:,toExclude(2)) = [];
    incongNegRT(:,toExclude(1)) = [];
    incongNegPic(:,toExclude(2)) = [];
    incongNegPic(:,toExclude(1)) = [];
    % Get the number of valid trials per condition 
    nValidCP = sum(~isnan(congPosRT));
    nValidCN = sum(~isnan(congNegRT));
    nValidIP = sum(~isnan(incongPosRT));   
    nValidIN = sum(~isnan(incongNegRT));
    
    colCP = congPosRT(:);
    colCN = congNegRT(:);
    colIP = incongPosRT(:);
    colIN = incongNegRT(:);
    
    CongruentPositive = colCP(~isnan(colCP));
    CongruentNegative = colCN(~isnan(colCN));
    IncongruentPositive = colIP(~isnan(colIP));
    IncongruentNegative = colIN(~isnan(colIN));
    % Generate matrix for reaction times
    reactionTime = [CongruentPositive;CongruentNegative;IncongruentPositive;IncongruentNegative];
    
    colPicCP = congPosPic(:);
    colPicCN = congNegPic(:);
    colPicIP = incongPosPic(:);
    colPicIN = incongNegPic(:);
   
    CongruentPositivePic = colPicCP(~isnan(colPicCP));
    CongruentNegativePic = colPicCN(~isnan(colPicCN));
    IncongruentPositivePic = colPicIP(~isnan(colPicIP));
    IncongruentNegativePic = colPicIN(~isnan(colPicIN));
    
    pictureSequence = [CongruentPositivePic;CongruentNegativePic;IncongruentPositivePic;IncongruentNegativePic];
    
    conditionLabel = [repmat(1,length(CongruentPositive),1);repmat(1,length(CongruentNegative),1);...
        repmat(-1,length(IncongruentPositive),1);repmat(-1,length(IncongruentNegative),1)];
    
    valenceLabel = [repmat(1,length(CongruentPositive),1);repmat(-1,length(CongruentNegative),1);...
        repmat(1,length(IncongruentPositive),1);repmat(-1,length(IncongruentNegative),1)];
    
    % Participant label
    participantCP = {};
    for i = 1:length(nValidCP)
        repeat = repmat({sprintf('Participant %d',i)},nValidCP(i),1);
        participantCP = [participantCP;repeat];
    end
    participantCN = {};
    for i = 1:length(nValidCN)
        repeat = repmat({sprintf('Participant %d',i)},nValidCN(i),1);
        participantCN = [participantCN;repeat];
    end
    participantIP = {};
    for i = 1:length(nValidIP)
        repeat = repmat({sprintf('Participant %d',i)},nValidIP(i),1);
        participantIP = [participantIP;repeat];
    end
    participantIN = {};
    for i = 1:length(nValidCP)
        repeat = repmat({sprintf('Participant %d',i)},nValidIN(i),1);
        participantIN = [participantIN;repeat];
    end
    % Generate matrix for participants
    participantID = [participantCP;participantCN;participantIP;participantIN];
    
    % Set variables to categorical and add Effect Codding
    participantID = categorical(participantID);
    pictureSequence = categorical(pictureSequence);
    
    
    DATA = table(reactionTime,valenceLabel,conditionLabel,pictureSequence,participantID,'VariableNames',...
        {'ReactionTime','Valence','Condition','Picture','Participant'});
    
    glme = fitglme(DATA,'ReactionTime ~ Valence*Condition + (1 | Participant) + (1 | Picture)','Distribution',...
        'Normal','Link','Identity');
    
    % Plot the table
    % Get the table in string form.
    TString = evalc('disp(glme)');
    % Use TeX Markup for bold formatting and underscores.
    TString = strrep(TString,'<strong>','\bf');
    TString = strrep(TString,'</strong>','\rm');
    TString = strrep(TString,'_','\_');
    % Get a fixed-width font.
    FixedWidth = get(0,'FixedWidthFontName');
    % Output the table using the annotation command.
    annotation(gcf,'Textbox','String',TString,'Interpreter','Tex',...
        'FontName',FixedWidth,'Units','Normalized','Position',[0 0 1 1]);
    
    print([plotFolder,filesep,'resultsGLME.png'], '-dpng', '-r400');
    
    % Residual plot
    residualValues = residuals(glme);
    fittedValues = fitted(glme);
    
    % Plot residuals and fitted values
    figure(3)
    subplot(2,2,[1,2])
    scatter(fittedValues,residualValues)
    xlabel('Fitted Values')
    ylabel('Residuals')
    title('Residual Plot')
    
    subplot(2,2,3)
    histogram(residualValues)
    title('Residuals')
    
    subplot(2,2,4)
    histogram(fittedValues)
    title('Fitted Values')
    
    print([plotFolder,filesep,'residual_fitted.png'], '-dpng', '-r400');
end

%% Compute effect size
betas = glme.Coefficients.Estimate;
SEs = glme.Coefficients.SE;
beta_effect = betas(3);
SE_effect = SEs(3); 
effect_size = beta_effect/SE_effect;
% Display the effect size
disp(['Effect size (Cohen''s d): ', num2str(effect_size)]);

rmpath(dataFolder)
rmpath(plotFolder)










