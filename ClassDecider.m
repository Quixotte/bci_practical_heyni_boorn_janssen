classdef ClassDecider
    %CLASSDECIDER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        value = 0;
        decay;
        increment;
        time;
    end
    
    methods
        function this = putClass(this,class)
            ms = round(toc(this.time) * 1000);
            this.value = (this.value+(class-this.value)*this.increment) * ((1 - this.decay).^ms);
            this.time = tic;
        end
        
        function this = updateValue(this)
            ms = round(toc(this.time) * 1000)
            this.value = this.value * ((1 - this.decay).^ms);
            this.time = tic;
        end
        
        function this = ClassDecider(decay, increment)
            this.decay = decay;
            this.increment = increment;
            this.time = tic;
        end
    end
    
end

