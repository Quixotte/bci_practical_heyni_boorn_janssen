clear all; clc;
load('dataset/ch_pos.mat'); %load eeg channel position
load('dataset/left.mat'); %load data for the left hand
load('dataset/right.mat'); %load data for the right hand
users = [42,32,7,53,54];
channels = 1:21;
[original, labels, set_users] = generateDatasets(left(1:100,:),right(1:100,:),users,2,channels,0);
% opt = struct('fs',160,'visualize',0,'badchrm',0,'badtrrm',0,'spatialfilter','slap','detrend',...
%     1, 'freqband',[6 8 26 28],'ch_pos',ch_pos(:,channels));
channel_names = ['FC5';'FC3';'FC1';'FCz';'FC2';'FC4';'FC6';...
    'C6 ';'C4 ';'C2 ';'Cz ';'C1 ';'C3 ';'C5 ';...
    'CP5';'CP3';'CP1';'CPz';'CP2';'CP4';'CP6'];
ch_pos = cellstr(channel_names);
opt = struct('fs',160,'visualize',0,'badchrm',0,'badtrrm',0,'spatialfilter','slap','detrend',...
    1, 'freqband',[6 8 26 28],'ch_pos',{ch_pos},'capFile','this_cap_best_cap.txt');
[set,~,~,~] = preproc_ersp(original,opt);
set = reshape(set,size(set,3),size(set,1)*size(set,2));

%% Test KMeans within subject
'KMeans within subject'
clusters = 5;
kw_acc = zeros(size(users,2),5);
for user=1:size(users,2)
    ind = set_users==users(user);
    subset = set(ind,:);
    N = size(subset,1);
    sublabels = labels(ind);
    
    indices = crossvalind('Kfold',N,N);
    cp = classperf(sublabels);
    for i=1:size(indices)
        train_set = subset(indices ~= i,:); tr_labels = sublabels(indices ~= i);
        test_set = subset(indices == i,:); te_labels = sublabels(indices == i);
        
        left = KMeans(clusters,size(train_set,2)); left.train(train_set(tr_labels==1));
        right = KMeans(clusters,size(train_set,2)); right.train(train_set(tr_labels==2));
        f = (min(left.getEuclideanDistance(test_set)) > min(right.getEuclideanDistance(test_set))) + 1;
        classperf(cp,f,indices==i);
    end
    kw_acc(user,:) = [cp.CorrectRate,cp.Sensitivity,cp.Specificity,sum(diag(cp.DiagnosticTable)),sum(sum(cp.DiagnosticTable))];
end
% test significance
k_wp = binocdf(kw_acc(:,4), kw_acc(:,5),0.5,'upper');
k_within_significant = k_wp<0.05;

%% Test Kmeans between subject
'KMeans between subject'
clusters = 5;
kb_acc = zeros(size(users,2),5);
for user=1:size(users,2)
    train_set = set(set_users~=users(user),:); tr_labels = labels(set_users~=users(user));
    test_set = set(set_users==users(user),:); te_labels = labels(set_users==users(user));
    
    cp = classperf(te_labels);
    
    left = KMeans(clusters,size(train_set,2)); left.train(train_set(tr_labels==1));
    right = KMeans(clusters,size(train_set,2)); right.train(train_set(tr_labels==2));
    f = (min(left.getEuclideanDistance(test_set)) > min(right.getEuclideanDistance(test_set))) + 1;
    classperf(cp,f);
    
    kb_acc(user,:) = [cp.CorrectRate,cp.Sensitivity,cp.Specificity,sum(diag(cp.DiagnosticTable)),sum(sum(cp.DiagnosticTable))];
end
k_bp = binocdf(kb_acc(:,4), kb_acc(:,5),0.5,'upper');
k_between_significant = k_bp<0.05;

%% Test Gaussian mixture model within subject
'Gaussian within subject'
clusters = 10;
iter = 1;
gw_acc = zeros(size(users,2),5);
for user=1:size(users,2)
    ind = set_users==users(user);
    subset = set(ind,:);
    N = size(subset,1);
    sublabels = labels(ind);
    
    indices = crossvalind('Kfold',N,N);
    cp = classperf(sublabels);
    for i=1:size(indices)
        train_set = subset(indices ~= i,:); tr_labels = sublabels(indices ~= i);
        test_set = subset(indices == i,:); te_labels = sublabels(indices == i);
        
        left = GaussianEM(clusters,size(train_set,2),'Left'); left.train(train_set(tr_labels==1,:),iter,0,0,2,4);
        right = GaussianEM(clusters,size(train_set,2),'Right'); right.train(train_set(tr_labels==2,:),iter,0,0,2,4);
        lp = left.getLikelihood(test_set); rp = left.getLikelihood(test_set);
        f = datasample(find([lp,rp] == max([lp,rp])),1,'Replace',false);
        classperf(cp,f,indices == i);
    end
    gw_acc(user,:) = [cp.CorrectRate,cp.Sensitivity,cp.Specificity,sum(diag(cp.DiagnosticTable)),sum(sum(cp.DiagnosticTable))];
end
% test significance
g_wp = binocdf(gw_acc(:,4), gw_acc(:,5),0.5,'upper');
g_within_significant = g_wp<0.05;

%% Test Gaussian mixture model between subject
'Gaussian between subject'
clusters = 5;
iter = 1;
gb_acc = zeros(size(users,2),5);
for user=1:size(users,2)
    train_set = set(set_users~=users(user),:); tr_labels = labels(set_users~=users(user));
    test_set = set(set_users==users(user),:); te_labels = labels(set_users==users(user));
    
    cp = classperf(te_labels);
    
    left = GaussianEM(clusters,size(train_set,2),'Left'); left.train(train_set(tr_labels==1,:),iter,0,0,2,4);
    right = GaussianEM(clusters,size(train_set,2),'Right'); right.train(train_set(tr_labels==2,:),iter,0,0,2,4);
    lp = left.getLikelihood(test_set); rp = left.getLikelihood(test_set);
    B = [lp,rp] == repmat(max([lp,rp],[],2),1,2);
    f = zeros(size(B,1),1);
    for i=1:size(f,1)
        f(i) = datasample(find(B(i,:)),1,'Replace',false);
    end
    classperf(cp,f);
    
    gb_acc(user,:) = [cp.CorrectRate,cp.Sensitivity,cp.Specificity,sum(diag(cp.DiagnosticTable)),sum(sum(cp.DiagnosticTable))];
end
g_bp = binocdf(gb_acc(:,4), gb_acc(:,5),0.5,'upper');
g_between_significant = g_bp<0.05;

%% Test logistic regression within subject
'Logistic Regression within subject'
warning('off','all');
lrw_acc = zeros(size(users,2),5);
for user=1:size(users,2)
    ind = set_users==users(user);
    subset = set(ind,:);
    N = size(subset,1);
    sublabels = labels(ind);
    
    indices = crossvalind('Kfold',N,N);
    cp = classperf(sublabels);
    for i=1:size(indices)
        train_set = subset(indices ~= i,:); tr_labels = sublabels(indices ~= i);
        test_set = subset(indices == i,:); te_labels = sublabels(indices == i);
        
        B = glmfit(train_set,tr_labels-1,'binomial');
        f = round(glmval(B,test_set,'logit'))+1;
        classperf(cp,f,indices == i);
    end
    lrw_acc(user,:) = [cp.CorrectRate,cp.Sensitivity,cp.Specificity,sum(diag(cp.DiagnosticTable)),sum(sum(cp.DiagnosticTable))];
end
% test significance
lr_wp = binocdf(lrw_acc(:,4), lrw_acc(:,5),0.5,'upper');
lr_within_significant = lr_wp<0.05;

%% Test Logistic regression between subject
'Logistic Regression between subject'
lrb_acc = zeros(size(users,2),5);
for user=1:size(users,2)
    train_set = set(set_users~=users(user),:); tr_labels = labels(set_users~=users(user));
    test_set = set(set_users==users(user),:); te_labels = labels(set_users==users(user));
    
    cp = classperf(te_labels);
    
    B = glmfit(train_set,tr_labels-1,'binomial');
    f = round(glmval(B,test_set,'logit'))+1;
    classperf(cp,f);
    
    lrb_acc(user,:) = [cp.CorrectRate,cp.Sensitivity,cp.Specificity,sum(diag(cp.DiagnosticTable)),sum(sum(cp.DiagnosticTable))];
end
lr_bp = binocdf(lrb_acc(:,4), lrb_acc(:,5),0.5,'upper');
lr_between_significant = lr_bp<0.05;

%% Test ERSP classifier within subject
'ERSP classifier within subject'
erspw_acc = zeros(size(users,2),5);
for user=1:size(users,2)
    ind = set_users==users(user);
    subset = original(:,:,ind);
    N = size(subset,3); K = N;
    sublabels = labels(ind);
    
    indices = crossvalind('Kfold',N,K);
    cp = classperf(sublabels);
    for i=1:K
        train_set = subset(:,:,indices ~= i); tr_labels = sublabels(indices ~= i);
        test_set = subset(:,:,indices == i); te_labels = sublabels(indices == i);
        
        [clsfr,~,~,~] = train_ersp_clsfr(train_set,tr_labels,opt);
        f = classifyEpoch(test_set,clsfr);
        classperf(cp,f,indices==i);
    end
    erspw_acc(user,:) = [cp.CorrectRate,cp.Sensitivity,cp.Specificity,sum(diag(cp.DiagnosticTable)),sum(sum(cp.DiagnosticTable))];
end
% test significance
ersp_wp = binocdf(erspw_acc(:,4), erspw_acc(:,5),0.5,'upper');
ersp_within_significant = ersp_wp<0.05;

%% Test ERSP classifier between subject
'ERSP classifier between subject'
erspb_acc = zeros(size(users,2),5);
for user=1:size(users,2)
    train_set = original(:,:,set_users~=users(user)); tr_labels = labels(set_users~=users(user));
    test_set = original(:,:,set_users==users(user)); te_labels = labels(set_users==users(user));
    
    cp = classperf(te_labels);
    
    [clsfr,~,~,~] = train_ersp_clsfr(train_set,tr_labels,opt);
    f = classifyEpoch(test_set,clsfr);
    classperf(cp,f);
    
    erspb_acc(user,:) = [cp.CorrectRate,cp.Sensitivity,cp.Specificity,sum(diag(cp.DiagnosticTable)),sum(sum(cp.DiagnosticTable))];
end
ersp_bp = binocdf(erspb_acc(:,4), erspb_acc(:,5),0.5,'upper');
ersp_between_significant = ersp_bp<0.05;


%% Plot diagrams
figure; hold on;
% bar([kb_acc(:,1),gb_acc(:,1),lrb_acc(:,1),erspb_acc(:,1),]);
% plot(0:10,ones(11,1)*0.5,'r');
% legend('KMeans','Gaussian Mixture model','Logistic regression','ERSP classifier','chance level');
% title('Between subject');
% xlim([0.5 5.5]);
bar([kw_acc(:,1),gw_acc(:,1),lrw_acc(:,1),erspw_acc(:,1),]);
plot(0:10,ones(11,1)*0.5,'r');
legend('KMeans','Gaussian Mixture model','Logistic regression','ERSP classifier','chance level');
title('Within subject');
xlim([0.5 5.5]);