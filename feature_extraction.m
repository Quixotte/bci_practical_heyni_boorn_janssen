clear all;
datapoint = zeros(10,300,50);%channel, timepoints, sample

Fs = 250;
%T = 1/Fs;             % Sampling period
L = size(datapoint,2);            % Length of signal
C = size(datapoint,1);
S = size(datapoint,3);
T = 1/Fs;             % Sampling period
t = (0:L-1)*T;        % Time vector
%nyquist = L/2;
for sample=1:S/2
    datapoint(:,:,sample) = 0.7*sin(2*pi*[50;50;51;52;48;41;50;50;50;50]*t)+2*randn(C,L);
end
for sample=S/2+1:S
    datapoint(:,:,sample) = 0.7*sin(2*pi*[20;20;21;22;18;11;20;20;20;20]*t)+2*randn(C,L);
end

P1 = zeros(S,C,L/2+1);
for s=1:S
    for i=1:C
        Y = fft(datapoint(i,:));
        P2 = abs(Y./L);
        P1(s,i,:) = 2*P2(1:L/2+1);
        P1(s,i,2:end-1) = 2*P1(s,i,2:end-1);
    end
end
f = Fs*(0:(L/2))/L;

IND = find(f<=45);
plot(f(IND),P1(:,IND));
P1 = P1(:,:,IND);
Data = P1(:,:);

[COEFF,score,latent] = princomp(Data);