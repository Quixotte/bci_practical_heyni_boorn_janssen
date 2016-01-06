addpath ('buffer_bci-master/utilities')
run initPaths;
filePath = 'S002/S002R07.edf';

[hdr, record] = edfread(filePath);