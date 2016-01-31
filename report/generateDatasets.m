function [ train, labelstr, train_users ] = generateDatasets( left, right, users, T, channels, PCA)
fs = 160; %sampling frequency of EEG cap

% Create train and test set
N = size(left,1); %number of users in total
samples = T*fs;
users_train = users;

train = zeros(size(channels,2),samples,2); tr = 1; train_users=zeros(0,1);
labelstr = zeros(2,1);

for user = 1:N
    if (any(users_train == user))
        for code=1:2
            if (code == 1)
                set = left{user,1};
            elseif (code == 2)
                set = right{user,1};
            end
            
            ntrials = size(set,3);
            for trial=1:ntrials
                sz = size(set(:,:,trial),2);
                start = round(sz/2-samples/2);
                
                train(:,:,tr) = set(channels,start:start+samples-1,trial);
                labelstr(tr) = code;
                train_users(tr,1) = user;
                tr = tr+1;
            end
        end
    end
end

