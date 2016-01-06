load('eegmmidb/S001/jf_prep/S001_mm.mat');
left = zeros(64,641,23,1);
right = zeros(64,641,22,1);
[_,_,trial] = di.vals;
l=1;
r=1;
for i = 1:180
  trialIdentifier = int2str(trial(i))(1:2);
  if trialIdentifier == '30' || trialIdentifier == '70' || trialIdentifier == '11'
    if di(3).extra(i).marker.type == 'T1'
      left(:,:,l,1) = X(1:64,:,i);
      l = l+1;
    else
      right(:,:,r,1) = X(1:64,:,i);
      r = r+1;
    end
  end
end
