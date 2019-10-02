% by Hangwei, 22-Aug-2017 10:48:40
% g50c data set
% split precomputed kernel matrix into training and testing part

clear all
clc
% get the groups of train and test
load('test.mat');
load('unlab.mat');
load('train.mat');
num_groups_test = max(group_t);
num_groups_unlab = max(group_unlab);
num_groups_lab = max(group_);
num_groups_train = num_groups_lab + num_groups_unlab;
group_unlab_new = max(group_) + group_unlab;
group_train = [group_; group_unlab_new];
label_train = [label_; label_unlab];

totalP = 10;
p = 2;
% read from precomputed k txt files
fID_all_names = fopen('data_all_names_semi.txt','r');
all_names = textscan(fID_all_names, '%s');
fclose(fID_all_names);
% get the k matrix of each pair of parameters
for j = 1:length(all_names{1,1})
    nowFileName = char(all_names{1,1}(j));
    outFileName = nowFileName(1:(end-4));
    [label_all, group_all, c] = libsvmreadK_hangwei(nowFileName);
    K_all = full(c);
    assert(num_groups_lab + num_groups_unlab + num_groups_test == size(K_all, 1));
    % remove useless 1st column
    K_all(:, 1) = [];
    % transform the kernel_all into k_train (lab and unlab kernel matrix) and k_test
    K_train = K_all(1:num_groups_train, 1:num_groups_train);
    K_test = K_all((num_groups_train + 1):(num_groups_train + num_groups_test), 1:num_groups_train); 
    
    % modify the kernel to be graph Laplacian kernel
    % code by hangwei, may be need to modified later
    % construct k-NN to the kernel
    tmp_k = ceil(sqrt(size(K_train, 1)));
    if mod(tmp_k, 2) == 0
        tmp_k = tmp_k -1;
    else
    end
    lower_tril_mat = tril(K_train);
    [B, I] = sort(lower_tril_mat, 'descend');
    new_tril_mat = lower_tril_mat;
    all_zero_mat = zeros(size(new_tril_mat));
    for ii = 1:size(I, 2) % column
        new_tril_mat(I((tmp_k+1):end, ii), ii) = 0;
    end
    W = new_tril_mat + new_tril_mat';
    W(1:(size(new_tril_mat, 1)+1):end) = diag(all_zero_mat); % make it symmetric
    
    %%% learnt from MR codes, calculate Laplacian matrix
    D = sum(W(:,:),2);  
    % normalized laplacian
    D(find(D))=sqrt(1./D(find(D))); % update the vector at the same time! Great!
    D=spdiags(D,0,speye(size(W,1)));
    W=D*W*D;
    L=speye(size(W,1))-W;
    L = L^p;
%%%%%%%%%%%%%%%%%%%%%%%% learnt from MR codes, calculate deformed kernel 

    r = 100;
    I=eye(size(K_train,1));
    Ktilde=(I+r*K_train*L)\K_train; % it equals ()^(-1)*K, qhw
    max(max(Ktilde))
    K_test_tilde = (K_test - r*K_test*L*Ktilde);
    
    % after calculation of Kernel matrix, split the matrix into labeled/unlabeled/test sub
    % matrix
    % train and test data for unlabeled data
    kernel_unlab_train = Ktilde(1:num_groups_lab, 1:num_groups_lab);
    kernel_unlab_test = Ktilde((num_groups_lab+1):(num_groups_lab + num_groups_unlab), 1:num_groups_lab);
    group_unlab_train = (1:num_groups_lab)';
    group_unlab_test = (1:num_groups_unlab)';
    
    % train and test data for test data
    kernel_test_train = Ktilde(1:num_groups_train, 1:num_groups_train);
    kernel_test_test = K_test_tilde;
    group_test_train = (1:num_groups_train)';
    group_test_test = (1:num_groups_test)';
    
 
    % get labels of each group for unlabeled data
    label_unlab_train = [];
    label_unlab_test = [];
    for i = 1:num_groups_lab
        Ind = find(group_ == i);
        label_unlab_train(i, 1) = label_(Ind(1,1), 1);
    end
    for i = 1: num_groups_unlab
        Ind = find(group_unlab == i);
        label_unlab_test(i, 1) = label_unlab(Ind(1, 1), 1);
    end
    
    
    % get labels of each group for test data
    label_test_train = [];
    label_test_test = [];
    for i = 1:num_groups_train
        Ind = find(group_train == i);
        label_test_train(i, 1) = label_train(Ind(1,1), 1);
    end
    for i = 1: num_groups_test
        Ind = find(group_t == i);
        label_test_test(i, 1) = label_t(Ind(1, 1), 1);
    end
    
    % save for unlabeled training and testing
    libsvmwrite_KernelMatrix_Hangwei(strcat(outFileName, '_p',num2str(p),'_r',num2str(r),'_unlab.train'), label_unlab_train, sparse(kernel_unlab_train));
    libsvmwrite_KernelMatrix_Hangwei(strcat(outFileName, '_p',num2str(p),'_r',num2str(r),'_unlab.test'), label_unlab_test, sparse(kernel_unlab_test));
    % save for test training and testing
    libsvmwrite_KernelMatrix_Hangwei(strcat(outFileName, '_p',num2str(p),'_r',num2str(r),'_test.train'), label_test_train, sparse(kernel_test_train));
    libsvmwrite_KernelMatrix_Hangwei(strcat(outFileName, '_p',num2str(p),'_r',num2str(r),'_test.test'), label_test_test, sparse(kernel_test_test));

end


