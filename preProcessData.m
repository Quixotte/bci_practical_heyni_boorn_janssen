clear;
participants = dir('eegmmidb');
%Channels, datapoints, trials, Particpants
%left = zeros(64,641,24,25);
right = zeros(64,641,24,25);

for fileIndex = 1:25
  startingIndex = 75;
  filename = participants(fileIndex+startingIndex+2).name;
  load(strcat('eegmmidb/',filename,'/jf_prep/',filename,'_mm.mat'));

  [_,_,trial] = di.vals;
  l=1;
  r=1;
  for i = 1:180
    trialIdentifier = int2str(trial(i))(1:2);
    if trialIdentifier == '30' || trialIdentifier == '70' || trialIdentifier == '11'
      if di(3).extra(i).marker.type == 'T1'
        %left(:,:,l,fileIndex) = X(1:64,:,i);
        %l = l+1;
      else
        right(:,:,r,fileIndex) = X(1:64,:,i);
        r = r+1;
      end
    end
  end
end
save('right4.mat','right');

