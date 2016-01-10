clear all; clc;
load('dataset/left.mat');
load('dataset/right.mat');
load('dataset/baselines.mat');

%% Settings for creation of train and test set
users_ratio = 0.4; %percentage of users for train set
bsamples = 5; %number of baselines per user
trial_ratio = 0.5; %percentage of trials for use in train set
fs = 160; %sampling frequency of EEG cap
T = 2; %number of seconds in sample
pca_th = 15; %select the components which explain at most 80% of the variation of the data
max_frequency = 26; %maximum frequency of signals to analyze
min_frequency = 8;
channels = [8:14 18 16 20 2 6];
%% Create train and test set
N = size(left,1); %number of users in total
samples = T*fs;
users_train = sort(randperm(size(left,1),floor(users_ratio*N)));

train = zeros(size(channels,2),samples,2); tr = 1;
test_same = zeros(size(channels,2),samples,2); tes = 1; %samples coming from the same users as in train, but different trials
test_different = zeros(size(channels,2),samples,2); ted = 1;  %samples coming from different users as in train
labelstr = zeros(2,1); %left=1, right=2, baseline=3
labelstes = zeros(2,1);
labelsted = zeros(2,1);

for user = 1:N
    if (sum(users_train==user) > 0)
        for code=1:2
            if (code == 1)
                set = left{user,1};
                train_trials = sort(randperm(size(set,1),floor(trial_ratio*size(set,1))));
            elseif (code == 2)
                set = right{user,1};
                train_trials = sort(randperm(size(set,1),floor(trial_ratio*size(set,1))));
            end
            
            ntrials = size(set,1);
            for trial=1:ntrials
                sz = size(set{trial,1},2);
                start = ceil(rand*(sz-samples-1));
                
                if (sum(train_trials==trial) > 0)
                    train(:,:,tr) = set{trial,1}(channels,start:start+samples-1);
                    labelstr(tr) = code;
                    tr = tr+1;
                else
                    test_same(:,:,tes) = set{trial,1}(channels,start:start+samples-1);
                    labelstes(tes) = code;
                    tes = tes+1;
                end
            end
        end
        
        %baselines
        set = baselines{user,1};
        ntrials = size(set,1);
        sz = size(set,2);
        for i=1:bsamples
            start = ceil(rand*(sz-samples-1));
            train(:,:,tr) = set(channels,start:start+samples-1);
            labelstr(tr) = 3;
            tr = tr+1;
        end
    else
        for code=1:2
            if (code == 1)
                set = left{user,1};
            elseif (code == 2)
                set = right{user,1};
            end
            
            ntrials = size(set,1);
            for trial=1:ntrials
                sz = size(set{trial,1},2);
                start = ceil(rand*(sz-samples-1));
                test_different(:,:,ted) = set{trial,1}(channels,start:start+samples-1);
                labelsted(ted) = code;
                ted = ted+1;
            end
        end
        
        %baselines
        set = baselines{user,1};
        ntrials = size(set,1);
        sz = size(set,2);
        for i=1:bsamples
            start = ceil(rand*(sz-samples-1));
            test_different(:,:,ted) = set(channels,start:start+samples-1);
            labelsted(ted) = 3;
            ted = ted+1;
        end
    end
end

%% perform the preprocessing on the training data
opt = struct('fs',fs,'visualize',0,'badchrm',0,'badtrrm',0,'spatialfilter','none'); %preprocessing options
[~,train_set,mu,coeff,freq,latent] = train_preprocessing(train, fs, pca_th, opt,min_frequency, max_frequency);
%data is fft data, train_set is data transformed to pca space

% perform the preprocessing on the test data
[~,test_same_set] = test_preprocessing(test_same, fs, opt,min_frequency,max_frequency, mu, coeff);
[~,test_different_set] = test_preprocessing(test_different, fs, opt,min_frequency, max_frequency, mu, coeff);
%% Export the files
save('dataset/processedDataset.mat','train_set', 'test_same_set', 'test_different_set', 'labelstr', 'labelstes', 'labelsted', 'freq');