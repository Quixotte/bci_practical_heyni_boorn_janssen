clc;
N = size(X,1);
D=228;
%Random initialization of the latent variables
Mu = repmat(mean(X,1),K,1);
Mu = Mu + (rand(K,D)*10 - 5);
Sigma = zeros(D,D,K);
for i=1:K
    Sigma(:,:,i) = eye(D).*(10*rand(D,D)+5);
end
Pi = repmat(1/K,1,K);

for cycle = 1:maxIter
    %expectation step
    Gamma = zeros(N,K);
    for n=1:N
        for k=1:K
            Gamma(n,k) = Pi(k)*mvnpdf(X(n,:),Mu(k,:),Sigma(:,:,k));
        end
        
        if max(Gamma(n,:) == 0)
            Gamma(n,:) = rand(1,K);
        end
    end
    Gamma = Gamma./repmat(sum(Gamma,2),1,K);
    
    %maximization step
    Nk = sum(Gamma,1);
    for k=1:K
        Mu(k,:) = (Gamma(:,k)'*X)./Nk(k);
        Sigma(:,:,k) = zeros(D,D);
        for n=1:N
            Sigma(:,:,k) = Sigma(:,:,k)+(X(n,:)-Mu(k,:))'*(X(n,:)-Mu(k,:))*Gamma(n,k);
        end
        Sigma(:,:,k) = Sigma(:,:,k)./Nk(k);
        
        while ~all(eig(Sigma(:,:,k)) > 0)
            Sigma(:,:,k) = Sigma(:,:,k)+eye(D).*rand(D,D);
        end
    end
    Pi = Nk./N;
    
    
%     %visualize
%     Assignment = zeros(N,1);
%     for n=1:N
%         Assignment(n) = find(Gamma(n,:)==max(Gamma(n,:)));
%     end
    
    if(show)
        if (calc_log)
            %calculate log likelihood
            log_likelihood = 0;
            for n=1:N
                s = 0;
                for k=1:K
                    s = s+mvnpdf(X(n,:),Mu(k,:),Sigma(:,:,k));
                end
                log_likelihood = log_likelihood+log(s);
            end
            ['Iteration: ',num2str(cycle),', Log likelihood: ',num2str(log_likelihood)]
        else
            ['Iteration: ',num2str(cycle)]
        end
    end
    
end