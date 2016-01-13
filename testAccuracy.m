clear all; clc;
load('dataset/processedDataset.mat');

%% Create clustering classifiers and train
IND = randperm(size(train_set,1)); %randomize training data
train_set = train_set(IND,:);
labelstr = labelstr(IND);
clusters = 20;

Left = KMeans(clusters,size(train_set,2));
Right = KMeans(clusters,size(train_set,2));
Baseline = KMeans(clusters,size(train_set,2));

for i=1:size(train_set,1)
    i
    switch labelstr(i)
        case 1, Left.addDataPoint(train_set(i,:));
        case 2, Right.addDataPoint(train_set(i,:));
        case 3, Baseline.addDataPoint(train_set(i,:));
    end
end

%% Test on train set
SET = train_set;
LABELS = labelstr;
S = size(SET,1);
conf = zeros(3);
predictions = zeros(S,1);
five = @(x) x(1,1);
for i=1:S
    distance = [five(sort(Left.getEuclideanDistance(SET(i,:)))),five(sort(Right.getEuclideanDistance(SET(i,:)))),...
        five(sort(Baseline.getEuclideanDistance(SET(i,:))))];
    predictions(i) = find(distance == min(distance));
    conf(LABELS(i),predictions(i)) = conf(LABELS(i),predictions(i)) + 1;
end
conf
correct = sum(predictions==LABELS)/S

%%
i=8;
d1 = sort(Left.getEuclideanDistance(SET(i,:)));
d2 = sort(Right.getEuclideanDistance(SET(i,:)));
d3 = sort(Baseline.getEuclideanDistance(SET(i,:)));