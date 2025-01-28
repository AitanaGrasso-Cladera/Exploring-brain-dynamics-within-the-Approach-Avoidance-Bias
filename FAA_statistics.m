%% FAA Statistics
%% First for F4-F3
load('January_allMeasures_PicOnset.mat','congNegF3','congNegF4','congPosF3','congPosF4',...
    'incongNegF3','incongNegF4','incongPosF3','incongPosF4')

positiveF3 = [congPosF3;incongPosF3];
positiveF4 = [congPosF4;incongPosF4];
negativeF3 = [congNegF3;incongNegF3];
negativeF4 = [congNegF4;incongNegF4];

positive = positiveF4 - positiveF3;
negative = negativeF4 - negativeF3;

[h,p,stats] = signrank(positive,negative);

clear all
%% Now for the average over electrodes
load('January_allMeasures_PicOnset.mat','congNegRight','congNegLeft','congPosRight','congPosLeft',...
    'incongNegRight','incongNegLeft','incongPosRight','incongPosLeft')

positiveRight = [congPosRight;incongPosRight];
positiveLeft = [congPosLeft;incongPosLeft];
negativeRight = [congNegRight;incongNegRight];
negativeLeft = [congNegLeft;incongNegLeft];

positive = positiveRight - positiveLeft;
negative = negativeRight - negativeLeft;

[p,h,stats] = signrank(positive,negative);