clear all; clc;
load('hector_data.mat');
[setHector,labelsHector] = getSet(windows);

load('data_stef_train.mat');
[setStef,labelsStef] = getSet(windows);

load('data_thomas_train.mat');
[setThomas,labelsThomas] = getSet(windows);