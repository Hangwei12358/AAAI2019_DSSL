% by Hangwei, 27-Jul-2017 14:13:30
% to construct binary data sets that combines both train and test data,
% preparation for l-2 kernel calculation
% skoda data set
% combine train and test data by [train;test];
clear all
clc
load('test.mat');
load('unlab.mat');
load('train.mat');
% combine train and test data

label_all = [label_; label_unlab; label_t];
label_all_binary = -ones(size(label_all)); % initialize as all -1's
% modify labels into binary labels, 

num_group_all = max(group_) + max(group_unlab) + max(group_t);
group_unlab_new = group_unlab + max(group_);
group_t_new = group_t + max(group_unlab_new);

group_all = [group_; group_unlab_new; group_t_new];

Ind = find(group_all == 1);
label_all_binary(Ind) = 1; 
% let 1st group's label to be different from others; -1 or +1 does not matter, here we choose
% to make 1st group label to be +1, others to be -1, to be consistent with
% C++ setting

data_all = [labData_std_pca; unlabData_std_pca; testData_std_pca];

libsvmwrite_emp_ubicomp08('data_semi.all', label_all_binary, group_all, sparse(data_all));



