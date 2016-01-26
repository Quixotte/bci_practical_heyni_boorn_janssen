function [train,labelstr] = getSet(windows)
trials = cellfun(@(c) str2double(c),windows(:,3));
remain = windows(trials<55,:);
remain(:,3) = num2cell(trials(trials<55));
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
end