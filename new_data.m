clear all; close all; clc;
load('hector_data.mat');
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
for trial=1:49
    d = remain(sessions==trial,:);
    for i=1:1:40
        c = d{i,1}.buf;
        train(:,:,index) = c(1:21,:); %only first 21 channels
        labelstr(index,:) = d{i,2};
        index = index+1;
    end
end
%% test on set
N = size(train,3);
K = 10;
IND = sort(crossvalind('Kfold', N, K)); %train on 90% test on the rest
cp1 = classperf(labelstr);
    opt = struct('fs',256,'visualize',0,'badchrm',0,'badtrrm',0,'spatialfilter','none','detrend',...
        1, 'freqband',[6 8 26 28]); %'ch_pos',ch_pos(:,channels)
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
save('dataset/hector_data_done.mat','train','labelstr');