clear all; clc;

%create two-class cluster KMeans
K = KMeans(2);

%add two known samples for initial clustering
m1 = [0 0];
m2 = [10 0];
K.addDataPoint(m1,1); %class 1
K.addDataPoint(m2,2); %class 2

%add extra random data points
for i=1:50
    K.addDataPoint(normrnd(m1,[2 2]));
    K.addDataPoint(normrnd(m2,[2 2]));
end

%get points based on clusters
C1 = K.DataPoints(K.Clusters==1,:);
C2 = K.DataPoints(K.Clusters==2,:);

%plot
figure; hold on;
h = plot(C1(:,1),C1(:,2),'*b');
k = plot(C2(:,1),C2(:,2),'+r');
l = plot(K.Mu(1,1),K.Mu(1,2),'xg');
m = plot(K.Mu(2,1),K.Mu(2,2),'xk');
legend([h,k,l,m],'Cluster 1','Cluster 2','Mean cluster 1','Mean cluster 2');

%% Linear regression
X = [ones(size(K.DataPoints,1),1) K.DataPoints];
Y = K.Clusters;
b = Y\X;

C1 = X(Y==1,:)*b';
C2 = X(Y==2,:)*b';

figure; hold on;
plot(C1); plot(C2); legend('Class 1','Class 2');

if (min(C1) > max(C2))
    boundary = 0.5*(min(C1) + max(C2));
else
    boundary = 0.5*(min(C2) + max(C1));
end
plot(ones(size(C1,1),1)*boundary);