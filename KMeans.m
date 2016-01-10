classdef KMeans < handle
    %KMEANS Create a discrete clustering of the data
    
    properties
        DataPoints = zeros(0,0);
        Clusters = zeros(0,0);
        N; %number of clusters
        Mu; %means of clusters
        S;
    end
    
    methods
        %adds a new datapoint to the database, cluster_label is optional as
        %long as some datapoints eventually get cluster labels
        function addDataPoint(this, point)            
            this.DataPoints(end+1,1:this.S) = point;
            this.Clusters(end+1,1) = 0;
            update(this);
        end
        
        %updates the cluster means and assigns labels to the datapoints
        function update(this)
            currentLabels = this.Clusters;
            
            %compute new means and reassign data points to clusters, until
            %nothings changes anymore
            while(true)
                updateMu(this);
                
                for i=1:size(this.DataPoints,1)
                    %assign label of cluster with the mean closest to each
                    %point
                    dist = getEuclideanDistance(this, this.DataPoints(i,:));
                    this.Clusters(i) = find(dist == min(dist));
                end
                
                if(this.Clusters == currentLabels)
                    break;
                end
                
                currentLabels = this.Clusters;
            end
        end
        
        %update the means of each cluster
        function updateMu(this)
            for i=1:this.N
                if(sum(this.Clusters == i) > 0)
                    this.Mu(i,:) = mean(this.DataPoints(this.Clusters == i,:),1);
                end
            end
        end
        
        %get euclidean distance between the cluster means and a point
        function dist = getEuclideanDistance(this, point)
            dist = zeros(this.N,1);
            for i = 1:this.N
                dist(i,1) = sum((this.Mu(i,:) - point).^2);
            end
        end
        
        %creates a new instance of KMeans, with N being the number of
        %clusters
        function this = KMeans(n,S)
            if nargin > 0
                if isnumeric(n)
                    this.N = n;
                    this.S = S;
                    this.Mu = rand(this.N,S);
                else
                    error('N must be numeric')
                end
            end
        end
    end
    
end