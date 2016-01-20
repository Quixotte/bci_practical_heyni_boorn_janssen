X = [Dl;Dr];
Y = [zeros(size(Dl,1),1);ones(size(Dr,1),1)];
[b,dev,stats] = glmfit(X,Y,'binomial');

% Test set

conf = zeros(2);
setl = test_same_setl;
setr = test_same_setr;
choicel = zeros(size(setl,1),1);
for i=1:size(setl,1)
    datapoint = setl(i,:);
    lpr = (datapoint-mul)/coeffl';
    rpr = (datapoint-mur)/coeffr';
    choicel(i) = glmval(b,datapoint,'logit');
    val = round(choicel(i)+1);
    conf(1,val) = conf(1,val)+1;
end

choicer = zeros(size(setr,1),1);
for i=1:size(setr,1)
    datapoint = setr(i,:);
    lpr = (datapoint-mul)/coeffl';
    rpr = (datapoint-mur)/coeffr';
    choicer(i) = glmval(b,datapoint,'logit');
    val = round(choicer(i)+1);
    conf(2,val) = conf(2,val)+1;
end
conf