function [mat_initial, micro, macro] = micro_macro_PR_WISDM( pred_label , orig_label, proportion_no0)
%computer micro and macro: precision, recall and fscore
% by hangwei, Nov.2016

[mat_initial, mat_order] = confusionmat(orig_label, pred_label);
% as we do not consider 0 class labels in the true labels, thus we need to
% remove the 1st row of the confusion matrix

% there may be cases that some labels not exist in true labels but exist in
% predicted labels

% mat_order(1,:) = [];
right_propor_no0 = zeros(length(mat_order), 1);
if(length(mat_order) ~= length(proportion_no0))
    for i = 1:length(mat_order)
        tmpLabel = mat_order(i, 1);
        a = find(proportion_no0(:,1) == tmpLabel);
        if(length(a) > 0)
            right_propor_no0(i, 1) = proportion_no0(a,2);
        else
            right_propor_no0(i, 1) = 0;
        end
    end
else
    right_propor_no0 = proportion_no0(:,2);
end


% -> do: remore the 1st row of the mat and move the first column to be the
% last column
% mat_initial(1,:) = [];
% [numR, numC] = size(mat_initial);
% mat = zeros(size(mat_initial));
% mat(:, 1:(numC-1)) = mat_initial(:, 2: numC);
% mat(:, numC) = mat_initial(:, 1);

len=size(mat_initial, 1);
macroTP=zeros(len,1);
macroFP=zeros(len,1);
macroFN=zeros(len,1);
macroP=zeros(len,1);
macroR=zeros(len,1);
macroF=zeros(len,1);
for i=1:len
    macroTP(i)=mat_initial(i,i);
    macroFP(i)=sum(mat_initial(:, i))-mat_initial(i,i);
    macroFN(i)=sum(mat_initial(i,:))-mat_initial(i,i);
    if (macroTP(i) == 0)
        macroP(i) = 0;
        macroR(i) = 0;
    else
        macroP(i)=macroTP(i)/(macroTP(i)+macroFP(i));
        macroR(i)=macroTP(i)/(macroTP(i)+macroFN(i));
    end
    if(macroP(i) == 0 || macroR(i) == 0)
        macroF(i) = 0;
    else
        macroF(i)=2*macroP(i)*macroR(i)/(macroP(i)+macroR(i));
    end
end
macro.precision=mean(macroP);
macro.recall=mean(macroR);
macro.fscore=mean(macroF);
if length(right_propor_no0) ~= length(macroF)
    disp('Warning_Hangwei: dim not the same! in micro_macro_PR_WISDM.m file!');
    macro.weighted_fscore = 0;
else
    macro.weighted_fscore = right_propor_no0' * macroF;
end

micro.precision= sum(macroTP)/(sum(macroTP)+sum(macroFP));
micro.recall= sum(macroTP)/(sum(macroTP)+sum(macroFN));
micro.fscore= 2*micro.precision*micro.recall/(micro.precision+micro.recall);
end

