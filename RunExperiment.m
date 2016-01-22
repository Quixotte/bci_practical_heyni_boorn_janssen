try; cd(fileparts(mfilename('fullpath')));catch; end;
run buffer_bci-master/utilities/initPaths.m

buffhost='localhost';
buffport=1972;

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

trlen_samp = 1*phaseToRun.fsample; % #samples per epoch

% set the real-time-clock to use

initgetwTime;
initsleepSec;
state = [];
windows = cell(1000,1);
endTest = false;
epoch = 1;
while (~endTest) 
  [data,devents,state]=buffer_waitData([],[],state,'startSet',{'stimulus.epoch'},'trlen_samp',trlen_samp,'exitSet',{'data' 'stimulus.sequences' 'end'});
  for ei=1:numel(devents)
        event=devents(ei);
        if( strcmp('stimulus.sequences',event.type) && strcmp('end',event.value) ) % end event
          endTest=true; 
          fprintf('Discarding all subsequent events: exit\n');
          break;
        end;
        windows{epoch,1} = data;
        epoch = epoch + 1;
        %Insert Hector Classification
        C = 1;
        C = num2str(C);
        sendEvent('feedback',C);
    end
end

save('Data.mat','windows');