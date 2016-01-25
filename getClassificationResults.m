clear all; clc;
% load('dataset/left_raw.mat');
% load('dataset/right_raw.mat');
% load('dataset/baselines_raw.mat');
% load('dataset/ch_pos.mat');
load('dataset/processedDataset_raw.mat');

S = [42,32,7,53,54];

subjects = size(S,2);
acc = zeros(1,1);
n=1;
for s=1
    [s,n]
    % Classification results
    %subjects ordered from best to worst: ;
    users = S(1:s);
    set = train(:,:,ismember(train_users,users));
    labels = labelstr(ismember(train_users,users),:);
    
    ds = size(set,3);
    K = ds;
    
    IND = sort(crossvalind('Kfold', ds, K));
    cp1 = classperf(labels);
    
    channels = [2 6 8:14 16 18 20];
    opt = struct('fs',fs,'visualize',0,'badchrm',1,'badtrrm',1,'spatialfilter','slap','detrend',...
        1,'ch_pos',ch_pos(:,channels), 'freqband',frequency_band);
    
    for k=1:K
        test_ind = (IND == k); train_ind = ~test_ind;
        train_set = set(channels,:,train_ind);
        train_labels = labels(train_ind,:);
        test_set = set(channels,:,test_ind);
        test_labels = labels(test_ind,:);
        
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
        
        classperf(cp1,f,test_ind);
    end
    
    acc(1,s) = cp1.CorrectRate
end

%% train on first and classify on second
clear all; clc;
load('dataset/processedDataset_raw.mat');

users = [42,32,7,53,54,2,49];
acc = zeros(2,size(users,2));
for k=1:size(users,2)
    test_u = ismember(train_users,users(k));
    set = train(:,:,~test_u);
    labels = labelstr(~test_u,:);
    
    channels = [2 6 8:14 16 18 20];
    opt = struct('fs',fs,'visualize',0,'badchrm',0,'badtrrm',0,'spatialfilter','slap','detrend',...
        1,'ch_pos',ch_pos(:,channels), 'freqband',frequency_band);
    
    train_set = set(channels,:,:);
    train_labels = labels;
    test_set = train(channels,:,test_u);
    test_labels = labelstr(test_u,:);
    
    [clsfr,res,~,~] = train_ersp_clsfr(train_set,train_labels,opt);
    cp1 = classperf(test_labels);
    cp2 = classperf(test_labels);
    newLabels = zeros(0,0); newSet = zeros(0,0,0);
    
%     [A,~,~,~] = preproc_ersp(test_set,opt);
    A = reshape(test_set,size(test_set,1)*size(test_set,2),size(test_set,3));
%     B = glmfit(A',train_labels-1,'binomial','link','logit');
%     [C,~,~,~] = preproc_ersp(test_set,opt);
%     C = reshape(C,size(C,1)*size(C,2),size(C,3));
    
    tsn = size(test_set,3); logreg = zeros(0,0);
    linv = @(x) exp(x)./(exp(x)+1);
    cl_neg = 0; cl_pos = 0;
    for i=1:tsn
        cl = apply_ersp_clsfr(test_set(:,:,i),clsfr);
        if (cl < 0)
            cl = 2;
        else
            cl = 1;
        end
        newLabels(i,:) = cl;
        
        if (i<2)
            logres(i,:) = cl;
        else
            %             opt.nFold=i-1;
            %             [clsfr2,res,~,~] = train_ersp_clsfr(test_set(:,:,1:i-1),logres(1:i-1),opt);
            %             cl2 = apply_ersp_clsfr(test_set(:,:,i),clsfr2);
            %             if (cl2 < 0)
            %                 cl2 = 2;
            %             else
            %                 cl2 = 1;
            %             end
            %             logres(i,:) = round(cl2 + ((tsn-i)/tsn)*cl);
            B = glmfit(A(:,1:(i-1))',logres(1:(i-1))-1,'binomial','link','logit','weights',(1/tsn):(1/tsn):((i-1)/tsn));
            logres(i,:) = round(((glmval(B,A(:,i)','logit')+((tsn-i)/tsn)*(cl-1)))/2)+1;
        end
    end
    classperf(cp1,newLabels,1:size(test_labels,1));
    classperf(cp2,logres,1:size(test_labels,1));
    acc(1,k) = cp1.CorrectRate;
    acc(2,k) = cp2.CorrectRate;
end