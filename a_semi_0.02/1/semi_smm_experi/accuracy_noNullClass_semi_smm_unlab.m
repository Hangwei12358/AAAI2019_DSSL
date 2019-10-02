% calculate the accuracy in frame of smm

% needed file: mat file containing true labels and group information;
%               txt files of the smm test results

clear all;
clc;
if exist('confuMat_smm_frame_unlab.txt') == 2
    delete('confuMat_smm_frame_unlab.txt');
end
if exist('confuMat_smm_event_unlab.txt') == 2
    delete('confuMat_smm_event_unlab.txt');
end
if exist('micro_macro_frame_unlab.txt') == 2
    delete('micro_macro_frame_unlab.txt');
end
if exist('micro_macro_event_unlab.txt') == 2
    delete('micro_macro_event_unlab.txt');
end

% load the ground truth label of test data
load('unlab.mat');

% as the labels in test data might not be all the labels in the train data
%%%%%%%%%%%%%%get the labels in test data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
allLabels_unlab = [];
ind = 1;
for i = 1:length(label_unlab)
    tmp_label = label_unlab(i);
    a = find(allLabels_unlab == tmp_label);
    if (length(a) > 0)
        ;
    else
        allLabels_unlab(ind, 1) = tmp_label;
        ind = ind + 1;
    end
end
[B, I] = sort(allLabels_unlab);
allLabels_unlab = B;
% class0Label = allLabels_unlab(1,1);
% allLabels_unlab(1,:) = [];


allTestLabels = cell(length(allLabels_unlab), 1);
for i = 1:length(allLabels_unlab)
    allTestLabels{i, 1} = allLabels_unlab(i,1);
end


lengthTestLabels = length(allTestLabels);
lengthAll = length(label_unlab);
proportion_each_label = zeros(lengthTestLabels, 1);
for theLabel = 1:length(allTestLabels)
    validRows = find(label_unlab == allTestLabels{theLabel}); 
    proportion_each_label(theLabel, 1) = allTestLabels{theLabel};
    proportion_each_label(theLabel, 2) = length(validRows)./lengthAll;
end

fID_save = fopen('accuracy_smm_unlab.csv','w+');
fID_confusionMat_frame = fopen('confuMat_smm_frame_unlab.txt','a+');
fID_confusionMat_event = fopen('confuMat_smm_event_unlab.txt','a+');
fID_micro_macro_frame = fopen('micro_macro_frame_unlab.txt','a+');
fID_micro_macro_event = fopen('micro_macro_event_unlab.txt','a+');
fprintf(fID_save,'%s\n', 'smm accuracy in frames');
fprintf(fID_micro_macro_frame, 'file miF_frames maF_frames weighted_maF_frames \n');
fprintf(fID_micro_macro_event, 'file miF_event maF_event weighted_maF_events\n');

max_miF_frame = 0;
max_maF_frame = 0;
max_maF_weiFrame = 0;
max_miF_event = 0;
max_maF_event = 0;
max_maF_weiEvent = 0;

% find total number of labels in unlabeled data:
totalGroupNum = max(group_unlab);
numGroup = zeros(totalGroupNum, 1); % each group's number of instances

for i = 1: totalGroupNum
    tmp = find(group_unlab == i);
    numGroup(i,1) = length(tmp);
end
 
trueLabelNum = zeros(totalGroupNum, 2);
 
 first_index = 1;
 for i = 1: totalGroupNum
     trueLabelNum(i,1) = label_unlab(first_index, 1);
     trueLabelNum(i,2) = numGroup(i,1); % take one label each group
 end
fID_all_names = fopen('precomputedK_smm_names_unlab.txt','r');
all_names = textscan(fID_all_names, '%s');
fclose(fID_all_names);

for j = 1:length(all_names{1,1})
% calculate the smm accuracy in frame
fID_smm = fopen(char(all_names{1,1}(j)),'r'); 
fgets(fID_smm); 
calcu_label_smm = textscan(fID_smm, '%d %d');
true_label_event = calcu_label_smm{1,1};
predict_label_event = calcu_label_smm{1,2};
if (size(calcu_label_smm{1,1}, 1) == 0)
    ;
else

 % true_label_event_no0 = true_label_event(true_label_event(:,1));
lengthAll_event = length(true_label_event);
proportion_each_label_event = zeros(lengthTestLabels, 1);
for theLabel = 1:length(allTestLabels)
    validRows = find(true_label_event == allTestLabels{theLabel}); 
    proportion_each_label_event(theLabel, 1) = allTestLabels{theLabel};
    proportion_each_label_event(theLabel, 2) = length(validRows)./lengthAll_event;
end

% the input should be the have-0 predicted/true labels
[confuMatrix_event, mi_event, ma_event] = micro_macro_PR_WISDM(predict_label_event, true_label_event, proportion_each_label_event);

fprintf(fID_confusionMat_frame, char(all_names{1,1}(j))); % print the file names before confusion matrix
fprintf(fID_confusionMat_event, char(all_names{1,1}(j)));
fprintf(fID_micro_macro_frame, char(all_names{1,1}(j)));
fprintf(fID_micro_macro_event, char(all_names{1,1}(j)));

fprintf(fID_confusionMat_frame, '\n');
fprintf(fID_confusionMat_event, '\n');
fprintf(fID_confusionMat_event, '%d %d %d %d %d %d\n', confuMatrix_event);% dimension should be number of no0 classes
fprintf(fID_micro_macro_event, ' %2.3f %2.3f %2.3f\n', mi_event.fscore*100, ma_event.fscore*100, ma_event.weighted_fscore*100);

if(mi_event.fscore > max_miF_event)
    max_miF_event = mi_event.fscore;
end

if(ma_event.fscore > max_maF_event)
    max_maF_event = ma_event.fscore;
end

if(ma_event.weighted_fscore > max_maF_weiEvent)
    max_maF_weiEvent = ma_event.weighted_fscore;
end
fclose(fID_smm);

tmp_frame = 0;
predict_label_frame = zeros(size(label_unlab));
frameInd = 1;
for i = 1 : totalGroupNum
    tmpGroupNum = trueLabelNum(i,2);
    tmpPredictLabel = calcu_label_smm{1,2}(i);
    tmpTrueLabel = calcu_label_smm{1,1}(i);
    predict_label_frame(frameInd:(frameInd + tmpGroupNum-1),1) = double(repmat(tmpPredictLabel, tmpGroupNum ,1));
    frameInd = frameInd + tmpGroupNum;
    
    if tmpPredictLabel == tmpTrueLabel
        tmp_frame = tmp_frame + tmpGroupNum;
    end
end
tmp_frame
accuracy_smm = tmp_frame./length(group_unlab) * 100
fprintf(fID_save,'%f(%d/%d)\n', accuracy_smm, tmp_frame, length(group_unlab));
[confuMatrix_frame, mi_frame, ma_frame] = micro_macro_PR_WISDM(predict_label_frame, label_unlab, proportion_each_label);

fprintf(fID_micro_macro_frame, ' %2.3f %2.3f %2.3f\n', mi_frame.fscore*100, ma_frame.fscore*100, ma_frame.weighted_fscore*100);
fprintf(fID_confusionMat_frame, '%d %d %d %d %d %d\n', confuMatrix_frame); % dimension should be number of no0 classes

if(mi_frame.fscore > max_miF_frame)
    max_miF_frame = mi_frame.fscore;
end

if(ma_frame.fscore > max_maF_frame)
    max_maF_frame = ma_frame.fscore;
end

if(ma_frame.weighted_fscore > max_maF_weiFrame)
    max_maF_weiFrame = ma_frame.weighted_fscore;
end
end
end

slack_vari = 'hi';
fprintf(fID_micro_macro_frame, 'summary max_miF_frame max_maF_frame max_maF_weiFrame \n');
fprintf(fID_micro_macro_frame, ' %s %2.3f %2.3f %2.3f\n',slack_vari, max_miF_frame*100, max_maF_frame*100, max_maF_weiFrame*100);

fprintf(fID_micro_macro_event, 'summary max_miF_event max_maF_event max_maF_weiEvent \n');
fprintf(fID_micro_macro_event, ' %s %2.3f %2.3f %2.3f\n',slack_vari, max_miF_event*100, max_maF_event*100, max_maF_weiEvent*100);

fclose(fID_save);
fclose(fID_confusionMat_event);
fclose(fID_confusionMat_frame);
fclose(fID_micro_macro_frame);
fclose(fID_micro_macro_event);

