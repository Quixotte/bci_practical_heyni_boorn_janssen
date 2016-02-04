function [ scores ] = performPCA( pca_th, Data )
%perform dimensionality reduction via PCA on the data

[coeff,~,latent,~,~,mu] = pca(Data);
A = cumsum(latent)./sum(latent);
if(pca_th <= 1)
    if (pca_th > 0) %select the first components such that pca_th portion of variance can be explained
        dimensions = find(A<pca_th)';
    else
        dimensions = 1:size(coeff,2);
    end
else
    dimensions = 1:pca_th; %select the first pca_th components
end

coeff = coeff(:,dimensions);
scores = (Data-repmat(mu,size(Data,1),1))/coeff'; %transform the data into PCA space
end

