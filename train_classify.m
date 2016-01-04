%% Create synthetic training set (25 samples per class of 300 timepoints each a 250 Hz)
clear all;
datapoint = zeros(10,100,50);%channel, timepoints, sample

Fs = 250;
%T = 1/Fs;             % Sampling period
L = size(datapoint,2);            % Length of signal
C = size(datapoint,1);
S = size(datapoint,3);
T = 1/Fs;             % Sampling period
t = (0:L-1)*T;        % Time vector
pca_th = 0.75; %find the PCA components that explain 75% of the data
%nyquist = L/2;

for sample=1:S/2
    datapoint(:,:,sample) = 0.7*rand(C,L).*sin(2*pi*[50;50;51;52;48;41;50;50;50;50]*t)+2*randn(C,L);
end
for sample=S/2+1:S
    datapoint(:,:,sample) = 0.7*rand(C,L).*sin(2*pi*[20;20;21;22;18;11;20;20;20;20]*t)+2*randn(C,L);
end

%% Feature extraction
P1 = zeros(S,C,L/2+1);
for s=1:S
    for i=1:C
        Y = fft(datapoint(:,:,s));
        P2 = abs(Y./L);
        P1(s,i,:) = 2*P2(1:L/2+1);
        P1(s,i,2:end-1) = 2*P1(s,i,2:end-1);
    end
end

f = Fs*(0:(L/2))/L;

IND = find(f<=45); %filter out all frequencies above 45 Hz
P1 = P1(:,:,IND);
Data = P1(:,:);
classlabels = zeros(S,1); %adjust this for real data
classlabels(1:S/2) = 1;
classlabels(S/2+1:end) = 2;
Data = [Data classlabels]; %also encode classlabels before PCA

[coeff,score,latent,~,~,mu] = pca(Data);
A = cumsum(latent)./sum(latent);
dimensions = find(A<pca_th)';

% %reconstruct original samples from component space
% orig = score(:,dimensions)*coeff(:,dimensions)' + repmat(mu,S,1);

%construct new point in PCA space
p = Data(7,:); %sample
point = (p-mu)/coeff(:,dimensions)'; %sample in PCA space
%% create train set on data
PCA = score(:,dimensions);

K = KMeans(2);
K.addDataPoint(PCA(1,:),1);
K.addDataPoint(PCA(end,:),2);

labels = classlabels([1,end,2:end-1]);
for i=2:S-1
    K.addDataPoint(PCA(i,:));
end

clLabels = K.Clusters;
pctCorrect = [num2str((sum(clLabels==labels) / S)*100), ' %']

%% Create test data
counter_2 = 0;

for j=1:100;
    %generate test data from class 2
    test_signal = 0.7*rand(C,L).*sin(2*pi*[50;50;51;52;48;41;50;50;50;50]*t)+2*randn(C,L);
    testF = zeros(C,L/2+1);
    for i=1:C
        Y = fft(test_signal(i,:));
        Y = abs(Y./L);
        testF(i,:) = 2*Y(1:L/2+1);
        testF(i,2:end-1) = 2*testF(i,2:end-1);
    end
    testF = testF(:,IND);
    
    %get PCA representation
    C1 = ([testF(:)',1]-mu)/coeff(:,dimensions)';
    C2 = ([testF(:)',2]-mu)/coeff(:,dimensions)';
    if (min(C2)<min(C1))
        counter_2=counter_2+1;
    end
end