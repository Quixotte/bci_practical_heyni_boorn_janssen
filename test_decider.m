length = 100;
value = zeros(1,length);
cd = ClassDecider(0.1,0.3);

for i=1:length
    %i
    cd = cd.updateValue();
    value(1,i) = cd.value;
    if (mod(i,1)==0)
        cd = cd.putClass(1);
    end
    pause(0.001);
end

plot(value);