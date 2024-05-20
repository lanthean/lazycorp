#!/usr/bin/python3


############################################################################
#                                                                          #
#  ##          ##      ########  ##   ##   ###      ###    ####     ####   #
#  ##         ## #          ##    ## ##   ##  #   ##   #   ##  #    ##  #  #
#  ##        ##   #       ##        ##    ##      ##   #   ####     ####   #
#  ##       ########    ##         ##     ##  #   ##   #   ##  #    ##     #
#  ######  ##       #  ########   ##       ###      ###    ##   #   ##     #
#                                                                          #
############################################################################

#kill command:
#for pid in $(pgrep -f move); do kill -9 $pid; done
from Quartz.CoreGraphics import CGEventCreateMouseEvent
from Quartz.CoreGraphics import CGEventPost
from Quartz.CoreGraphics import kCGMouseButtonLeft
from Quartz.CoreGraphics import kCGEventMouseMoved
from Quartz.CoreGraphics import kCGHIDEventTap
import time
from datetime import datetime

import signal
import sys
import os

## Globals
# endTime = "16:25" 
endTime = "23:59"
inactivityTimeoutSeconds = 20
activityCounter = 0
moveCounter = 0

## Functions
def MouseMove(x, y):
    global moveCounter
    event = CGEventCreateMouseEvent(None, kCGEventMouseMoved, (x, y), kCGMouseButtonLeft)
    CGEventPost(kCGHIDEventTap, event)
    moveCounter += 1
    print("  moving mouse for user #{}".format(moveCounter))
    time.sleep(inactivityTimeoutSeconds)

def UserActive():
    global activityCounter
    inactivity = os.popen("ioreg -c IOHIDSystem | awk '/HIDIdleTime/ {print $NF/1000000000; exit}'").read()
    if abs(float(inactivity) - 0.0) < inactivityTimeoutSeconds:
        activityCounter += 1
        print("  inactivity < {}s: {}s".format(inactivityTimeoutSeconds, float(inactivity)))
        time.sleep(inactivityTimeoutSeconds)
        return True
    else:
        return False

def lzExit():
    print("| Number of times user was found active:    #{}".format(activityCounter))
    print("| Number of times mouse was moved for user: #{}".format(moveCounter))
    print("| Script had ended at " + datetime.now().strftime("%H:%M"))
    exit()

def signal_handler(sig, frame):
    print("\n| Ctrl+C caught!")
    lzExit()

signal.signal(signal.SIGINT, signal_handler)

#start time of the script
print("| Script has been started: {}".format(datetime.now()))
print("| Planned end of the script at: {}".format(endTime))
print("| Running...")

while True:
    currentTime = datetime.now().strftime("%H:%M")
    if currentTime >= endTime :
       lzExit()
    
    if UserActive(): continue
    MouseMove(600, 600)
    if UserActive(): continue
    MouseMove(650, 650)    
    
############################################################################
