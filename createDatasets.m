clear all; clc;
participants = dir('eegmmidb');
N = size(participants,1);
%Channels, datapoints, trials, Particpants
%left = zeros(64,641,24,25);
% right = zeros(64,641,24,25);
left = cell(N,1);
right = cell(N,1);

for participant = 3:N
    participant;
    filename = participants(participant).name
    load(strcat('eegmmidb/',filename,'/jf_prep/',filename,'_mm.mat'));
    
    [a_,b_,trials] = di.vals;
    l=1;
    r=1;
    lp = zeros(65,641,1);
    rp = zeros(65,641,1);
    
    for trial = 1:size(trials,2)
        trialIdentifier = int2str(trials(trial));
        trialIdentifier = trialIdentifier(1:2);
        if (strcmp(trialIdentifier,'30') || strcmp(trialIdentifier,'70') || strcmp(trialIdentifier,'11'))
            if strcmp(di(3).extra(trial).marker.type,'T1')
                lp(:,:,l) = X(:,:,trial);
                l = l+1;
            else
                rp(:,:,r) = X(:,:,trial);
                r = r+1;
            end
        end
    end
    
    left{participant-2} = lp;
    right{participant-2} = rp;
end

save('right.mat','right');
save('left.mat','left');