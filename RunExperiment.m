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

trlen_samp = 2*phaseToRun.fsample; % #samples per epoch

% set the real-time-clock to use

initgetwTime;
initsleepSec;
state = [];
windows = cell(1000,1);
endTest = 0;
epoch = 1;
while (~endTest)
  [data,devents,state]=buffer_waitData([],[],state,'startSet',{'stimulus.epoch'},'trlen_samp',trlen_samp,'exitSet',{'data' {'stimulus.sequences' 'stimulus.epoch'} 'end'});
  for ei=1:numel(devents)
        event=devents(ei);
        if( strcmp('stimulus.epoch',event.type) && strcmp('end',event.value) ) % end event 
          fprintf('Discarding all subsequent events: exit\n');
          break;
        end;
        if( strcmp('stimulus.sequences',event.type) && strcmp('end',event.value) ) % end Test 
          fprintf('Discarding all subsequent events: exit\n');
          endTest = 1;
          break;
        end;
        windows{epoch,1} = data;
        windows{epoch,2} = event.value;
        epoch = epoch + 1;
        
        %Insert Hector Classification
        
        C = randi(2,1);
        
        C = num2str(C);
        
        windows{epoch,3} = C;
        sendEvent('feedback',C);
    end
end

save('Data.mat','windows');