%tests the classifiers on the EEGMMIDB data set, both within-subject as
%between-subject

clear all; clc;
load('dataset/ch_pos.mat'); %load eeg channel position
load('dataset/left.mat'); %load data for the left hand
load('dataset/right.mat'); %load data for the right hand
users = [42,32,7,53,54,2,49];
channels = 1:21;
kmeans_clusters = 5;
gmm_clusters = 10;
gmm_iter = 1;
[original, labels, set_users] = generateDatasets(left(1:100,:),right(1:100,:),users,2,channels,160);

channel_names = ['FC5';'FC3';'FC1';'FCz';'FC2';'FC4';'FC6';...
    'C6 ';'C4 ';'C2 ';'Cz ';'C1 ';'C3 ';'C5 ';...
    'CP5';'CP3';'CP1';'CPz';'CP2';'CP4';'CP6'];
ch_pos = cellstr(channel_names);
opt = struct('fs',160,'visualize',0,'badchrm',0,'badtrrm',0,'spatialfilter','slap','detrend',...
    1, 'freqband',[6 8 26 28],'ch_pos',{ch_pos},'capFile','this_cap_best_cap.txt'); %filter in mu and beta frequencies
[dataset,~,~,~] = preproc_ersp(original,opt); %preprocess the data
dataset = reshape(dataset,size(dataset,3),size(dataset,1)*size(dataset,2));

%% Test KMeans within subject
'KMeans within subject'

kw_acc = zeros(size(users,2),5);
for user=1:size(users,2)
    ind = set_users==users(user);
    subset = dataset(ind,:);
    N = size(subset,1); K=N;
    sublabels = labels(ind);
    
    indices = crossvalind('Kfold',N,K);
    cp = classperf(sublabels);
    for i=1:size(indices)
        train_set = subset(indices ~= i,:); tr_labels = sublabels(indices ~= i); %train on all but one datapoints
        test_set = subset(indices == i,:); te_labels = sublabels(indices == i); %test on remaining data point
        
        left = KMeans(kmeans_clusters,size(train_set,2)); left.train(train_set(tr_labels==1)); %train kmeans for left and right
        right = KMeans(kmeans_clusters,size(train_set,2)); right.train(train_set(tr_labels==2));
        %closest point is the best estimate
        f = (min(left.getEuclideanDistance(test_set)) > min(right.getEuclideanDistance(test_set))) + 1; %classify on minimal distance
        classperf(cp,f,indices==i);
    end
    kw_acc(user,:) = [cp.CorrectRate,cp.Sensitivity,cp.Specificity,sum(diag(cp.DiagnosticTable)),sum(sum(cp.DiagnosticTable))];
end
% test significance calculated from theoretical binomial distribution with
% mean 0.5
k_wp = binocdf(kw_acc(:,4), kw_acc(:,5),0.5,'upper');

%% Test Kmeans between subject
'KMeans between subject'

kb_acc = zeros(size(users,2),5);
for user=1:size(users,2)
    train_set = dataset(set_users~=users(user),:); tr_labels = labels(set_users~=users(user)); %train on all but one subject
    test_set = dataset(set_users==users(user),:); te_labels = labels(set_users==users(user)); %test on remaining subject
    
    cp = classperf(te_labels);
    
    left = KMeans(kmeans_clusters,size(train_set,2)); left.train(train_set(tr_labels==1));  %train kmeans for left and right
    right = KMeans(kmeans_clusters,size(train_set,2)); right.train(train_set(tr_labels==2));
    f = (min(left.getEuclideanDistance(test_set)) > min(right.getEuclideanDistance(test_set))) + 1; %classify on min distance
    classperf(cp,f);
    
    kb_acc(user,:) = [cp.CorrectRate,cp.Sensitivity,cp.Specificity,sum(diag(cp.DiagnosticTable)),sum(sum(cp.DiagnosticTable))];
end
% test significance calculated from theoretical binomial distribution with
% mean 0.5
k_bp = binocdf(kb_acc(:,4), kb_acc(:,5),0.5,'upper');

%% Test Gaussian mixture model within subject
'Gaussian within subject'
gw_acc = zeros(size(users,2),5);
for user=1:size(users,2)
    ind = set_users==users(user);
    subset = dataset(ind,:);
    N = size(subset,1); K=N;
    sublabels = labels(ind);
    
    indices = crossvalind('Kfold',N,K);
    cp = classperf(sublabels);
    for i=1:size(indices)
        train_set = subset(indices ~= i,:); tr_labels = sublabels(indices ~= i);%train on all but one datapoints
        test_set = subset(indices == i,:); te_labels = sublabels(indices == i); %test on remaining data point
        
        left = GaussianEM(gmm_clusters,size(train_set,2),'Left'); left.train(train_set(tr_labels==1,:),gmm_iter,0,0,2,4);
        right = GaussianEM(gmm_clusters,size(train_set,2),'Right'); right.train(train_set(tr_labels==2,:),gmm_iter,0,0,2,4);
        lp = left.getLikelihood(test_set); rp = left.getLikelihood(test_set);
        f = datasample(find([lp,rp] == max([lp,rp])),1,'Replace',false); %classify on highest likelihood, random if p-values are 0
        classperf(cp,f,indices == i);
    end
    gw_acc(user,:) = [cp.CorrectRate,cp.Sensitivity,cp.Specificity,sum(diag(cp.DiagnosticTable)),sum(sum(cp.DiagnosticTable))];
end
% test significance
g_wp = binocdf(gw_acc(:,4), gw_acc(:,5),0.5,'upper');

%% Test Gaussian mixture model between subject
'Gaussian between subject'
gb_acc = zeros(size(users,2),5);
for user=1:size(users,2)
    train_set = dataset(set_users~=users(user),:); tr_labels = labels(set_users~=users(user));%train on all but one subject
    test_set = dataset(set_users==users(user),:); te_labels = labels(set_users==users(user)); %test on remaining subject
    
    cp = classperf(te_labels);
    
    left = GaussianEM(gmm_clusters,size(train_set,2),'Left'); left.train(train_set(tr_labels==1,:),gmm_iter,0,0,2,4);
    right = GaussianEM(gmm_clusters,size(train_set,2),'Right'); right.train(train_set(tr_labels==2,:),gmm_iter,0,0,2,4);
    lp = left.getLikelihood(test_set); rp = left.getLikelihood(test_set);
    B = [lp,rp] == repmat(max([lp,rp],[],2),1,2);
    f = zeros(size(B,1),1);
    for i=1:size(f,1)
        f(i) = datasample(find(B(i,:)),1,'Replace',false);%classify on highest likelihood, random if p-values are 0
    end
    classperf(cp,f);
    
    gb_acc(user,:) = [cp.CorrectRate,cp.Sensitivity,cp.Specificity,sum(diag(cp.DiagnosticTable)),sum(sum(cp.DiagnosticTable))];
end
g_bp = binocdf(gb_acc(:,4), gb_acc(:,5),0.5,'upper');

%% Test logistic regression within subject
'Logistic Regression within subject'
warning('off','all');
lrw_acc = zeros(size(users,2),5);
for user=1:size(users,2)
    ind = set_users==users(user);
    subset = dataset(ind,:);
    N = size(subset,1); K=N;
    sublabels = labels(ind);
    
    indices = crossvalind('Kfold',N,K);
    cp = classperf(sublabels);
    for i=1:size(indices)
        train_set = subset(indices ~= i,:); tr_labels = sublabels(indices ~= i);%train on all but one datapoints
        test_set = subset(indices == i,:); te_labels = sublabels(indices == i); %test on remaining data point
        
        B = glmfit(train_set,tr_labels-1,'binomial'); %fit logistic regression to it (binary case)
        f = round(glmval(B,test_set,'logit'))+1;
        classperf(cp,f,indices == i);
    end
    lrw_acc(user,:) = [cp.CorrectRate,cp.Sensitivity,cp.Specificity,sum(diag(cp.DiagnosticTable)),sum(sum(cp.DiagnosticTable))];
end
% test significance
lr_wp = binocdf(lrw_acc(:,4), lrw_acc(:,5),0.5,'upper');

%% Test Logistic regression between subject
'Logistic Regression between subject'
lrb_acc = zeros(size(users,2),5);
for user=1:size(users,2)
    train_set = dataset(set_users~=users(user),:); tr_labels = labels(set_users~=users(user));%train on all but one subject
    test_set = dataset(set_users==users(user),:); te_labels = labels(set_users==users(user)); %test on remaining subject
    
    cp = classperf(te_labels);
    
    B = glmfit(train_set,tr_labels-1,'binomial'); %fit logistic regression to it (binary case)
    f = round(glmval(B,test_set,'logit'))+1;
    classperf(cp,f);
    
    lrb_acc(user,:) = [cp.CorrectRate,cp.Sensitivity,cp.Specificity,sum(diag(cp.DiagnosticTable)),sum(sum(cp.DiagnosticTable))];
end
lr_bp = binocdf(lrb_acc(:,4), lrb_acc(:,5),0.5,'upper');

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
        train_set = subset(:,:,indices ~= i); tr_labels = sublabels(indices ~= i);%train on all but one datapoints
        test_set = subset(:,:,indices == i); te_labels = sublabels(indices == i); %test on remaining data point
        
        [clsfr,~,~,~] = train_ersp_clsfr(train_set,tr_labels,opt); %train standard ersp classifier
        f = classifyEpoch(test_set,clsfr);
        classperf(cp,f,indices==i);
    end
    erspw_acc(user,:) = [cp.CorrectRate,cp.Sensitivity,cp.Specificity,sum(diag(cp.DiagnosticTable)),sum(sum(cp.DiagnosticTable))];
end
% test significance
ersp_wp = binocdf(erspw_acc(:,4), erspw_acc(:,5),0.5,'upper');

%% Test ERSP classifier between subject
'ERSP classifier between subject'
erspb_acc = zeros(size(users,2),5);
for user=1:size(users,2)
    train_set = original(:,:,set_users~=users(user)); tr_labels = labels(set_users~=users(user));%train on all but one subject
    test_set = original(:,:,set_users==users(user)); te_labels = labels(set_users==users(user)); %test on remaining subject
    
    cp = classperf(te_labels);
    
    [clsfr,~,~,~] = train_ersp_clsfr(train_set,tr_labels,opt); %train standard ersp classifier
    f = classifyEpoch(test_set,clsfr);
    classperf(cp,f);
    
    erspb_acc(user,:) = [cp.CorrectRate,cp.Sensitivity,cp.Specificity,sum(diag(cp.DiagnosticTable)),sum(sum(cp.DiagnosticTable))];
end
ersp_bp = binocdf(erspb_acc(:,4), erspb_acc(:,5),0.5,'upper');

%% Plot between subject diagrams
names = cell(size(users));
for i=1:size(names,2)
    names{i} = ['Subject ',num2str(users(i))];
end

figure; hold on;
Y = [kb_acc(:,1),gb_acc(:,1),lrb_acc(:,1),erspb_acc(:,1),]; %performance on each classifier
p = [k_bp,g_bp,lr_bp,ersp_bp]'; %significance
h = bar(Y,'hist');
x=cell2mat(get(h,'Xdata'));
y=cell2mat(get(h,'Ydata'));

%draw significance labels with only 20 lines of code (yeah matlab woohoo)!
xcenter = 0.5*(x(2:4:end,:)+x(3:4:end,:));
ytop = y(2:4:end,:);
for i = 1:size(ytop,2)
    for j = 1:size(ytop,1)
        t='';pval = p(j,i);
        if pval < 0.001
            t = '***';
        elseif pval < 0.01
            t = '**';
        elseif pval < 0.1
            t = '*';
        end
        t = text(xcenter(j, i),ytop(j, i)+0.01, t); %plot significance asterisks above bars
        t.FontSize = 20;
        t.HorizontalAlignment = 'center';
    end
end
plot(0:size(names,2)+1,ones(size(names,2)+2,1)*0.5,'r','LineWidth',3);
legend('KMeans','Gaussian Mixture model','Logistic regression','ERSP classifier','chance level');
set(gca, 'XTickLabel',names, 'XTick',1:numel(names));
title('Between subject');
xlim([0.5 size(names,2)+0.5]); ylim([0 1]);

%% Plot within subject diagrams
figure; hold on;
Y = [kw_acc(:,1),gw_acc(:,1),lrw_acc(:,1),erspw_acc(:,1)]; %performance on each classifier
p = [k_wp,g_wp,lr_wp,ersp_wp]'; %significance
h = bar(Y,'hist');
x=cell2mat(get(h,'Xdata'));
y=cell2mat(get(h,'Ydata'));

%draw significance labels with only 20 lines of code (yeah matlab woohoo)!
xcenter = 0.5*(x(2:4:end,:)+x(3:4:end,:));
ytop = y(2:4:end,:);
for i = 1:size(ytop,2)
    for j = 1:size(ytop,1)
        t='';pval = p(j,i);
        if pval < 0.001
            t = '***';
        elseif pval < 0.01
            t = '**';
        elseif pval < 0.1
            t = '*';
        end
        t = text(xcenter(j, i),ytop(j, i)+0.01, t); %plot significance asterisks above bars
        t.FontSize = 20;
        t.HorizontalAlignment = 'center';
    end
end
plot(0:size(names,2)+1,ones(size(names,2)+2,1)*0.5,'r','LineWidth',3);
legend('KMeans','Gaussian Mixture model','Logistic regression','ERSP classifier','chance level');
set(gca, 'XTickLabel',names, 'XTick',1:numel(names));
title('Within subject');
xlim([0.5 size(names,2)+0.5]); ylim([0 1]);

%% Visualization
figure;
[X,~,~,~] = preproc_ersp(original,opt);
c1 = mean(X(:,:,labels(:,1)==1),3);
c2 = mean(X(:,:,labels(:,1)==2),3);
for i=1:21
    subplot(3,7,i); hold on;
    plot(c1(i,:)); plot(c2(i,:)); legend('l','r');
    title(channel_names(i,:));
end