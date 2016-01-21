clear all; clc;
load('dataset/left_raw.mat');
load('dataset/right_raw.mat');
load('dataset/baselines_raw.mat');
load('dataset/ch_pos.mat')

% [42,32,7,53,54,2,49,56,94,48,62,22,26,60,31,83,29,15]
% weak [80,63,95,67]

%% Settings for creation of train and test set
users_ratio = 50/86; %percentage of users for train set
test_users = 5;
bsamples = 60; %number of baselines per user
trial_ratio = 0.8; %percentage of trials for use in train set
fs = 160; %sampling frequency of EEG cap
T = 1; %number of seconds in sample
pca_th = 0.99; %select the components which explain at most 80% of the variation of the data
ppca = 0;
frequency_band = [6 8 26 28];
channels = 1:64;%[2 6 8:14 16 18 20];
% Create train and test set
N = size(left_raw,1); %number of users in total
samples = T*fs;
users_train = [7];%sort(randperm(N,floor(users_ratio*N)));
users_test = 1:N;
users_test(users_train)=[];
users_test = datasample(users_test,test_users,'Replace',false);

train = zeros(size(channels,2),samples,2); tr = 1; train_users=zeros(0,1);
test_same = zeros(size(channels,2),samples,2); tes = 1; %samples coming from the same users as in train, but different trials
test_different = zeros(size(channels,2),samples,2); ted = 1;  %samples coming from different users as in train
test_same_users=zeros(0,1);
test_different_users=zeros(0,1);
baselines = zeros(size(channels,2),samples,1);
labelstr = zeros(2,1); %left=1, right=2, baseline=3
labelstes = zeros(2,1);
labelsted = zeros(2,1);

for user = 1:N
    if (sum(users_train == user) > 0)
        %baselines
%         set = baselines_raw{user,1};
%         sz = size(set,2);
%         b = zeros(size(channels,2),samples);
%         for i=1:bsamples
%             start = ceil(rand*(sz-samples-1));
%             b = b+set(channels,start:start+samples-1);
%         end
%         baselines(:,:,user) = b;
%         b = mean(baselines_raw{user,1},2);
%         b = repmat(b(channels,:),1,samples);
        
        for code=1:2
            if (code == 1)
                set = left_raw{user,1};
                train_trials = sort(randperm(size(set,1),floor(trial_ratio*size(set,1))));
            elseif (code == 2)
                set = right_raw{user,1};
                train_trials = sort(randperm(size(set,1),floor(trial_ratio*size(set,1))));
            end
            
            ntrials = size(set,1);
            for trial=1:ntrials
                sz = size(set{trial,1},2);
                start = ceil(rand*(sz-samples-1));
                
                if (sum(train_trials==trial) > 0)
                    train(:,:,tr) = set{trial,1}(channels,start:start+samples-1);
                    labelstr(tr) = code;
                    train_users(tr,1) = user;
                    tr = tr+1;
                else
                    test_same(:,:,tes) = set{trial,1}(channels,start:start+samples-1);
                    labelstes(tes) = code;
                    test_same_users(tes,1) = user;
                    tes = tes+1;
                end
            end
        end
    elseif sum(users_test == user) > 0
        %baselines
        set = baselines_raw{user,1};
        sz = size(set,2);
        b = zeros(size(channels,2),samples);
        for i=1:bsamples
            start = ceil(rand*(sz-samples-1));
            b = b+set(channels,start:start+samples-1);
        end
        baselines(:,:,user) = b;
        b = mean(baselines_raw{user,1},2);
        b = repmat(b(channels,:),1,samples);
        
        for code=1:2
            if (code == 1)
                set = left_raw{user,1};
            elseif (code == 2)
                set = right_raw{user,1};
            end
            
            ntrials = size(set,1);
            for trial=1:ntrials
                sz = size(set{trial,1},2);
                start = ceil(rand*(sz-samples-1));
                test_different(:,:,ted) = set{trial,1}(channels,start:start+samples-1);
                labelsted(ted) = code;
                test_different_users(ted,1) = user;
                ted = ted+1;
            end
        end
    end
end

% perform the preprocessing on the training data
opt = struct('fs',fs,'visualize',0,'badchrm',0,'badtrrm',0,'spatialfilter','slap','detrend',...
    1,'ch_pos',ch_pos(:,channels),'freqband',frequency_band); %preprocessing options 'spatialfilter','none'
trainl = train(:,:,labelstr==1); train_usersl = train_users(labelstr==1);
[Dl,train_setl,mul,coeffl] = train_preprocessing_ersp(trainl,opt,pca_th,ppca);
% [Datal,train_setl,mul,coeffl,~,~,Dl] = train_preprocessing_ersp(trainl, fs, pca_th, opt,min_frequency, max_frequency);
'ok1'
trainr = train(:,:,labelstr==2); train_usersr = train_users(labelstr==2);
[Dr,train_setr,mur,coeffr] = train_preprocessing_ersp(trainr,opt,pca_th,ppca);
% [Datar,train_setr,mur,coeffr,freq,latent,Dr] = train_preprocessing_ersp(trainr, fs, pca_th, opt,min_frequency, max_frequency);
% %data is fft data, train_set is data transformed to pca space
% 'ok2'
% % % perform the preprocessing on the test data
tesl = test_same(:,:,labelstes==1); test_same_usersl = test_same_users(labelstes==1);
[test_same_setl,~,~,~]  = train_preprocessing_ersp(tesl,opt,pca_th,ppca);
% [test_same_setl,test_same_setlP] = test_preprocessing_ersp(tesl, fs, opt,min_frequency,max_frequency, mul, coeffl);
% 'ok3'
tesr = test_same(:,:,labelstes==2); test_same_usersr = test_same_users(labelstes==2);
[test_same_setr,~,~,~] = train_preprocessing_ersp(tesr,opt,pca_th,ppca);
% [test_same_setr,test_same_setrP] = test_preprocessing_ersp(tesr, fs, opt,min_frequency,max_frequency, mur, coeffr);
% [~,test_different_set] = test_preprocessing(test_different, fs, opt,min_frequency, max_frequency, mu, coeff);
% 'ok4'
% tedl = test_different(:,:,labelsted==1); test_different_usersl = test_different_users(labelsted==1);
% [test_different_setl,test_different_setlP] = test_preprocessing_ersp(tedl, fs, opt,min_frequency,max_frequency, mul, coeffl);
% 'ok5'
% tedr = test_different(:,:,labelsted==2); test_different_usersr = test_different_users(labelsted==2);
% [test_different_setr,test_different_setrP] = test_preprocessing_ersp(tedr, fs, opt,min_frequency,max_frequency, mur, coeffr);

'done!'
% Plot
% m1 = mean(train_set(labelstr==1,:),1); s1 = std(train_set(labelstr==1,:),1);
% m2 = mean(train_set(labelstr==2,:),1); s2 = std(train_set(labelstr==2,:),1);
% errorbar(m1,s1); hold on;
% errorbar(m2,s2);

%% Export the files
save('dataset/processedDataset_raw.mat','train_setl','train_setr', 'tesl','tesr', 'labelstr',...
    'labelstes', 'labelsted', 'freq','train_usersl','train_usersr','test_same_usersl','test_same_usersr',...
    'test_different_usersl', 'baselines','mul','mur','coeffl','coeffr','test_same_setl','test_same_setr',...
    'test_different_setl','test_different_setr','test_different_usersl','test_different_usersr');