function [ scores ] = performPCA( pca_th, Data )
[coeff,~,latent,~,~,mu] = pca(Data);
A = cumsum(latent)./sum(latent);
if(pca_th <= 1)
    if (pca_th > 0)
        dimensions = find(A<pca_th)';
    else
        dimensions = 1:size(coeff,2);
    end
else
    dimensions = 1:pca_th;
end
coeff = coeff(:,dimensions);
scores = (Data-repmat(mu,size(Data,1),1))/coeff';
end

