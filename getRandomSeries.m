function [ pattern ] = getRandomSeries( L, max_same, p_left )
%GETRANDOMSERIES Summary of this function goes here
%   Detailed explanation goes here
% L is the length of the vector, max_same is the maximum number of times a direction is
% presented after each other
pattern = zeros(1,L);
last = -(rand()>p_left); Nsame = 1;

for i=1:L
    if(Nsame >= max_same)
        if (last == 2)
            pattern(1,i) = 1;
            last = 1;
        else
           pattern(1,i) = 2; 
           last = 2
        end
        Nsame = 1;
        continue;
    end
    
    p = rand();
    if (p <= p_left)
        pattern(1,i) = 1;
    else
        pattern(1,i) = 2;
    end
    
    if(pattern(1,i) == last)
        Nsame = Nsame + 1;
    else
        Nsame = 1;
    end
    
    last = pattern(1,i);
end
save('pattern');

end