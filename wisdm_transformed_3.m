% by Hangwei, 18-Aug-2017 13:47:06
% semi-supervised setting

clear all
clc
load('wisdm_1.mat');
addpath(genpath(pwd)); % helpful for using libsvmwrite in the main path instead of adding them to all subfolders
ParentPath = pwd;
allDataChunk = leftChunk;
rng('default');
load('semi_ratio_all.mat');

numClass = length(allLabels);

for i = 1:size(semi_ratio_all, 1)
    nowRatio = semi_ratio_all(i, 1) + semi_ratio_all(i, 2) + semi_ratio_all(i, 3);
    prop_lab = semi_ratio_all(i, 1)./nowRatio;
    prop_unlab = semi_ratio_all(i, 2) ./nowRatio;
    prop_test = semi_ratio_all(i, 3) ./nowRatio;
    nowRatio_str = num2str(nowRatio);
    load(strcat('semi_ratio_', nowRatio_str,'.mat'));
    nowFolderPath = strcat('a_semi_', num2str(labRatio_inside));
    mkdir(nowFolderPath);
    cd(nowFolderPath);
    for tmpFolderIndn = 1: numRuns
        % cd the corresponding folder
        tmpFolderInd = int2str(tmpFolderIndn)
        mkdir(tmpFolderInd);
        cd(tmpFolderInd);

        labCell = cell(1,1); % labeled data
        unlabCell = cell(1,1);% unlabeled data
        testCell = cell(1,1);% test data
        labInd = 1;
        unlabInd = 1;
        testInd = 1;
        
    for tmpClass = 1: numClass % class
        nowLabel = allLabels(tmpClass);
        if(nowLabel >= 0)
            nowData = eval(strcat('class', int2str(nowLabel)));
        else
            nowData = eval(strcat('classMinus', int2str(-nowLabel)));
        end
        trainSubject = semi_ratio{tmpClass, 1}(tmpFolderIndn, :);% train/test split for this class, this folder
        numLabInstance = ceil(prop_lab * size(trainSubject, 2));
        numUnlabInstance = ceil(prop_unlab * size(trainSubject, 2))-1;
        numTestInstance = ceil(prop_test * size(trainSubject, 2))-1;
        assert(numLabInstance + numUnlabInstance + numTestInstance <= size(trainSubject, 2));
        
        labSubject = trainSubject(:, 1:numLabInstance);
        unlabSubject = trainSubject(:, (numLabInstance + 1):(numLabInstance + numUnlabInstance));
        testSubject = trainSubject(:, (numLabInstance + numUnlabInstance + 1):(numLabInstance + numUnlabInstance + numTestInstance));
        for i = 1:size(nowData, 1)
            if(ismember(i, labSubject))
                labCell{labInd, 1} = nowData{i, 1}; % data
                labCell{labInd, 2} = nowData{i, 2}; % class label
                labInd = labInd + 1;
            elseif(ismember(i, unlabSubject))
                unlabCell{unlabInd, 1} = nowData{i, 1}; % data
                unlabCell{unlabInd, 2} = unlabInd;
                unlabCell{unlabInd, 3} = nowData{i, 2}; % class label
                unlabInd = unlabInd + 1;               
            elseif(ismember(i, testSubject))
                testCell{testInd, 1} = nowData{i, 1};
                testCell{testInd, 2} = testInd;
                testCell{testInd, 3} = nowData{i, 2};
                testInd = testInd + 1;
            else
                ;
            end
        end
    end
    % sort the training data based on labels
    labR = size(labCell, 1);
    unlabR = size(unlabCell, 1);
    testR = size(testCell, 1);
    actiLabel = zeros(labR, 1);
    for i = 1: labR
        actiLabel(i,1) = labCell{i,2};
    end
    [B, I] = sort(actiLabel);
    sortedLabCell = cell(labR, 3);
    for i = 1: labR
        sortedLabCell{i,1} = labCell{I(i,1),1}; % chunked data
        sortedLabCell{i,2} = i;
        sortedLabCell{i,3} = labCell{I(i,1),2}; % label
    end
    
    % transform into svm and smm compatible format
    label_ = [];
    group_ = [];
    data_ = [];
    label_unlab = [];
    group_unlab = [];
    data_unlab = [];   
    label_t = [];
    group_t = [];
    data_t = []; 

    firstInd = 1; 
    TOTALFRAMETRAIN = 0;
    for i = 1: labR
        [tmpSize, b] = size(sortedLabCell{i,1});
        TOTALFRAMETRAIN = TOTALFRAMETRAIN + tmpSize;
        lastInd = firstInd + tmpSize -1;

        label_(firstInd:lastInd,1) = repmat(sortedLabCell{i,3}, tmpSize, 1);
        group_(firstInd:lastInd,1) = repmat(i, tmpSize, 1);
        data_(firstInd:lastInd, 1:b) = sortedLabCell{i,1};
        firstInd = lastInd + 1;
    end
    if(size(data_, 2) > numFeatures)
        disp('Error: dimension not correct!\n');
    end
    disp(TOTALFRAMETRAIN)

    firstInd = 1;
    TOTALFRAMEUNLAB = 0;
    for i = 1: unlabR
        [tmpSize, b] = size(unlabCell{i,1});
        TOTALFRAMEUNLAB = TOTALFRAMEUNLAB + tmpSize;
        lastInd = firstInd + tmpSize -1;

        label_unlab(firstInd:lastInd,1) = repmat(unlabCell{i,3}, tmpSize, 1);
        group_unlab(firstInd:lastInd,1) = repmat(i, tmpSize, 1);
        data_unlab(firstInd:lastInd, 1:b) = unlabCell{i,1};
        firstInd = lastInd + 1;
    end
    disp(TOTALFRAMEUNLAB)    
    
    firstInd = 1;
    TOTALFRAMETEST = 0;
    for i = 1: testR
        [tmpSize, b] = size(testCell{i,1});
        TOTALFRAMETEST = TOTALFRAMETEST + tmpSize;
        lastInd = firstInd + tmpSize -1;

        label_t(firstInd:lastInd,1) = repmat(testCell{i,3}, tmpSize, 1);
        group_t(firstInd:lastInd,1) = repmat(i, tmpSize, 1);
        data_t(firstInd:lastInd, 1:b) = testCell{i,1};
        firstInd = lastInd + 1;
    end
    disp(TOTALFRAMETEST)

    
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%deal with NaN in data
    %%% deal with NaN values in the training data
    [R_data_, C_data_] = size(data_);
    data_new = zeros(R_data_, C_data_);

    for k = 1:numClass
        tmpInd = strcat('Ind', num2str(k));
        tmpMean = strcat('mean', num2str(k));
        tmpR = strcat('tmpR', num2str(k));
        tmpaa = strcat('aa', num2str(k));
        tmpMeanRep = strcat('mean',num2str(k),'Rep');
        assignin('base', tmpInd, find(label_(:,1) == allLabels(k)));
        assignin('base', tmpMean, mean(data_(eval(tmpInd),:), 'omitnan'));
        assignin('base', tmpR, size(eval(tmpInd),1));
        assignin('base', tmpMeanRep, repmat(eval(tmpMean), eval(tmpR), 1));
        assignin('base', tmpaa, isnan(data_(eval(tmpInd),:)));
        if k == 1
            data_(isnan(data_)) = 0;
        end
        data_new(eval(tmpInd),:) = data_(eval(tmpInd),:) + eval(tmpaa).*eval(tmpMeanRep);
    end
    % NaN in unlabeled data
    [R_data_unlab, C_data_unlab] = size(data_unlab);
    data_new_unlab = zeros(R_data_unlab, C_data_unlab);

    for k = 1:length(allLabels)
        tmpInd = strcat('Ind', num2str(k),'unlab');
        tmpMean = strcat('mean', num2str(k),'unlab');
        tmpR = strcat('tmpR', num2str(k),'unlab');
        tmpaa = strcat('aa', num2str(k),'unlab');
        tmpMeanRep = strcat('mean',num2str(k),'Repunlab');
        assignin('base', tmpInd, find(label_unlab(:,1) == allLabels(k))); %%%%
        assignin('base', tmpMean, mean(data_unlab(eval(tmpInd),:), 'omitnan'));%%%%
        assignin('base', tmpR, size(eval(tmpInd),1)); %%%%
        assignin('base', tmpMeanRep, repmat(eval(tmpMean), eval(tmpR), 1));
        assignin('base', tmpaa, isnan(data_unlab(eval(tmpInd),:)));
        if k == 1
            data_unlab(isnan(data_unlab)) = 0;
        end
        data_new_unlab(eval(tmpInd),:) = data_unlab(eval(tmpInd),:) + eval(tmpaa).*eval(tmpMeanRep);
    end
  
    % NaN in test data
    [R_data_t, C_data_t] = size(data_t);
    data_new_t = zeros(R_data_t, C_data_t);

    for k = 1:length(allLabels)
        tmpInd = strcat('Ind', num2str(k),'t');
        tmpMean = strcat('mean', num2str(k),'t');
        tmpR = strcat('tmpR', num2str(k),'t');
        tmpaa = strcat('aa', num2str(k),'t');
        tmpMeanRep = strcat('mean',num2str(k),'Rept');
        assignin('base', tmpInd, find(label_t(:,1) == allLabels(k))); %%%%
        assignin('base', tmpMean, mean(data_t(eval(tmpInd),:), 'omitnan'));%%%%
        assignin('base', tmpR, size(eval(tmpInd),1)); %%%%
        %assignin('base', strcat('tmpC', num2str(k)), size(eval(tmpInd),2));
        assignin('base', tmpMeanRep, repmat(eval(tmpMean), eval(tmpR), 1));
        assignin('base', tmpaa, isnan(data_t(eval(tmpInd),:)));
        if k == 1
            data_t(isnan(data_t)) = 0;
        end
        data_new_t(eval(tmpInd),:) = data_t(eval(tmpInd),:) + eval(tmpaa).*eval(tmpMeanRep);
    end

    % do the PCA to train data and deal with test data with the same parameter
    [n,m] = size(data_new);
    trainMean = mean(data_new);
    [p,q] = size(std(data_new));
    trainStd = std(data_new)+ repmat(0.01,p,q); % add a small number

    % the calculated contains NaN because of the denominator has 0, and divide
    % 0
    labData_std = (data_new - repmat(trainMean,[n,1]))./repmat(trainStd,[n,1]);

    [pca_coeff, score, eigenvalues, ~, explained,mu] = pca(labData_std); %princomp also works
    pcaDim = 0;
    for i = 1:length(explained)
        if(sum(explained(1:i)) >= 90)
            pcaDim = i
            break;
        end
    end
    if(pcaDim == 0)
        disp('Error: pcaDim == 0!!!!');
    end
    labData_std_pca = score(:,1:pcaDim);

    % unlabelded data
    [n3,m3] = size(data_new_unlab);
    data_noClass0_std_unlab = (data_new_unlab - repmat(trainMean,[n3,1]))./repmat(trainStd,[n3,1]);
    data_noClass0_std_unlab_tmp = data_noClass0_std_unlab * pca_coeff;
    unlabData_std_pca = data_noClass0_std_unlab_tmp(:,1:pcaDim);
    
    %testing data
    [n2,m2] = size(data_new_t);
    data_noClass0_std_t = (data_new_t - repmat(trainMean,[n2,1]))./repmat(trainStd,[n2,1]);
    data_noClass0_std_t_tmp = data_noClass0_std_t * pca_coeff;
    testData_std_pca = data_noClass0_std_t_tmp(:,1:pcaDim);

    % save in svm and smm format
    mkdir('semi_smm_experi');
    
    libsvmwrite_emp_ubicomp08('./semi_smm_experi/smm.lab', label_, group_, sparse(labData_std_pca));
    libsvmwrite_emp_ubicomp08('./semi_smm_experi/smm.unlab', label_unlab, group_unlab, sparse(unlabData_std_pca));
    libsvmwrite_emp_ubicomp08('./semi_smm_experi/smm.test', label_t, group_t, sparse(testData_std_pca));

    save('./semi_smm_experi/train.mat', 'label_','group_','labData_std_pca', 'allLabels');
    save('./semi_smm_experi/unlab.mat','label_unlab','group_unlab','unlabData_std_pca', 'allLabels');        
    save('./semi_smm_experi/test.mat','label_t','group_t', 'testData_std_pca', 'allLabels');

    fileattrib(strcat('./semi_smm_experi'), '+w'); % remove the writing permission of the whole folder

    cd ..
    fileattrib(tmpFolderInd, '+w');
    end
    cd(ParentPath);
    fileattrib(nowFolderPath, '+w'); % remove the writing permission of the whole folder
end
