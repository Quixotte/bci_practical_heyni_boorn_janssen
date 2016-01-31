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

%% Test ERSP classifier between subject
'ERSP classifier between subject'
N = size(users,2);
erspb_acc = zeros(N,5);
for user=1:size(users,2)
    user
    train_set = original(:,:,set_users~=users(user)); tr_labels = labels(set_users~=users(user));
    test_set = original(:,:,set_users==users(user)); te_labels = labels(set_users==users(user));
    
    cp = classperf(te_labels);
    [clsfr,~,~,~] = train_ersp_clsfr(train_set,tr_labels,opt);
    f = classifyEpoch(test_set,clsfr);
    classperf(cp,f);
    
    erspb_acc(user,:) = [cp.CorrectRate,cp.Sensitivity,cp.Specificity,sum(diag(cp.DiagnosticTable)),sum(sum(cp.DiagnosticTable))];
end
ersp_bp = binocdf(erspb_acc(:,4), erspb_acc(:,5),0.5,'upper');

%% Test adaptive classifier and plot it (between subject)
'Adaptive classifier between subject'
ad_acc = zeros(size(users,2),5);
for user=1:size(users,2)
    user
    %create train and test sets (leave one out crossvalidation)
    train_set = original(:,:,set_users~=users(user)); tr_labels = labels(set_users~=users(user));
    test_set = original(:,:,set_users==users(user)); te_labels = labels(set_users==users(user));
    
    cp = classperf(te_labels);
    
    %train the classifiers on the specified users
    [clsfr,~,~,~] = train_ersp_clsfr(train_set,tr_labels,opt);
    f = classifyEpoch(test_set,clsfr);
    classperf(cp,f);
    linclasses = zeros(0,0); %classification result from ERSP classifier
    classified = zeros(0,0); %weighted average classifications
    glmset = zeros(0,0); weights = zeros(0,0); %set of training samples for glm and weights
    default = erspb_acc(user,1); %the standard performance of ersp classifier on this user
    S = size(test_set,3);
    
    for i=1:S
        sample = test_set(:,:,i);
        c = classifyEpoch(sample,clsfr); %get ERSP classifier
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
    classperf(cp,classified);
    
    ad_acc(user,:) = [cp.CorrectRate,cp.Sensitivity,cp.Specificity,sum(diag(cp.DiagnosticTable)),sum(sum(cp.DiagnosticTable))];
end
ad_bp = binocdf(ad_acc(:,4), ad_acc(:,5),0.5,'upper'); %does this classifier perform better than chance?

%%
figure; hold on; %plot bars with significance asterisks
Y = [ad_acc(:,1),erspb_acc(:,1)];
p = [ad_bp,ersp_bp]';
h = bar(Y,'hist');

%draw significance labels with only 20 lines of code (yeah matlab woohoo)!
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
title(['Within subject, p = ',num2str(signrank(erspb_acc(:,4),ad_acc(:,4)))]);
xlim([0.5 size(names,2)+0.5]); ylim([0 1]);