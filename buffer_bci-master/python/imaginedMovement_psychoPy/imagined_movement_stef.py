#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
This experiment was created using PsychoPy2 Experiment Builder (v1.82.01), Wed Jan 20 15:59:00 2016
If you publish work using this script please cite the relevant PsychoPy publications
  Peirce, JW (2007) PsychoPy - Psychophysics software in Python. Journal of Neuroscience Methods, 162(1-2), 8-13.
  Peirce, JW (2009) Generating stimuli for neuroscience using PsychoPy. Frontiers in Neuroinformatics, 2:10. doi: 10.3389/neuro.11.010.2008
"""

from __future__ import division  # so that 1/3=0.333 instead of 1/3=0
from psychopy import visual, core, data, event, logging, sound, gui
from psychopy.constants import *  # things like STARTED, FINISHED
import numpy as np  # whole numpy lib is available, prepend 'np.'
from numpy import sin, cos, tan, log, log10, pi, average, sqrt, std, deg2rad, rad2deg, linspace, asarray
from numpy.random import random, randint, normal, shuffle
import os  # handy system and path functions
import math
import scipy.io as sio

# Ensure that relative paths start from the same directory as this script
_thisDir = os.path.dirname(os.path.abspath(__file__))
os.chdir(_thisDir)

# Store info about the experiment session
expName = 'simple_imagined_movement'  # from the Builder filename that created this script
expInfo = {u'session': u'001', u'participant': u''}
dlg = gui.DlgFromDict(dictionary=expInfo, title=expName)
if dlg.OK == False: core.quit()  # user pressed cancel
expInfo['date'] = data.getDateStr()  # add a simple timestamp
expInfo['expName'] = expName

# Data file name stem = absolute path + name; later add .psyexp, .csv, .log, etc
filename = _thisDir + os.sep + u'data' + os.sep + '%s_%s' %(expInfo['participant'], expInfo['date'])

# An ExperimentHandler isn't essential but helps with data saving
thisExp = data.ExperimentHandler(name=expName, version='',
    extraInfo=expInfo, runtimeInfo=None,
    originPath=u'/Users/stefjanssen/Documents/programming/matlab/bci_practical/buffer_bci-master/python/imaginedMovement_psychoPy/simple_imagined_movement.psyexp',
    savePickle=True, saveWideText=True,
    dataFileName=filename)
    
#save a log file for detail verbose info
logFile = logging.LogFile(filename+'.log', level=logging.EXP)
logging.console.setLevel(logging.WARNING)  # this outputs to the screen, not a file

endExpNow = False  # flag for 'escape' or other condition => quit the exp

# Start Code - component code to be run before the window creation

# Setup the Window
win = visual.Window(size=[1024, 600], fullscr=False, screen=0, allowGUI=True, allowStencil=False,
    monitor='testMonitor', color=[0,0,0], colorSpace='rgb',
    blendMode='avg', useFBO=True,
    )
# store frame rate of monitor if we can measure it successfully
expInfo['frameRate']=win.getActualFrameRate()
if expInfo['frameRate']!=None:
    frameDur = 1.0/round(expInfo['frameRate'])
else:
    frameDur = 1.0/60.0 # couldn't get a reliable measure so guess

# Initialize components for Routine "Instructions"
InstructionsClock = core.Clock()
text_3 = visual.TextStim(win=win, ori=0, name='text_3',
    text=u'Trials will display left/right.\n\nPerform clenching movements with\nappriopiate hand. Feedback will be\ngiven whether we correctly predicted\nyour hand.',    font=u'Arial',
    pos=[0, 0], height=0.1, wrapWidth=80,
    color=u'white', colorSpace='rgb', opacity=1,
    depth=0.0)
    
text_4 = visual.TextStim(win=win, ori=0, name='text_4',
    text=u'Pause',    font=u'Arial',
    pos=[0, 0], height=0.1, wrapWidth=80,
    color=u'white', colorSpace='rgb', opacity=1,
    depth=0.0)# buffer_bci Handling the requered imports
import sys
import time
sys.path.append("../../dataAcq/buffer/python/")
from FieldTrip import Client, Event
from time import sleep

# buffer_bci Connecting to the buffer.
host = 'localhost'
port = 1972
ftc = Client()
hdr = None;
while hdr is None :
    print 'Trying to connect to buffer on %s:%i ...'%(host,port)
    try:
        ftc.connect(host, port)
        print '\nConnected - trying to read header...'
        hdr = ftc.getHeader()
    except IOError:
        pass
    if hdr is None:
        print 'Invalid Header... waiting'
        time.sleep(1)
    else:
        print hdr
        print hdr.labels
# buffer_bci Defining a usefull helper functions

def sendEvent(eventType, eventValue):
    e = Event()
    e.type = eventType
    e.value = eventValue
    ftc.putEvents(e)
    
procnEvents=0
def waitnewevents(evtype, timeout_ms=1000,verbose = True):      
    """Function that blocks until a certain type of event is recieved. 
        evttype defines a list of type-strings, recieving any of these event types will 
        termintes the block.  Only the first such matching event is returned
    """    
    global ftc, nEvents, nSamples
    start = time.time()
    if not 'procnEvents' in globals():
        global procnEvents
        nSamples,nEvents=ftc.poll()
        procnEvents=nEvents
    elapsed_ms = 0
    
    if verbose:
        print "Waiting for event " + str(evtype) + " with timeout_ms " + str(timeout_ms)
    
    evt=None
    while elapsed_ms < timeout_ms and evt is None:
        nSamples, nEvents2 = ftc.wait(-1,procnEvents+1, timeout_ms - elapsed_ms)     

        if procnEvents < nEvents2: # new events to process
            procnEvents = max(procnEvents,nEvents2-50)
            print procnEvents
            print nEvents2
            evts = ftc.getEvents([procnEvents, nEvents2 -1])
            evts = filter(lambda x: x.type in evtype,evts)
            if len(evts) > 0:
                evt=evts
        elapsed_ms = (time.time() - start)*1000
        procnEvents = nEvents2
        nEvents = nEvents2            
    return evt

# Initialize components for Routine "Instructions"
stimulusFeedbackClock = core.Clock()
ISI = core.StaticPeriod(win=win, screenHz=expInfo['frameRate'], name='ISI')
imagination_instruction = visual.TextStim(win=win, ori=0, name='imagination_instruction',
    text='default text',    font=u'Arial',
    pos=[0,0], height=0.1, wrapWidth=None,
    color=u'white', colorSpace='rgb', opacity=1,
    depth=-1.0)
sendFeedbackCounter = 0

# Initialize components for Routine "shapeFeedback"
shapeFeedbackClock = core.Clock()
eventRequestClock = core.Clock()

start_inc_pos_left = [-0.02, 0.09]
end_car_pos_left = [-0.2, -0.35]

image = visual.ImageStim(win=win, name='image',
    image=u'images/cabrio.jpg', mask=None,
    ori=0, pos=[0, 0], size=[0.3, 0.3],
    color=[1,1,1], colorSpace='rgb', opacity=1,
    flipHoriz=False, flipVert=False,
    texRes=128, interpolate=True, depth=0.0)

inc_car_image = visual.ImageStim(win=win, name='inc_car',
    image=u'images/car_after_crop.png', mask=None,
    ori=0, pos=[0,0], size = [0.2, 0.2],
    color=[1,1,1], colorSpace='rgb', opacity=1,
    flipHoriz=False, flipVert=False,
    texRes=128, interpolate=True, depth=0.0)
    
street_image = visual.ImageStim(win=win, name='street',
    image=u'images/street.png', mask=None,
    ori=0, pos=[0,0], size = [1, 1],
    color=[1,1,1], colorSpace='rgb', opacity=1,
    flipHoriz=False, flipVert=False,
    texRes=128, interpolate=True, depth=0.0)

steering = visual.Rect(win, width=0.5, height=0.1, lineWidth=1.5,
lineColor='white', lineColorSpace='rgb', fillColor='white',
fillColorSpace='rgb', vertices=((-0.5, 0), (0, 0.5), (0.5, 0)),
closeShape=True, pos=(0, 0), size=1, ori=0.0)

steering_box = visual.Rect(win, width=0.8, height=0.1, lineWidth=1.5,
lineColor='white', lineColorSpace='rgb', fillColor=None,
fillColorSpace='rgb', vertices=((-0.5, 0), (0, 0.5), (0.5, 0)),
closeShape=True, pos=(0, 0.85), size=1, ori=0.0)

# Create some handy timers
globalClock = core.Clock()  # to track the time since experiment started
routineTimer = core.CountdownTimer()  # to track time remaining of each (non-slip) routine 

#------Prepare to start Routine "Instructions"-------
t = 0
InstructionsClock.reset()  # clock 
frameN = -1
# update component parameters for each repeat
key_resp_2 = event.BuilderKeyResponse()  # create an object of type KeyResponse
key_resp_2.status = NOT_STARTED

# keep track of which components have finished
InstructionsComponents = []
InstructionsComponents.append(text_3)
InstructionsComponents.append(key_resp_2)
for thisComponent in InstructionsComponents:
    if hasattr(thisComponent, 'status'):
        thisComponent.status = NOT_STARTED

#-------Start Routine "Instructions"-------
continueRoutine = True
while continueRoutine:
    # get current time
    t = InstructionsClock.getTime()
    frameN = frameN + 1  # number of completed frames (so 0 is the first frame)
    # update/draw components on each frame
    
    # *text_3* updates
    if t >= 0.0 and text_3.status == NOT_STARTED:
        # keep track of start time/frame for later
        text_3.tStart = t  # underestimates by a little under one frame
        text_3.frameNStart = frameN  # exact frame index
        text_3.setAutoDraw(True)
    if text_3.status == STARTED and t >= (0.0 + (3600-win.monitorFramePeriod*0.75)): #most of one frame period left
        text_3.setAutoDraw(False)
    
    # *key_resp_2* updates
    if t >= 0.0 and key_resp_2.status == NOT_STARTED:
        # keep track of start time/frame for later
        key_resp_2.tStart = t  # underestimates by a little under one frame
        key_resp_2.frameNStart = frameN  # exact frame index
        key_resp_2.status = STARTED
        # keyboard checking is just starting
        key_resp_2.clock.reset()  # now t=0
        event.clearEvents(eventType='keyboard')
    if key_resp_2.status == STARTED:
        theseKeys = event.getKeys(keyList=['y', 'n', 'left', 'right', 'space'])
        
        # check for quit:
        if "escape" in theseKeys:
            endExpNow = True
        if len(theseKeys) > 0:  # at least one key was pressed
            key_resp_2.keys = theseKeys[-1]  # just the last key pressed
            key_resp_2.rt = key_resp_2.clock.getTime()
            # a response ends the routine
            continueRoutine = False
    
    
    # check if all components have finished
    if not continueRoutine:  # a component has requested a forced-end of Routine
        break
    continueRoutine = False  # will revert to True if at least one component still running
    for thisComponent in InstructionsComponents:
        if hasattr(thisComponent, "status") and thisComponent.status != FINISHED:
            continueRoutine = True
            break  # at least one component has not yet finished
    
    # check for quit (the Esc key)
    if endExpNow or event.getKeys(keyList=["escape"]):
        core.quit()
    
    # refresh the screen
    if continueRoutine:  # don't flip if this routine is over or we'll get a blank screen
        win.flip()

#-------Ending Routine "Instructions"-------
for thisComponent in InstructionsComponents:
    if hasattr(thisComponent, "setAutoDraw"):
        thisComponent.setAutoDraw(False)
# check responses
if key_resp_2.keys in ['', [], None]:  # No response was made
   key_resp_2.keys=None
# store data for thisExp (ExperimentHandler)
thisExp.addData('key_resp_2.keys',key_resp_2.keys)
if key_resp_2.keys != None:  # we had a response
    thisExp.addData('key_resp_2.rt', key_resp_2.rt)
thisExp.nextEntry()

# the Routine "Instructions" was not non-slip safe, so reset the non-slip timer
routineTimer.reset()

n_reps = 5
# set up handler to look after randomisation of conditions etc
trials_2 = data.TrialHandler(nReps=n_reps, method='random', 
    extraInfo=expInfo, originPath=u'/Users/stefjanssen/Documents/programming/matlab/bci_practical/buffer_bci-master/python/imaginedMovement_psychoPy/simple_imagined_movement.psyexp',
    trialList=data.importConditions('stimulus_conditions.csv'),
    seed=None, name='trials_2')
thisExp.addLoop(trials_2)  # add the loop to the experiment
thisTrial_2 = trials_2.trialList[0]  # so we can initialise stimuli with some values
# abbreviate parameter names if possible (e.g. rgb=thisTrial_2.rgb)
if thisTrial_2 != None:
    for paramName in thisTrial_2.keys():
        exec(paramName + '= thisTrial_2.' + paramName)

inc_car_pos = sio.loadmat('pattern.mat')['pattern'][0]
print inc_car_pos

sendFeedbackCounter = 0
getFeedbackCounter = 0

for i, thisTrial_2 in enumerate(trials_2):
    currentLoop = trials_2
    # abbreviate parameter names if possible (e.g. rgb = thisTrial_2.rgb)
    if thisTrial_2 != None:
        for paramName in thisTrial_2.keys():
            exec(paramName + '= thisTrial_2.' + paramName)
    #------Prepare to start Routine "shapeFeedback"-------
    t = 0
    shapeFeedbackClock.reset()  # clocks
    eventRequestClock.reset()
    frameN = -1
    this_routine_time = 12.0
    # update component parameters for each repeat
    # keep track of which components have finished
    shapeFeedbackComponents = []
    shapeFeedbackComponents.append(image)
    shapeFeedbackComponents.append(inc_car_image)
    shapeFeedbackComponents.append(street_image)
    for thisComponent in shapeFeedbackComponents:
        if hasattr(thisComponent, 'status'):
            thisComponent.status = NOT_STARTED
    
    #-------Start Routine "shapeFeedback"-------

    continueRoutine = True
    routineTimer.add(this_routine_time)
    feedbacks = []
    while continueRoutine and routineTimer.getTime() > 0:
        # get current time
        feedback_t = eventRequestClock.getTime()
        if feedback_t > 0.100:    #send req for feedback every 100 ms
            sendEvent("stimulus.epoch", str(inc_car_pos[i]) + "," + str(i))
            sendFeedbackCounter = 1 + sendFeedbackCounter
            eventRequestClock.reset()
        
        frameN = frameN + 1  # number of completed frames (so 0 is the first frame)
        # update/draw components on each frame
        
        feedbackEvt = waitnewevents("feedback",250)
        if feedbackEvt is None:
            feedback='None'
        else:
            feedback=feedbackEvt[0].value
            getFeedbackCounter = getFeedbackCounter + 1 
        if feedback is not "None":
            feedbacks.append(feedback)
        print feedback
        percent_there = 1-(routineTimer.getTime()/this_routine_time)
        if percent_there > 1:
            percent_there = 1
        percent_there = math.pow(percent_there, 2.) #squared to slow down at start
        diff_x = percent_there * abs(start_inc_pos_left[0]- end_car_pos_left[0])
        diff_y = percent_there * abs(start_inc_pos_left[1]-end_car_pos_left[1])
        
        y = start_inc_pos_left[1] - diff_y
        
        if inc_car_pos[i] == 1:
            x = start_inc_pos_left[0] - diff_x
        else:
            x = start_inc_pos_left[0]*-1 + diff_x

        # *background_image* updates
        if t >= 0.0 and street_image.status == NOT_STARTED:
            # keep track of start time/frame for later
            street_image.tStart = t  # underestimates by a little under one frame
            street_image.frameNStart = frameN  # exact frame index
            street_image.setAutoDraw(True)
        if street_image.status == STARTED and t >= (0.0 + (this_routine_time-win.monitorFramePeriod*0.75)): #most of one frame period left
            street_image.setAutoDraw(False)
            
        # *inc_car image* updates
        if t >= 0.0 and inc_car_image.status == NOT_STARTED:
            # keep track of start time/frame for later
            inc_car_image.tStart = t  # underestimates by a little under one frame
            inc_car_image.frameNStart = frameN  # exact frame index
            inc_car_image.setAutoDraw(True)
        if inc_car_image.status == STARTED and t >= (0.0 + (this_routine_time-win.monitorFramePeriod*0.75)): #most of one frame period left
            inc_car_image.setAutoDraw(False)
            
        if inc_car_image.status == STARTED:  # only update if being drawn
            inc_car_image.pos = [x,y]
            this_size = 0.05 + (0.3-0.05)*percent_there
            inc_car_image.size = [this_size, this_size]
            
        # *image* updates
        if t >= 0.0 and image.status == NOT_STARTED:
            # keep track of start time/frame for later
            image.tStart = t  # underestimates by a little under one frame
            image.frameNStart = frameN  # exact frame index
            image.setAutoDraw(True)
        if image.status == STARTED and t >= (0.0 + (this_routine_time-win.monitorFramePeriod*0.75)): #most of one frame period left
            image.setAutoDraw(False)
        
        n_feedbacks = len(feedbacks)
        if n_feedbacks == 0:
            percent_left = 0
        else:
            weighted_list = np.arange(1, n_feedbacks+1)
            weighted_list = weighted_list/sum(weighted_list)
            print weighted_list
            percent_left = sum(
                [(1 if feedbacks[j]== '1' else 0) * weighted_list[j] 
                for j in np.arange(n_feedbacks)]
            )
            percent_left = feedbacks.count('1')/n_feedbacks
            print "percent_left:"
            print percent_left
        
        if image.status == STARTED: #only update if being drawn
            if percent_left > 0.5:  #send car left
                image.pos = end_car_pos_left
            elif percent_left < 0.5:#send car right
                image.pos = [end_car_pos_left[0] * -1, end_car_pos_left[1]];
                
        # *steering* updates
        if t >= 0.0 and steering.status == NOT_STARTED:
            # keep track of start time/frame for later
            steering.tStart = t  # underestimates by a little under one frame
            steering.frameNStart = frameN  # exact frame index
            steering.setAutoDraw(True)
        if steering.status == STARTED and t >= (0.0 + (this_routine_time-win.monitorFramePeriod*0.75)): #most of one frame period left
            steering.setAutoDraw(False)
            
        if steering.status == STARTED:  # only update if being drawn
            steering.pos = [0.2-0.4*percent_left, 0.85]
            
        # *steering_box* updates
        if t >= 0.0 and steering_box.status == NOT_STARTED:
            # keep track of start time/frame for later
            steering_box.tStart = t  # underestimates by a little under one frame
            steering_box.frameNStart = frameN  # exact frame index
            steering_box.setAutoDraw(True)
        if steering_box.status == STARTED and t >= (0.0 + (this_routine_time-win.monitorFramePeriod*0.75)): #most of one frame period left
            steering_box.setAutoDraw(False)
            
        if steering_box.status == STARTED:  # only update if being drawn
            steering_box.pos = [0.0, 0.85]
            

        # check if all components have finished
        if not continueRoutine:  # a component has requested a forced-end of Routine
            break
        continueRoutine = False  # will revert to True if at least one component still running
        for thisComponent in shapeFeedbackComponents:
            if hasattr(thisComponent, "status") and thisComponent.status != FINISHED:
                continueRoutine = True
                break  # at least one component has not yet finished

        # check for quit (the Esc key)
        if endExpNow or event.getKeys(keyList=["escape"]):
            core.quit()
        
        # refresh the screen
        if continueRoutine:  # don't flip if this routine is over or we'll get a blank screen
            win.flip()
    
    #-------Ending Routine "shapeFeedback"-------
    for thisComponent in shapeFeedbackComponents:
        if hasattr(thisComponent, "setAutoDraw"):
            thisComponent.setAutoDraw(False)
    
    sendEvent("stimulus.trial","end")
    
    #-------Starting pause time ---------#
    if i is not n_reps:
        routineTimer.add(3.00)
    else:
        routineTimer.add(30.0)
        
    while routineTimer.getTime() > 0:
        # *text_4* updates
        if i is n_reps:
            text_4.text = "Longer Pause\n       " + str(int(routineTimer.getTime()))
        if t >= 0.0 and text_4.status == NOT_STARTED:
            # keep track of start time/frame for later
            text_4.tStart = t  # underestimates by a little under one frame
            text_4.frameNStart = frameN  # exact frame index
            text_4.setAutoDraw(True)
        if text_4.status == STARTED and t >= (0.0 + (3600-win.monitorFramePeriod*0.75)): #most of one frame period left
            text_4.setAutoDraw(False)
            
        if continueRoutine:  # don't flip if this routine is over or we'll get a blank screen
            win.flip()
    if i is n_reps:
        text_4.text = "Pause"
    thisExp.nextEntry()
    
# completed 1 repeats of 'trials_2'

sendEvent("stimulus.sequences", "end")
print "getFeedbackCounter:"
print getFeedbackCounter

print "sendFeedbackCounter"
print sendFeedbackCounter
win.close()
core.quit()
