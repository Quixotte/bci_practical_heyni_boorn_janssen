classdef KMeans < handle
    %KMEANS Create a discrete clustering of the data
    
    properties
        DataPoints = zeros(0,0);
        Clusters = zeros(0,0);
        N; %number of clusters
        Mu; %means of clusters
    end
    
    methods
        %adds a new datapoint to the database, cluster_label is optional as
        %long as some datapoints eventually get cluster labels
        function addDataPoint(this, point, cluster_label)
            if (nargin < 3)
                cluster_label = 0;
            end
            
            sz = size(point,2);
            this.DataPoints(end+1,1:sz) = point;
            this.Clusters(end+1,1) = cluster_label;
            update(this);
        end
        
        %updates the cluster means and assigns labels to the datapoints
        function update(this)
            currentLabels = this.Clusters;
            
            %check if all clusters have elements
            for i = 1:this.N
                if(sum(find(currentLabels==i)) == 0)
                    return;
                end
            end
            
            %compute new means and reassign data points to clusters, until
            %nothings changes anymore
            while(true)
                nextLabels = zeros(size(currentLabels,1),1);
                updateMu(this);
                
                for i=1:size(this.DataPoints,1)
                    %assign label of cluster with the mean closest to each
                    %point
                    dist = getEuclideanDistance(this, this.DataPoints(i,:));
                    nextLabels(i,1) = find(dist == min(dist));
                end
                
                if(nextLabels==currentLabels)
                    break;
                end
                
                currentLabels = nextLabels;
            end
            
            this.Clusters = currentLabels;
        end
        
        %update the means of each cluster
        function updateMu(this)
            for i=1:this.N
                this.Mu(i,1:size(this.DataPoints,2)) = mean(this.DataPoints(this.Clusters == i,:),1);
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