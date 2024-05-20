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

def signal_handler(sig, frame):
    print("\n| [w] Ctrl+C caught!")
    sys.exit(0)

signal.signal(signal.SIGINT, signal_handler)

endtime = "16:25" 
#endtime = "23:59"

#start time of the script
print(("Script has been started: ") + str(datetime.now()))
print("Planed end of the script at: " + endtime)
print("Running...")

def MouseMove(x, y):
        event = CGEventCreateMouseEvent(None, kCGEventMouseMoved, (x, y), kCGMouseButtonLeft)
        CGEventPost(kCGHIDEventTap, event)

while True:
    inactivity = os.popen("ioreg -c IOHIDSystem | awk '/HIDIdleTime/ {print $NF/1000000000; exit}'").read()
    if abs(float(inactivity) - 0.0) < 20:
        print("inactivity: {}".format(float(inactivity)))
        time.sleep(20)
        continue
    
    print("moving mouse for user")
    MouseMove(600, 600)
    time.sleep(20)

    inactivity = os.popen("ioreg -c IOHIDSystem | awk '/HIDIdleTime/ {print $NF/1000000000; exit}'").read()
    if abs(float(inactivity) - 0.0) < 20:
        print("inactivity: {}".format(float(inactivity)))
        time.sleep(20)
        continue
    
    print("moving mouse for user")
    MouseMove(650, 650)
    
    currentTime = datetime.now().strftime("%H:%M")
    if currentTime >= endtime :
       print("Script had ended at " + datetime.now().strftime("%H:%M"))
       exit()
    time.sleep(20)
    

############################################################################
