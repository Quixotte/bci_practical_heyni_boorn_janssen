length = 10000;
value = zeros(1,length);
cd = ClassDecider(0.995,0.3);

for i=1:length
    %i
    cd = cd.updateValue();
    value(1,i) = cd.value;
    if (i==1000)
        cd = cd.putClass(1);
    end
    %pause(0.001);
end

plot(value);