try; cd(fileparts(mfilename('fullpath')));catch; end;
run buffer_bci-master/utilities/initPaths.m

buffhost='localhost';
buffport=1972;
trlen_samp = 50; % #samples per epoch

phaseToRun=[];
while ( isempty(phaseToRun) || ~isstruct(phaseToRun) || (phaseToRun.nchans==0) ) % wait for the buffer to contain valid data
  try 
    phaseToRun=buffer('get_hdr',[],buffhost,buffport); 
  catch
    phaseToRun=[];
    fprintf('Invalid header info... waiting.\n');
  end;
  pause(1);
end;

initgetwTime;
initsleepSec;
state = [];
endTest = false;

while(true)
    sendEvent('stimulus.epoch','start');
    pause(0.5);
end