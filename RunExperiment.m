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

% set the real-time-clock to use

initgetwTime;
initsleepSec;
state = [];
endTest = false;
while (~endTest) 
  [data,devents,state]=buffer_waitData([],[],state,'startSet',{'stimulus.epoch'},'trlen_samp',trlen_samp,'exitSet',{'data' 'stimulus.sequences' 'end'});
  fprintf('yo');
  for ei=1:numel(devents)
        event=devents(ei);
        if( isequal('stimulus.sequences',event.type) && isequal('end',event.value) ) % end event
          endTest=true; 
          fprintf('Discarding all subsequent events: exit\n');
          break;
        end;
        
        %Insert Hector Classification
        C = 0;
        sendClass(C);
    end
end