classdef Gaussian < handle
    %GAUSSIANEM Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        D;
        Mu;
        Sigma;
        Name;
    end
    
    methods
        function P = getLogLikelihood(this,datapoint)
            P = 0;
            for i=1:size(datapoint,2)
                P = P+reallog(normpdf(datapoint(1,i),this.Mu(i),this.Sigma(i))+eps);
            end
        end
        
        function this = Gaussian(D,TITLE)
            this.D = D;
            this.Name = TITLE;
        end
        
        function [] = train(this, X)
            this.Mu = mean(X);
            this.Sigma = std(X);
        end
    end
end

