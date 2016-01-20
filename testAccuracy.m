clear all; clc;
load('dataset/processedDataset.mat');

%% Create clustering classifiers and train with KMEANS
IND = randperm(size(train_set,1)); %randomize training data
train_set = train_set(IND,:);
labelstr = labelstr(IND);
K = 20;

Left = KMeans(K,size(train_set,2));
Right = KMeans(K,size(train_set,2));
Baseline = KMeans(K,size(train_set,2));

for i=1:size(train_set,1)
    i
    switch labelstr(i)
        case 1, Left.addDataPoint(train_set(i,:));
        case 2, Right.addDataPoint(train_set(i,:));
        case 3, Baseline.addDataPoint(train_set(i,:));
    end
end
%% Test on train set KMEANS
SET = test_same_set;
LABELS = labelstes;
S = size(SET,1);
conf = zeros(3);
predictions = zeros(S,1);
five = @(x) x(1,1);
for i=1:S
    distance = [min(Left.getEuclideanDistance(SET(i,:))),min(Right.getEuclideanDistance(SET(i,:))),...
        min(Baseline.getEuclideanDistance(SET(i,:)))];
    predictions(i) = find(distance == min(distance));
    conf(LABELS(i),predictions(i)) = conf(LABELS(i),predictions(i)) + 1;
end
conf
correct = sum(predictions==LABELS)/S

%% Create Gaussian clustering

L = train_set(labelstr==1,:);
R = train_set(labelstr==2,:);
SET = train_set(labelstr<3,:);
LABELS = labelstr(labelstr<3);

SET2 = test_same_set(labelstes<3,:);
LABELS2 = labelstes(labelstes<3);
Iter = 1:5:20;
Clusters = 1:5:20;

table = zeros(size(Iter,2),size(Clusters,2));
self = zeros(size(Iter,2),size(Clusters,2));
for K = 1:size(Clusters,2)
    for MaxIter = 1:size(Iter,2);
        [K,MaxIter]
        
        Left = GaussianEM(Clusters(K),size(train_set,2),'Left');
        Right = GaussianEM(Clusters(K),size(train_set,2),'Right');
        % Baseline = GaussianEM(K,size(train_set,2),'Nothing');
        %
        Left.train(L,Iter(MaxIter),0,0,2,4);
        Right.train(R,Iter(MaxIter),0,0,2,4);
        % Baseline.train(train_set(labelstr==3,:),MaxIter,1,1,1,10000);
        
        S = size(SET,1);
        conf = zeros(3);
        predictions = zeros(S,1);
        for i=1:S
            probability = [max(Left.getLikelihood(SET(i,:))),max(Right.getLikelihood(SET(i,:)))];
            predictions(i) = datasample(find(probability == max(probability)),1,'Replace',false);
            conf(LABELS(i),predictions(i)) = conf(LABELS(i),predictions(i)) + 1;
        end
        correct = sum(predictions==LABELS)/S;
        self(K,MaxIter) = correct;
        
        % Test on train set EM GAUSSIAN
        
        S = size(SET2,1);
        conf = zeros(3);
        predictions = zeros(S,1);
        for i=1:S
            probability = [max(Left.getLikelihood(SET2(i,:))),max(Right.getLikelihood(SET2(i,:)))];
            predictions(i) = datasample(find(probability == max(probability)),1,'Replace',false);
            conf(LABELS2(i),predictions(i)) = conf(LABELS2(i),predictions(i)) + 1;
        end
        conf
        correct = sum(predictions==LABELS2)/S
        table(K,MaxIter) = correct;
    end
end