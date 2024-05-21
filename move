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
import logging
import os
import yaml

## Measure time
start = time.perf_counter()

## Globals
configFile="../config.yaml"
# endTime and logLevel is set ^ in config.yaml
activityCounter = 0
moveCounter = 0
cfg = ""

## Functions
def MouseMove(x, y):
    global moveCounter
    event = CGEventCreateMouseEvent(None, kCGEventMouseMoved, (x, y), kCGMouseButtonLeft)
    CGEventPost(kCGHIDEventTap, event)
    moveCounter += 1
    log.debug("moving mouse for user #{}".format(moveCounter))
    time.sleep(cfg['inactivityTimeoutSeconds'])

def UserActive():
    global activityCounter
    inactivity = os.popen("ioreg -c IOHIDSystem | awk '/HIDIdleTime/ {print $NF/1000000000; exit}'").read()
    if abs(float(inactivity) - 0.0) < cfg['inactivityTimeoutSeconds']:
        activityCounter += 1
        log.debug("inactivity < {}s: {}s".format(cfg['inactivityTimeoutSeconds'], float(inactivity)))
        time.sleep(cfg['inactivityTimeoutSeconds'])
        return True
    else:
        return False

def LoadConfiguration(configFile):
    with open(configFile) as f:
        cfg = yaml.load(f, Loader=yaml.FullLoader)
    return cfg

def lzExit():
    log.info("Number of times user was found active:    #{}".format(activityCounter))
    log.info("Number of times mouse was moved for user: #{}".format(moveCounter))
    timeRunInSeconds = time.perf_counter() - start
    m, s = divmod(timeRunInSeconds, 60)
    h, m = divmod(m, 60)
    log.info("Script had ended at {}, ran for {}h {}m {}s".format(datetime.now().strftime("%H:%M"), int(h), int(m), int(s)))
    exit()

def signal_handler(sig, frame):
    print("")
    log.warning("Ctrl+C caught!")
    lzExit()

signal.signal(signal.SIGINT, signal_handler)

## Config
cfg = LoadConfiguration(configFile)
# print(cfg['logLevel'])
# exit()
## Logging
# Configure logging
logging.addLevelName(logging.DEBUG, 'd')
logging.addLevelName(logging.INFO, 'i')
logging.addLevelName(logging.WARNING, 'w')
logging.addLevelName(logging.ERROR, 'e')
logging.basicConfig(level=eval(cfg['logLevel']), format='| [%(levelname)s] %(message)s')

# Create a logger with configured logging module
log = logging.getLogger('LazyCorpMoveMouse')

# Start the run
log.info("Script has been started: {}".format(datetime.now()))
log.info("Planned end of the script at: {}".format(cfg['endTime']))
log.info("Running...")

while True:
    currentTime = datetime.now().strftime("%H:%M")
    if currentTime >= cfg['endTime'] :
       lzExit()
    
    if UserActive(): continue
    MouseMove(600, 600)
    if UserActive(): continue
    MouseMove(650, 650)    
    
############################################################################
