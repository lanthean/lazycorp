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

import time
from datetime import datetime
import signal
import logging
import os
import yaml
from Xlib import X, display
from Xlib.ext import xtest

## Measure time
start = time.perf_counter()

## Globals
configFile = "../config.yaml"
# endTime and logLevel is set ^ in config.yaml
activityCounter = 0
moveCounter = 0
cfg = ""

## Functions
def MouseMove(x, y, relative=False, positive=True):
    global moveCounter
    d = display.Display()
    screen = d.screen()
    root = screen.root
    if relative:
        log.debug("Move mouse relative to current position")
        pointer = root.query_pointer()
        if positive: relative_difference = 1
        else: relative_difference = -1
        log.debug("root.warp_pointer({} + {}, {} + {})".format(pointer.root_x, relative_difference, pointer.root_y, relative_difference))
        root.warp_pointer(pointer.root_x + relative_difference, pointer.root_y + relative_difference)
    else:
        root.warp_pointer(x, y)
    d.sync()
    moveCounter += 1
    log.debug("Moving mouse for user #{}".format(moveCounter))
    time.sleep(cfg['inactivityTimeoutSeconds'])

def UserActive():
    global activityCounter
    # Use `xprintidle` to get idle time in milliseconds
    idle_time = int(os.popen("xprintidle").read().strip()) / 1000  # Convert to seconds
    if idle_time < cfg['inactivityTimeoutSeconds']:
        activityCounter += 1
        log.debug("Inactivity < {}s: {}s".format(cfg['inactivityTimeoutSeconds'], idle_time))
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
    log.info("Script ended at {}, ran for {}h:{}m:{}s".format(datetime.now().strftime("%H:%M"), int(h), int(m), int(s)))
    exit()

def signal_handler(sig, frame):
    print("")
    log.warning("Ctrl+C caught!")
    lzExit()

signal.signal(signal.SIGINT, signal_handler)

## Config
cfg = LoadConfiguration(configFile)

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
log.info("Script started: {}".format(datetime.now()))
log.info("Planned end of the script at: {}".format(cfg['endTime']))
log.info("Running...")

while True:
    currentTime = datetime.now().strftime("%H:%M")
    if currentTime >= cfg['endTime']:
        lzExit()
    
    if UserActive(): 
        continue
    MouseMove(600, 1080, True, True)
    if UserActive(): 
        continue
    MouseMove(650, 1080, True, False)
