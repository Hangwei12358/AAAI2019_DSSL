% generate group indices of test/labeled/unlabeled data
% inductive setting
% by Hangwei, 19-Sep-2017 16:42:51
clear all
clc
load('wisdm_1.mat');
addpath(genpath(pwd)); % helpful for using libsvmwrite in the main path instead of adding them to all subfolders
ParentPath = pwd;
allDataChunk = leftChunk; 
rng('default');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% the parameters that may need to change
testRatio = 0.2;
unLabRatio = 0.2;
ratio_lab_all = 1- testRatio - unLabRatio;
labRatio_inside = 0.02; % this number should be vary
labRatio = ratio_lab_all * labRatio_inside; 
semi_ratio_all = [labRatio unLabRatio testRatio]; % proportion for labeled/unlabeled/test data
numRuns = 6;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
numClass = length(allLabels);
% get the size of different classes
allDataLabels = cell2mat(allDataChunk(:, 2));
for i = 1:length(allLabels)
    numEntrySet(i, 1) = length(find(allDataLabels == allLabels(i, 1)));
end
% codes for semi-supervised learning, 18-Aug-2017 13:40:02

nowRatio = unLabRatio + labRatio + testRatio;
nowRatio_str = num2str(nowRatio);
semi_ratio = cell(1,1);
for i = 1:numClass
    numEntry = numEntrySet(i);
    numTrainEntry = ceil(numEntry * nowRatio);
    trainEntry1 = randperm(numEntry, numTrainEntry); % select the subjects as train subjects
    trainEntry2 = randperm(numEntry, numTrainEntry); % select the subjects as train subjects
    trainEntry3 = randperm(numEntry, numTrainEntry); % select the subjects as train subjects
    trainEntry4 = randperm(numEntry, numTrainEntry); % select the subjects as train subjects
    trainEntry5 = randperm(numEntry, numTrainEntry); % select the subjects as train subjects
    trainEntry6 = randperm(numEntry, numTrainEntry); % select the subjects as train subjects
    trainEntrySemi = [trainEntry1; trainEntry2; trainEntry3; trainEntry4; trainEntry5; trainEntry6];
    semi_ratio{i, 1} = trainEntrySemi; %%%% {numClass} * {numRuns}
end
toSaveFile = strcat('semi_ratio_', nowRatio_str, '.mat');
save(toSaveFile,'semi_ratio');
save('semi_ratio_all.mat','semi_ratio_all','labRatio_inside','numEntrySet','numRuns');

