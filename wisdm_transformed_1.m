% deal with raw data
clear all
clc
addpath('/Users/Hangwei/Desktop/DSSL_wisdm/wisdm_transformed_labeled_0.02/Code_Matlab/matlab2weka');
addpath('/home/hangwei/Documents/DataSets/WISDM_ar_v1.1');
addpath(genpath(pwd));

% load weka's .arff format folder into Matlab
myPath = '/home/hangwei/Documents/DataSets/WISDM_ar_v1.1/';
fileDataset = 'WISDM_ar_v1.1_transformed.arff';
javaaddpath('/home/hangwei/Documents/Code_Matlab/weka-3-9-1/weka.jar');
wekaOBJ = loadARFF([myPath fileDataset]);
[data_raw,featureNames,targetNDX,stringVals,relationName] = weka2matlab(wekaOBJ);


% chunk based on labels
[allR, allC] = size(data_raw);

allDataChunk = cell(1, 3);
targetLabelCol = 46; % may be different for different datasets
indFirstFeature = 3;
indLastFeature = 45; 
indSubject = 2;
firstLabel = data_raw(1, targetLabelCol);
chunkInd = 1;
tmpInd = 1;
label_all = [];

for i = 2: allR
    secondLabel = data_raw(i,targetLabelCol);
    if(secondLabel ~= firstLabel)
        allDataChunk{chunkInd, 1} = data_raw(tmpInd:(i-1), indFirstFeature:indLastFeature); 
        tmpInd = i;
        allDataChunk{chunkInd, 2} = firstLabel;
        label_all(chunkInd, 1) = firstLabel;
        allDataChunk{chunkInd, 3} = data_raw((i-1), indSubject); % subject info
        chunkInd = chunkInd + 1;
        firstLabel = secondLabel;
    elseif(i == allR) % the last chunk
        allDataChunk{chunkInd, 1} = data_raw(tmpInd:allR, indFirstFeature:indLastFeature);
        allDataChunk{chunkInd, 2} = firstLabel;
        label_all(chunkInd, 1) = firstLabel;
        allDataChunk{chunkInd, 3} = data_raw(allR, indSubject);
    else
        ;
    end
end

% allLabels and all subjects IDs
allLabels = [0;1;2;3;4;5];
allSubjects = [];
allSubjects(1,1) = data_raw(1, indSubject);
sub_ind = 2;
for i = 2: allR
    if (~ismember(data_raw(i, indSubject), allSubjects))
        allSubjects(sub_ind, 1) = data_raw(i, indSubject);
        sub_ind = sub_ind + 1;
    end
end

% split different label's data into different cells
for i = 1:size(allLabels, 1)
    nowLabel = allLabels(i);
    if(nowLabel < 0)
        tmpVar = strcat('classMinus', int2str(-nowLabel));
    else
        tmpVar = strcat('class', int2str(nowLabel));
    end
    nowInd = find(label_all(:,1) == nowLabel);
    assignin('base', tmpVar, allDataChunk(nowInd, :));
end
leftChunk = allDataChunk;
numFeatures = size(allDataChunk{1,1}, 2);
save('wisdm_1.mat', 'numFeatures', 'leftChunk','allLabels','class0','class1','class2','class3','class4','class5');
save('data_raw.mat', 'data_raw', 'allLabels','allSubjects');
save('data_chunked.mat','allDataChunk','allLabels','allSubjects');


