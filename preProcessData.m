addpath ("buffer_bci-master/utilities")
addpath ("Data")
run initPaths.m;
filePath = "S102/S102R07.edf";

[hdr, record] = edfread(filePath);
