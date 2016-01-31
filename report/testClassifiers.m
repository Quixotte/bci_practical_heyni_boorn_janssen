clear all; clc;
load('dataset/ch_pos.mat'); %load eeg channel position
load('dataset/left.mat'); %load data for the left hand
load('dataset/right.mat'); %load data for the right hand
users = [42,32,7,53,54];
channels = 1:21;
[original, labels, set_users] = generateDatasets(left(1:100,:),right(1:100,:),users,2,channels,0);

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
clusters = 5;
kw_acc = zeros(size(users,2),5);
for user=1:size(users,2)
    ind = set_users==users(user);
    subset = dataset(ind,:);
    N = size(subset,1); K=N;
    sublabels = labels(ind);
    
    indices = crossvalind('Kfold',N,K);
    cp = classperf(sublabels);
    for i=1:size(indices)
        train_set = subset(indices ~= i,:); tr_labels = sublabels(indices ~= i);
        test_set = subset(indices == i,:); te_labels = sublabels(indices == i);
        
        left = KMeans(clusters,size(train_set,2)); left.train(train_set(tr_labels==1));
        right = KMeans(clusters,size(train_set,2)); right.train(train_set(tr_labels==2));
        %closest point is the best estimate
        f = (min(left.getEuclideanDistance(test_set)) > min(right.getEuclideanDistance(test_set))) + 1;
        classperf(cp,f,indices==i);
    end
    kw_acc(user,:) = [cp.CorrectRate,cp.Sensitivity,cp.Specificity,sum(diag(cp.DiagnosticTable)),sum(sum(cp.DiagnosticTable))];
end
% test significance calculated from theoretical binomial distribution with
% mean 0.5
k_wp = binocdf(kw_acc(:,4), kw_acc(:,5),0.5,'upper');

%% Test Kmeans between subject
'KMeans between subject'
clusters = 5;
kb_acc = zeros(size(users,2),5);
for user=1:size(users,2)
    train_set = dataset(set_users~=users(user),:); tr_labels = labels(set_users~=users(user));
    test_set = dataset(set_users==users(user),:); te_labels = labels(set_users==users(user));
    
    cp = classperf(te_labels);
    
    left = KMeans(clusters,size(train_set,2)); left.train(train_set(tr_labels==1));
    right = KMeans(clusters,size(train_set,2)); right.train(train_set(tr_labels==2));
    f = (min(left.getEuclideanDistance(test_set)) > min(right.getEuclideanDistance(test_set))) + 1;
    classperf(cp,f);
    
    kb_acc(user,:) = [cp.CorrectRate,cp.Sensitivity,cp.Specificity,sum(diag(cp.DiagnosticTable)),sum(sum(cp.DiagnosticTable))];
end
% test significance calculated from theoretical binomial distribution with
% mean 0.5
k_bp = binocdf(kb_acc(:,4), kb_acc(:,5),0.5,'upper');

%% Test Gaussian mixture model within subject
'Gaussian within subject'
clusters = 10;
iter = 1;
gw_acc = zeros(size(users,2),5);
for user=1:size(users,2)
    ind = set_users==users(user);
    subset = dataset(ind,:);
    N = size(subset,1); K=N;
    sublabels = labels(ind);
    
    indices = crossvalind('Kfold',N,K);
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

%% Test Gaussian mixture model between subject
'Gaussian between subject'
clusters = 5;
iter = 1;
gb_acc = zeros(size(users,2),5);
for user=1:size(users,2)
    train_set = dataset(set_users~=users(user),:); tr_labels = labels(set_users~=users(user));
    test_set = dataset(set_users==users(user),:); te_labels = labels(set_users==users(user));
    
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

%% Test Logistic regression between subject
'Logistic Regression between subject'
lrb_acc = zeros(size(users,2),5);
for user=1:size(users,2)
    train_set = dataset(set_users~=users(user),:); tr_labels = labels(set_users~=users(user));
    test_set = dataset(set_users==users(user),:); te_labels = labels(set_users==users(user));
    
    cp = classperf(te_labels);
    
    B = glmfit(train_set,tr_labels-1,'binomial');
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

%% Plot between subject diagrams
names = cell(size(users));
for i=1:size(names,2)
    names{i} = ['Subject ',num2str(users(i))];
end

figure; hold on;
Y = [kb_acc(:,1),gb_acc(:,1),lrb_acc(:,1),erspb_acc(:,1),];
p = [k_bp,g_bp,lr_bp,ersp_bp]';
h = bar(Y,'hist');
x=cell2mat(get(h,'Xdata'));
y=cell2mat(get(h,'Ydata'));

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
Y = [kw_acc(:,1),gw_acc(:,1),lrw_acc(:,1),erspw_acc(:,1)];
p = [k_wp,g_wp,lr_wp,ersp_wp]';
h = bar(Y,'hist');
x=cell2mat(get(h,'Xdata'));
y=cell2mat(get(h,'Ydata'));

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

%% Test adaptive classifier and plot it (between subject)
'Adaptive classifier between subject'
ad_acc = zeros(size(users,2),5);
for user=1:size(users,2)
    user
    %create train and test sets (leave one out crossvalidation)
    train_set = original(:,:,set_users~=users(user)); tr_labels = labels(set_users~=users(user));
    test_set = original(:,:,set_users==users(user)); te_labels = labels(set_users==users(user));
    
    cp = classperf(te_labels);
    [clsfr,~,~,~] = train_ersp_clsfr(train_set,tr_labels,opt); %train the classifiers on the specified users
    linclasses = zeros(0,0); %classification result from ERSP classifier
    classified = zeros(0,0); %weighted average classifications
    glmset = zeros(0,0); weights = zeros(0,0); %set of training samples for glm and weights
    default = erspb_acc(user,1); %the standard performance of ersp classifier on this user
    S = size(test_set,3);
    
    for i=1:S
        sample = test_set(:,:,i);
        c = apply_ersp_clsfr(sample,clsfr); %get ERSP classifier
        if (c < 0) c = 2; else c=1; end;
        linclasses(i) = c;
        
        if (i<10) %skip the first samples to get a feel of the data
            classified(i,:) = c; %take default classification
            weights(i,:) = default;
            glmset(i,:) = sample(:);
        else
            B = glmfit(glmset,(classified-1),'binomial','weights',weights); %train glm on all instances
            self = glmval(B,sample(:)','logit')+1; %get output from glm
            w = i/S * 1.3; %apply weighted learning
            weights(i,:) = (w+default)/2; %set certainty of classification
            classified(i,:) = round((self*w+c*default)/(w+default)); %take weighted average
            glmset(i,:) = sample(:);
        end
    end
    
    f = classifyEpoch(test_set,clsfr);
    classperf(cp,f);
    
    ad_acc(user,:) = [cp.CorrectRate,cp.Sensitivity,cp.Specificity,sum(diag(cp.DiagnosticTable)),sum(sum(cp.DiagnosticTable))];
end
ad_bp = binocdf(ad_acc(:,4), ad_acc(:,5),0.5,'upper'); %does this classifier perform better than chance?

figure; hold on; %plot bars with significance asterisks
Y = [ad_acc(:,1),erspb_acc(:,1)];
p = [ad_bp,ersp_bp]';
h = bar(Y,'hist');
x=cell2mat(get(h,'Xdata'));
y=cell2mat(get(h,'Ydata'));

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
        t = text(xcenter(j, i),ytop(j, i)+0.01, t);
        t.FontSize = 20;
        t.HorizontalAlignment = 'center';
    end
end
plot(0:size(names,2)+1,ones(size(names,2)+2,1)*0.5,'r','LineWidth',3);
legend('KMeans','Gaussian Mixture model','Logistic regression','ERSP classifier','chance level');
set(gca, 'XTickLabel',names, 'XTick',1:numel(names));
title(['Within subject, p = ',num2str(ranksum(erspb_acc(:,4),ad_acc(:,4)))]);
xlim([0.5 size(names,2)+0.5]); ylim([0 1]);