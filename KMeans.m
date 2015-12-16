classdef KMeans
    %KMEANS Create a discrete clustering of the data
    
    properties
        DataPoints = zeros(1,0);
        N;
        Mu;
    end
    
    methods
        
        function this = KMeans(n)
            if nargin > 0
                if isnumeric(n)
                    this.N = n;
                    this.Mu = zeros(this.N,0);
                else
                    error('N must be numeric')
                end
            end
        end
    end
    
end

