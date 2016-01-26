clear all; close all; clc;
load('Hector_data.mat');
%%
trials = cellfun(@(c) str2double(c),windows(:,3));
remain = windows(trials<50,:);
remain(:,3) = num2cell(trials(trials<50));
remain(:,2) = num2cell(cellfun(@(c) str2double(c),remain(:,2)));

l = cell2mat(remain(:,2));
sessions = cell2mat(remain(:,3));

train = zeros(0,0,0);
labelstr = zeros(0,0);
index=1;
for trial=0:49
    d = remain(sessions==trial,:);
    for i=6:2:40
        c = d{i,1}.buf;
        train(:,:,index) = c(1:21,:); %only first 21 channels
        labelstr(index,:) = d{i,2};
        index = index+1;
    end
end
%%
channel_names = ['FC5';'FC3';'FC1';'FCz';'FC2';'FC4';'FC6';...
    'C6 ';'C4 ';'C2 ';'Cz ';'C1 ';'C3 ';'C5 ';...
    'CP5';'CP3';'CP1';'CPz';'CP2';'CP4';'CP6'];
ch_pos = cellstr(channel_names);
    opt = struct('fs',256,'visualize',0,'badchrm',0,'badtrrm',0,'spatialfilter','slap','detrend',...
        1, 'freqband',[6 8 26 28],'ch_pos',{ch_pos},'capFile','this_cap_best_cap.txt');

[clsfr,~,~,~] = train_ersp_clsfr(train,labelstr,opt);
save('classifier_Thomas.mat','clsfr','opt');
%% test on set
N = size(train,3);
K = 10;
IND = crossvalind('Kfold', N, K); %train on 90% test on the rest
cp1 = classperf(labelstr);
    for k=1:K
    test_ind = (IND == k); train_ind = ~test_ind;
    
    train_set = train(:,:,train_ind); train_labels = labelstr(train_ind,:);
    test_set = train(:,:,test_ind); test_labels = labelstr(test_ind,:);
    
    [clsfr,res,~,~] = train_ersp_clsfr(train_set,train_labels,opt);
    [f,fraw,p,X] = apply_ersp_clsfr(test_set,clsfr);
    
    for i=1:size(clsfr.spMx,2)
        if (clsfr.spMx(i) == -1)
            f(f < 0,:) = clsfr.spKey(i);
        elseif (clsfr.spMx(i) == 1)
            f(f >= 0,:) = clsfr.spKey(i);
        else
            'error!'
        end
    end
    
    classperf(cp1,f,test_ind)
end

%%
lm = reshape(train,size(train,1)*size(train,2),size(train,3));
endin = round(size(lm,2)*0.9);

trglm = lm(:,1:endin); trlabels = labelstr(1:endin)-1;
tesy = labelstr(endin+1:end);
B = glmfit(trglm',trlabels,'binomial');

cp = classperf(trlabels);
glmy = glmval(B,trglm','logit');
classperf(cp,round(glmy))
%%
save('dataset/hector_data_done.mat','train','labelstr');