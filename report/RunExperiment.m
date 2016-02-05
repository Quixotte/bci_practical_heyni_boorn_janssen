try; cd(fileparts(mfilename('fullpath')));catch; end;
run buffer_bci-master/utilities/initPaths.m;

classifierFile = 'classifier_Thomas.mat';%The classifier that needs to be run
windowlength = 2; %In seconds
resultsFileName = 'Data_Thomas_TEST.mat';

load(classifierFile);

buffhost='localhost';
buffport=1972;
useLinearClassifier = 1;
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

trlen_samp = windowLength*phaseToRun.fsample; % #samples per epoch
% set the real-time-clock to use

initgetwTime;
initsleepSec;
state = [];
windows = cell(10000,1);
endTest = 0;
epoch = 1;
trialNumber = 1;

linclasses = zeros(0,0); %classification result from ERSP classifier
classified = zeros(0,0); %weighted average classifications
glmset = zeros(0,0); weights = zeros(0,0); %set of training samples for glm and weights
default = 0.5989;%the standard performance of ersp classifier on this user, optimized

%While we wait for the experiment to end
while (~endTest)
    %Wait for a stimulus.epoch event, and if it occurs get the data.
    [data,devents,state]=buffer_waitData([],[],state,'startSet',{'stimulus.epoch'},'trlen_samp',trlen_samp,'exitSet',{'data' {'stimulus.sequences' 'stimulus.trial'} 'end'});
    for ei=1:numel(devents)
        event=devents(ei);
        if( strcmp('stimulus.trial',event.type) && strcmp('end',event.value) ) % end event
            fprintf('Discarding all subsequent events: exit\n');
            break;
        end;
        if( strcmp('stimulus.sequences',event.type) && strcmp('end',event.value) ) % end Test
            fprintf('Discarding all subsequent events: exit\n');
            endTest = 1;
            break;
        end;
        windows{epoch,1} = data;
        
        %Get car position and incomming car position for the records.
        trial_tuple = strsplit(event.value,',');
        windows{epoch,2} = trial_tuple(1);
        windows{epoch,3} = trial_tuple(2);
        
        %Insert Hector Classification
        if(useLinearClassifier)
            C = classifyEpoch(data.buf,clsfr); %clsfr should be in the workspace!
            C = 3 - C; %data is trained on where the incoming car is, not where you should be
            C = num2str(C);
        else
            %         or use the adaptive classifier
            sample = data;
            s2 = preproc_ersp(sample,opt);
            c = classifyEpoch(sample,clsfr); %get ERSP classifier
            linclasses(epoch) = c;
            
            if (epoch<10) %skip the first samples to get a feel of the data
                classified(epoch,:) = c; %take default classification
                C = c;
                weights(epoch,:) = default;
                glmset(epoch,:) = s2(:);
            else
                B = glmfit(glmset,(classified-1),'binomial','weights',weights); %train glm on all instances
                self = glmval(B,s2(:)','logit')+1; %get output from glm
                w = epoch/S * 1.3; %apply weighted learning
                weights(epoch,:) = (w+default)/2; %set certainty of classification
                classified(epoch,:) = round((self*w+c*default)/(w+default)); %take weighted average
                C = round((self*w+c*default)/(w+default));
                glmset(epoch,:) = s2(:);
            end
        end
        
        windows{epoch,4} = C;
        
        %Send feedback event
        sendEvent('feedback',C);
        epoch = epoch + 1;
        
    end
end

windows = windows(1:epoch,:);
save(resultsFileName,'windows');