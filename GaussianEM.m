classdef GaussianEM < handle
    %GAUSSIANEM Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        K = 1;
        D;
        Mu;
        Sigma;
        Assignment;
        Pi;
        Name;
    end
    
    methods
        function P = getLikelihood(this,datapoint)
            P = zeros(1,this.K);
            for k=1:this.K
                P(k) = this.Pi(k)*mvnpdf(datapoint,this.Mu(k,:),this.Sigma(:,:,k));
            end
        end
        
        function this = GaussianEM(K,D,TITLE)
            this.K = K;
            this.D = D;
            this.Name = TITLE;
        end
        
        function [] = train(this, X, maxIter, show, calc_log, mu_rnd, sigma_rnd)
            N = size(X,1);
            
            %Random initialization of the latent variables
            this.Mu = repmat(mean(X,1),this.K,1);
            this.Mu = this.Mu + (rand(this.K,this.D)*mu_rnd - mu_rnd/2);
            this.Sigma = zeros(this.D,this.D,this.K);
            for i=1:this.K %eye(this.D)
                this.Sigma(:,:,i) = eye(this.D).*(sigma_rnd*rand(this.D,this.D)+sigma_rnd/2);
            end
            this.Pi = repmat(1/this.K,1,this.K);
            
            for cycle = 1:maxIter
                %expectation step
                Gamma = zeros(N,this.K);
                for n=1:N
                    for k=1:this.K
                        Gamma(n,k) = this.Pi(k)*mvnpdf(X(n,:),this.Mu(k,:),this.Sigma(:,:,k));
                    end
                    if max(Gamma(n,:) == 0)
                        Gamma(n,:) = rand(1,this.K);
                    end
                end
                Gamma = Gamma./repmat(sum(Gamma,2),1,this.K);
                
                %maximization step
                Nk = sum(Gamma,1);
                for k=1:this.K
                    this.Mu(k,:) = (Gamma(:,k)'*X)./Nk(k);
                    this.Sigma(:,:,k) = zeros(this.D,this.D);
                    for n=1:N
                        this.Sigma(:,:,k) = this.Sigma(:,:,k)+(X(n,:)-this.Mu(k,:))'*(X(n,:)-this.Mu(k,:))*Gamma(n,k);
                    end
                    this.Sigma(:,:,k) = this.Sigma(:,:,k)./Nk(k);
                    
                    while ~all(eig(this.Sigma(:,:,k)) > 0)
                        this.Sigma(:,:,k) = this.Sigma(:,:,k)+eye(this.D).*rand(this.D,this.D);
                    end
                end
                this.Pi = Nk./N;
                
                if(show)
                    if (calc_log)
                        %calculate log likelihood
                        log_likelihood = 0;
                        for n=1:N
                            s = 0;
                            for k=1:this.K
                                s = s+mvnpdf(X(n,:),this.Mu(k,:),this.Sigma(:,:,k));
                            end
                            log_likelihood = log_likelihood+log(s);
                        end
                        [this.Name,': Iteration: ',num2str(cycle),', Log likelihood: ',num2str(log_likelihood)]
                    else
                        [this.Name,': Iteration: ',num2str(cycle)]
                    end
                end
                
            end
        end
    end
    
end

