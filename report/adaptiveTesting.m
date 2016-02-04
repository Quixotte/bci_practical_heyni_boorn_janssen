% this script loads the data sets, preprocesses it and test ERSP
% within-subject, ERSP between-subject and the adaptive classifier on this
% data set

clear all; clc;
load('data_hector_train.mat');
[setHector,labelsHector] = getSet(windows);

load('data_stef_train.mat');
[setStef,labelsStef] = getSet(windows);

load('data_thomas_train.mat');
[setThomas,labelsThomas] = getSet(windows);

SET = cat(3,setHector,setStef,setThomas); %concatenate the sets
LABELS = cat(2,labelsHector,labelsStef,labelsThomas);%concatenate the labels
USERS = [ones(900,1);ones(900,1)*2;ones(900,1)*3];
names = {'Héctor','Stef','Thomas'};

channel_names = ['FC5';'FC3';'FC1';'FCz';'FC2';'FC4';'FC6';...
    'C6 ';'C4 ';'C2 ';'Cz ';'C1 ';'C3 ';'C5 ';...
    'CP5';'CP3';'CP1';'CPz';'CP2';'CP4';'CP6'];
ch_pos = cellstr(channel_names);
opt = struct('fs',256,'visualize',0,'badchrm',0,'badtrrm',0,'spatialfilter','slap','detrend',...
    1, 'freqband',[6 8 26 28],'ch_pos',{ch_pos},'capFile','this_cap_best_cap.txt');

%% Test ERSP classifier between subject
'ERSP classifier between subject'
erspb_acc = zeros(3,5);
for user=1:3
    user
    train_set = SET(:,:,USERS~=user); tr_labels = LABELS(USERS~=user); %train on all but one user
    test_set = SET(:,:,USERS==user); te_labels = LABELS(USERS==user); %test on the remaining user
    
    cp = classperf(te_labels);
    [clsfr,~,~,~] = train_ersp_clsfr(train_set,tr_labels,opt);
    f = classifyEpoch(test_set,clsfr);
    classperf(cp,f);
    
    %calculate classifier performance
    erspb_acc(user,:) = [cp.CorrectRate,cp.Sensitivity,cp.Specificity,sum(diag(cp.DiagnosticTable)),sum(sum(cp.DiagnosticTable))];
end
ersp_bp = binocdf(erspb_acc(:,4), erspb_acc(:,5),0.5,'upper'); %calculate one-sided binomial test

%% Test ERSP classifier within subject
'ERSP classifier within subject'
erspw_acc = zeros(3,5);
K = 10;
for user=1:3
    user
    dataset = SET(:,:,USERS==user);
    labelstr = LABELS(USERS==user);
    
    IND = crossvalind('Kfold', size(dataset,3), K); %train on 90%, test on the rest
    cp = classperf(labelstr);
    for k=1:K
        test_ind = (IND == k); train_ind = ~test_ind;
        
        train_set = dataset(:,:,train_ind); train_labels = labelstr(train_ind,:); %train on 90% of data
        test_set = dataset(:,:,test_ind); test_labels = labelstr(test_ind,:); %test on remaining 10%
        
        [clsfr,~,~,~] = train_ersp_clsfr(train_set,train_labels,opt);
        f = classifyEpoch(test_set,clsfr);
        classperf(cp,f,test_ind);
    end
    %calculate classifier performance
    erspw_acc(user,:) = [cp.CorrectRate,cp.Sensitivity,cp.Specificity,sum(diag(cp.DiagnosticTable)),sum(sum(cp.DiagnosticTable))];
end
ersp_wp = binocdf(erspw_acc(:,4), erspw_acc(:,5),0.5,'upper');%calculate one-sided binomial test

%% Test adaptive classifier and plot it (between subject)
'Adaptive classifier between subject'
warning('off','all');
ad_acc = zeros(3,5);
for user=1:3
    user
    %create train and test sets (leave one out crossvalidation)
    train_set = SET(:,:,USERS~=user); tr_labels = LABELS(USERS~=user);
    test_set = SET(:,:,USERS==user); te_labels = LABELS(USERS==user);
    
    cp = classperf(te_labels);
    
    %train the classifiers on the specified users
    [clsfr,~,~,~] = train_ersp_clsfr(train_set,tr_labels,opt);
    linclasses = zeros(0,0); %classification result from ERSP classifier
    classified = zeros(0,0); %weighted average classifications
    glmset = zeros(0,0); weights = zeros(0,0); %set of training samples for glm and weights
    default = 0.5989;%the standard performance of ersp classifier on this user, optimized
    S = size(test_set,3);
    
    for i=1:S
        if (mod(i,50)==0) %training can be slow, so show intermediate output
            i
        end
        sample = test_set(:,:,i);
        s2 = preproc_ersp(sample,opt);
        c = classifyEpoch(sample,clsfr); %get ERSP classifier
        linclasses(i) = c;
        
        if (i<10) %skip the first samples to get a feel of the data
            classified(i,:) = c; %take default classification
            weights(i,:) = default;
            glmset(i,:) = s2(:);
        else
            B = glmfit(glmset,(classified-1),'binomial','weights',weights); %train glm on all instances
            self = glmval(B,s2(:)','logit')+1; %get output from glm
            w = i/S * 1.3; %apply weighted learning
            weights(i,:) = (w+default)/2; %set certainty of classification
            classified(i,:) = round((self*w+c*default)/(w+default)); %take weighted average
            glmset(i,:) = s2(:);
        end
    end
    classperf(cp,classified);
    
    %calculate classifier performance
    ad_acc(user,:) = [cp.CorrectRate,cp.Sensitivity,cp.Specificity,sum(diag(cp.DiagnosticTable)),sum(sum(cp.DiagnosticTable))];
end
ad_bp = binocdf(ad_acc(:,4), ad_acc(:,5),0.5,'upper'); %does this classifier perform better than chance?

%%
p = sum(erspb_acc(:,4))/sum(erspb_acc(:,5));
p = binocdf(sum(ad_acc(:,4)), sum(ad_acc(:,5)),p,'upper')
figure; hold on; %plot bars with significance asterisks
Y = [erspw_acc(:,1),erspb_acc(:,1),ad_acc(:,1)]; %performance of the classifiers
p = [ersp_wp,ersp_bp,ad_bp]'; %significance of classifiers
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
legend('Within subject ERSP','Between subject ERSP','Between subject adaptive classifier','chance level');
set(gca, 'XTickLabel',names, 'XTick',1:numel(names));
title('Classification comparisson');
xlim([0.5 size(names,2)+0.5]); ylim([0 1]);