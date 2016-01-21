#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
This experiment was created using PsychoPy2 Experiment Builder (v1.79.01), January 20, 2016, at 17:25
If you publish work using this script please cite the relevant PsychoPy publications
  Peirce, JW (2007) PsychoPy - Psychophysics software in Python. Journal of Neuroscience Methods, 162(1-2), 8-13.
  Peirce, JW (2009) Generating stimuli for neuroscience using PsychoPy. Frontiers in Neuroinformatics, 2:10. doi: 10.3389/neuro.11.010.2008
"""

from __future__ import division  # so that 1/3=0.333 instead of 1/3=0
from psychopy import locale_setup, visual, core, data, event, logging, sound, gui
from psychopy.constants import *  # things like STARTED, FINISHED
import numpy as np  # whole numpy lib is available, prepend 'np.'
from numpy import sin, cos, tan, log, log10, pi, average, sqrt, std, deg2rad, rad2deg, linspace, asarray
from numpy.random import random, randint, normal, shuffle
import os  # handy system and path functions
import sys # to get file system encoding

# Ensure that relative paths start from the same directory as this script
_thisDir = os.path.dirname(os.path.abspath(__file__)).decode(sys.getfilesystemencoding())
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
    originPath=u'C:\\Users\\Thoma\\Documents\\Universiteit\\BCI\\bci_practical_heyni_boorn_janssen\\buffer_bci-master\\python\\imaginedMovement_psychoPy\\simple_imagined_movement.psyexp',
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
    text='Simple Imagined Movement Experiment\n\nDuring the trails imagine yourself vigerously shaking the indicated body part (left hand, right hand, left foot or right foot).\n\nPress <space> to continue.',    font='Arial',
    pos=[0, 0], height=0.1, wrapWidth=80,
    color='white', colorSpace='rgb', opacity=1,
    depth=0.0)
# buffer_bci Handling the requered imports
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

# Initialize components for Routine "feedbackInstructions"
feedbackInstructionsClock = core.Clock()
text_4 = visual.TextStim(win=win, ori=0, name='text_4',
    text='Feedback Phase',    font='Arial',
    pos=[0, 0], height=0.1, wrapWidth=None,
    color='white', colorSpace='rgb', opacity=1,
    depth=0.0)

# Initialize components for Routine "stimulusFeedback"
stimulusFeedbackClock = core.Clock()
ISI = core.StaticPeriod(win=win, screenHz=expInfo['frameRate'], name='ISI')
imagination_instruction = visual.TextStim(win=win, ori=0, name='imagination_instruction',
    text='default text',    font='Arial',
    pos=[0, 0], height=0.1, wrapWidth=None,
    color='white', colorSpace='rgb', opacity=1,
    depth=-1.0)
sendFeedbackCounter = 0

# Initialize components for Routine "feedback"
feedbackClock = core.Clock()
getFeedbackCounter = 0
text_5 = visual.TextStim(win=win, ori=0, name='text_5',
    text='default text',    font='Arial',
    pos=[0, 0], height=0.1, wrapWidth=None,
    color='white', colorSpace='rgb', opacity=1,
    depth=-1.0)

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
        win.callOnFlip(key_resp_2.clock.reset)  # t=0 on next screen flip
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

#------Prepare to start Routine "feedbackInstructions"-------
t = 0
feedbackInstructionsClock.reset()  # clock 
frameN = -1
# update component parameters for each repeat
key_resp_3 = event.BuilderKeyResponse()  # create an object of type KeyResponse
key_resp_3.status = NOT_STARTED
# keep track of which components have finished
feedbackInstructionsComponents = []
feedbackInstructionsComponents.append(text_4)
feedbackInstructionsComponents.append(key_resp_3)
for thisComponent in feedbackInstructionsComponents:
    if hasattr(thisComponent, 'status'):
        thisComponent.status = NOT_STARTED

#-------Start Routine "feedbackInstructions"-------
continueRoutine = True
while continueRoutine:
    # get current time
    t = feedbackInstructionsClock.getTime()
    frameN = frameN + 1  # number of completed frames (so 0 is the first frame)
    # update/draw components on each frame
    
    # *text_4* updates
    if t >= 0.0 and text_4.status == NOT_STARTED:
        # keep track of start time/frame for later
        text_4.tStart = t  # underestimates by a little under one frame
        text_4.frameNStart = frameN  # exact frame index
        text_4.setAutoDraw(True)
    if text_4.status == STARTED and t >= (0.0 + (3600-win.monitorFramePeriod*0.75)): #most of one frame period left
        text_4.setAutoDraw(False)
    
    # *key_resp_3* updates
    if t >= 0.0 and key_resp_3.status == NOT_STARTED:
        # keep track of start time/frame for later
        key_resp_3.tStart = t  # underestimates by a little under one frame
        key_resp_3.frameNStart = frameN  # exact frame index
        key_resp_3.status = STARTED
        # keyboard checking is just starting
        win.callOnFlip(key_resp_3.clock.reset)  # t=0 on next screen flip
        event.clearEvents(eventType='keyboard')
    if key_resp_3.status == STARTED:
        theseKeys = event.getKeys(keyList=['y', 'n', 'left', 'right', 'space'])
        
        # check for quit:
        if "escape" in theseKeys:
            endExpNow = True
        if len(theseKeys) > 0:  # at least one key was pressed
            key_resp_3.keys = theseKeys[-1]  # just the last key pressed
            key_resp_3.rt = key_resp_3.clock.getTime()
            # a response ends the routine
            continueRoutine = False
    
    # check if all components have finished
    if not continueRoutine:  # a component has requested a forced-end of Routine
        break
    continueRoutine = False  # will revert to True if at least one component still running
    for thisComponent in feedbackInstructionsComponents:
        if hasattr(thisComponent, "status") and thisComponent.status != FINISHED:
            continueRoutine = True
            break  # at least one component has not yet finished
    
    # check for quit (the Esc key)
    if endExpNow or event.getKeys(keyList=["escape"]):
        core.quit()
    
    # refresh the screen
    if continueRoutine:  # don't flip if this routine is over or we'll get a blank screen
        win.flip()

#-------Ending Routine "feedbackInstructions"-------
for thisComponent in feedbackInstructionsComponents:
    if hasattr(thisComponent, "setAutoDraw"):
        thisComponent.setAutoDraw(False)
# check responses
if key_resp_3.keys in ['', [], None]:  # No response was made
   key_resp_3.keys=None
# store data for thisExp (ExperimentHandler)
thisExp.addData('key_resp_3.keys',key_resp_3.keys)
if key_resp_3.keys != None:  # we had a response
    thisExp.addData('key_resp_3.rt', key_resp_3.rt)
thisExp.nextEntry()
# the Routine "feedbackInstructions" was not non-slip safe, so reset the non-slip timer
routineTimer.reset()

# set up handler to look after randomisation of conditions etc
trials_2 = data.TrialHandler(nReps=1, method='random', 
    extraInfo=expInfo, originPath=-1,
    trialList=data.importConditions('stimulus_conditions.csv'),
    seed=None, name='trials_2')
thisExp.addLoop(trials_2)  # add the loop to the experiment
thisTrial_2 = trials_2.trialList[0]  # so we can initialise stimuli with some values
# abbreviate parameter names if possible (e.g. rgb=thisTrial_2.rgb)
if thisTrial_2 != None:
    for paramName in thisTrial_2.keys():
        exec(paramName + '= thisTrial_2.' + paramName)

for thisTrial_2 in trials_2:
    currentLoop = trials_2
    # abbreviate parameter names if possible (e.g. rgb = thisTrial_2.rgb)
    if thisTrial_2 != None:
        for paramName in thisTrial_2.keys():
            exec(paramName + '= thisTrial_2.' + paramName)
    
    #------Prepare to start Routine "stimulusFeedback"-------
    t = 0
    stimulusFeedbackClock.reset()  # clock 
    frameN = -1
    routineTimer.add(4.000000)
    # update component parameters for each repeat
    imagination_instruction.setText(instruction)
    sendEvent("feedbackStimulus" + str(sendFeedbackCounter), "")
    sendFeedbackCounter = 0 + sendFeedbackCounter
    # keep track of which components have finished
    stimulusFeedbackComponents = []
    stimulusFeedbackComponents.append(ISI)
    stimulusFeedbackComponents.append(imagination_instruction)
    for thisComponent in stimulusFeedbackComponents:
        if hasattr(thisComponent, 'status'):
            thisComponent.status = NOT_STARTED
    
    #-------Start Routine "stimulusFeedback"-------
    continueRoutine = True
    while continueRoutine and routineTimer.getTime() > 0:
        # get current time
        t = stimulusFeedbackClock.getTime()
        frameN = frameN + 1  # number of completed frames (so 0 is the first frame)
        # update/draw components on each frame
        
        # *imagination_instruction* updates
        if t >= 0.0 and imagination_instruction.status == NOT_STARTED:
            # keep track of start time/frame for later
            imagination_instruction.tStart = t  # underestimates by a little under one frame
            imagination_instruction.frameNStart = frameN  # exact frame index
            imagination_instruction.setAutoDraw(True)
        if imagination_instruction.status == STARTED and t >= (0.0 + (4-win.monitorFramePeriod*0.75)): #most of one frame period left
            imagination_instruction.setAutoDraw(False)
        
        # *ISI* period
        if t >= 0.0 and ISI.status == NOT_STARTED:
            # keep track of start time/frame for later
            ISI.tStart = t  # underestimates by a little under one frame
            ISI.frameNStart = frameN  # exact frame index
            ISI.start(0.5)
        elif ISI.status == STARTED: #one frame should pass before updating params and completing
            ISI.complete() #finish the static period
        
        # check if all components have finished
        if not continueRoutine:  # a component has requested a forced-end of Routine
            break
        continueRoutine = False  # will revert to True if at least one component still running
        for thisComponent in stimulusFeedbackComponents:
            if hasattr(thisComponent, "status") and thisComponent.status != FINISHED:
                continueRoutine = True
                break  # at least one component has not yet finished
        
        # check for quit (the Esc key)
        if endExpNow or event.getKeys(keyList=["escape"]):
            core.quit()
        
        # refresh the screen
        if continueRoutine:  # don't flip if this routine is over or we'll get a blank screen
            win.flip()
    
    #-------Ending Routine "stimulusFeedback"-------
    for thisComponent in stimulusFeedbackComponents:
        if hasattr(thisComponent, "setAutoDraw"):
            thisComponent.setAutoDraw(False)
    
    
    #------Prepare to start Routine "feedback"-------
    t = 0
    feedbackClock.reset()  # clock 
    frameN = -1
    routineTimer.add(2.000000)
    # update component parameters for each repeat
    feedbackEvt = waitnewevents("feedback",1000)
    if feedbackEvt is None:
        feedbackTxt='None'
    else:
        feedbackTxt=str(feedbackEvt[0].value)
    getFeedbackCounter = getFeedbackCounter + 1 
    text_5.setText("Feedback = " + feedbackTxt)
    # keep track of which components have finished
    feedbackComponents = []
    feedbackComponents.append(text_5)
    for thisComponent in feedbackComponents:
        if hasattr(thisComponent, 'status'):
            thisComponent.status = NOT_STARTED
    
    #-------Start Routine "feedback"-------
    continueRoutine = True
    while continueRoutine and routineTimer.getTime() > 0:
        # get current time
        t = feedbackClock.getTime()
        frameN = frameN + 1  # number of completed frames (so 0 is the first frame)
        # update/draw components on each frame
        
        
        # *text_5* updates
        if t >= 0.0 and text_5.status == NOT_STARTED:
            # keep track of start time/frame for later
            text_5.tStart = t  # underestimates by a little under one frame
            text_5.frameNStart = frameN  # exact frame index
            text_5.setAutoDraw(True)
        if text_5.status == STARTED and t >= (0.0 + (2-win.monitorFramePeriod*0.75)): #most of one frame period left
            text_5.setAutoDraw(False)
        
        # check if all components have finished
        if not continueRoutine:  # a component has requested a forced-end of Routine
            break
        continueRoutine = False  # will revert to True if at least one component still running
        for thisComponent in feedbackComponents:
            if hasattr(thisComponent, "status") and thisComponent.status != FINISHED:
                continueRoutine = True
                break  # at least one component has not yet finished
        
        # check for quit (the Esc key)
        if endExpNow or event.getKeys(keyList=["escape"]):
            core.quit()
        
        # refresh the screen
        if continueRoutine:  # don't flip if this routine is over or we'll get a blank screen
            win.flip()
    
    #-------Ending Routine "feedback"-------
    for thisComponent in feedbackComponents:
        if hasattr(thisComponent, "setAutoDraw"):
            thisComponent.setAutoDraw(False)
    
    thisExp.nextEntry()
    
# completed 1 repeats of 'trials_2'




win.close()
core.quit()
