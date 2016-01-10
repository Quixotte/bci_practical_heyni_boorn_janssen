function [ Data, scores ] = test_preprocessing( D, Fs, opt, min_f, max_f, mu, coeff )

C = size(D,1); %channel
L = size(D,2); %length of signal
S = size(D,3); %trial

P1 = zeros(S,C,L/2+1);
D = preproc(D,opt);

for s=1:S
    for i=1:C
        Y = fft(D(:,:,s));
        P2 = abs(Y./L);
        P1(s,i,:) = 2*P2(1:L/2+1);
        P1(s,i,2:end-1) = 2*P1(s,i,2:end-1);
    end
end

f = Fs*(0:(L/2))/L;

IND = f<=max_f & f>=min_f;
P1 = P1(:,:,IND);
Data = P1(:,:);
freq = f(IND);

%representation in PCA space
% scores = (Data-repmat(mu,size(Data,1),1))/coeff';
scores=Data;

% %reconstruct original samples from component space
% orig = score(:,dimensions)*coeff(:,dimensions)' + repmat(mu,S,1);
%
% %construct new point in PCA space
% p = Data(7,:); %sample
% point = (p-mu)/coeff(:,dimensions)'; %sample in PCA space
%

end