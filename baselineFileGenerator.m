clear;
participants = dir('eegmmidb');
baselines = zeros(64,9600,104);

for fileIndex = 1:104
  filename = participants(fileIndex+2).name;
  [hdr,record] = edfread(strcat('Data/',filename,'/',filename,'R01.edf'));
  baselines(:,:,fileIndex);
end
save('baselines.mat','baselines');
