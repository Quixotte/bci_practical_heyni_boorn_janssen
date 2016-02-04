%this script creates a classifier for use in the experiment. Change the
%subject_id to create a classifier for a different user.

clear all; clc;

subject_id = 1; %the subject for which the classifier is created

load('data_hector_train.mat');
[setHector,labelsHector] = getSet(windows);
load('data_stef_train.mat');
[setStef,labelsStef] = getSet(windows);
load('data_thomas_train.mat');
[setThomas,labelsThomas] = getSet(windows);

SET = cat(3,setHector,setStef,setThomas); %concatenate the sets
LABELS = cat(2,labelsHector,labelsStef,labelsThomas);%concatenate the labels
USERS = [ones(900,1);ones(900,1)*2;ones(900,1)*3];

channel_names = ['FC5';'FC3';'FC1';'FCz';'FC2';'FC4';'FC6';...
    'C6 ';'C4 ';'C2 ';'Cz ';'C1 ';'C3 ';'C5 ';...
    'CP5';'CP3';'CP1';'CPz';'CP2';'CP4';'CP6'];
ch_pos = cellstr(channel_names);
opt = struct('fs',256,'visualize',0,'badchrm',0,'badtrrm',0,'spatialfilter','slap','detrend',...
    1, 'freqband',[6 8 26 28],'ch_pos',{ch_pos},'capFile','this_cap_best_cap.txt');

[clsfr,~,~,~] = train_ersp_clsfr(SET(:,:,USERS~=subject_id),LABELS(USERS~=subject_id),opt);
save('classifierHector.mat','clsfr');