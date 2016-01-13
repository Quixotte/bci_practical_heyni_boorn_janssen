function [ Data, scores, mu, coeff, freq, A ] = train_preprocessing( D, Fs, pca_th, opt, min_f, max_f )

C = size(D,1); %channel
L = size(D,2); %length of signal
S = size(D,3); %trial

P1 = zeros(S,C,L/2+1);

for s=1:S
    D(:,:,s) = preproc(D(:,:,s),opt);
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
scores=Data;
mu=0; coeff=0; A=0;
% [coeff,~,latent,~,~,mu] = pca(Data);
% A = cumsum(latent)./sum(latent);
% if(pca_th <= 1)
%     if (pca_th > 0)
%         dimensions = find(A<pca_th)';
%     else
%         dimensions = 1:size(coeff,2);
%     end
% else
%     dimensions = 1:pca_th;
% end
% coeff = coeff(:,dimensions);
% scores = (Data-repmat(mu,size(Data,1),1))/coeff';

% %reconstruct original samples from component space
% orig = score(:,dimensions)*coeff(:,dimensions)' + repmat(mu,S,1);
%
% %construct new point in PCA space
% p = Data(7,:); %sample
% point = (p-mu)/coeff(:,dimensions)'; %sample in PCA space
%

end

