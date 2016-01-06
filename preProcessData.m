<<<<<<< HEAD
open('eegmmidb/S001/jf_prep/S001_mm.mat');
left = zeros(64,641,180,1);
right = zeros(64,641,180,1);
for i = 1:180
di.vals(i);
end
=======
addpath ('buffer_bci-master/utilities')
run initPaths;
filePath = 'S002/S002R07.edf';

[hdr, record] = edfread(filePath);
>>>>>>> 5354037d3f9039a2d669a2ce3b3ec1e3e5eb2937
