% analyze all the results
% by hangwei, May.8.2017
clear all
clc
fID_results = fopen('Results_All_Semi.txt','r'); 
results_cell = textscan(fID_results, '%f %f %f %f');
[~, targetCol] = size(results_cell);
for i = 1:targetCol
    results_all_semi(:, i) = results_cell{1, i};
end

%%%%%%%the following may need to change%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
semiRatioAll = {'03'}; % 0.05 for g50c
numRuns = 6;
nameOfMethods = {'semi_smm'};
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

numFolders = size(semiRatioAll, 1);
resultsOfFolders = strcat('results_semiRatio_', semiRatioAll);
numMethods = size(nameOfMethods, 1); % need to change later
tmp_ind = (1:1:numMethods)';
numEachFolder = numMethods * numRuns;
numAll = numEachFolder * numFolders;
% check the results size is correct or not
assert(size(results_all_semi, 1) == numAll);

% generate group indices
indOfMethods_group = repmat(tmp_ind, [numAll/numMethods, 1]);
save('results_all_semi.mat', 'results_all_semi');
% results for each folder
toSaveFiles = '';
for i = 1:numFolders
    firstInd = (i-1)*numEachFolder + 1;
    lastInd = i*numEachFolder;
    firstInd_result = (i-1)*numMethods + 1;
    lastInd_result = i*numMethods;
    results_mean = splitapply(@mean, results_all_semi(firstInd:lastInd,:), indOfMethods_group(firstInd:lastInd,:)); % by hangwei, nice
    results_std =  splitapply(@std, results_all_semi(firstInd:lastInd,:), indOfMethods_group(firstInd:lastInd,:));
    
    % show results in table
    miF_s = results_mean(:, 1);
    maF_s = results_mean(:, 2);
    miF_s_std = results_std(:, 1);
    maF_s_std = results_std(:, 2);
    resultsTable = table(miF_s, maF_s, miF_s_std, maF_s_std, 'RowNames',nameOfMethods)

    assignin('base', resultsOfFolders{i, 1}, resultsTable); % let strings to be variable names and initialize them, by hangwei, useful
    save('results_all_semi.mat',resultsOfFolders{i, 1}, '-append');
end