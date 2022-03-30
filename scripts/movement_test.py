# =============================================================================
# TTGO-T1
# - ATROVER DC motors control (via UART)
#
# Serial protocol
# ?: Info message
# !: Emergency stop
# *: commands (speed = atoi(###))
#    f###: move forward
#    b###: move backward atoi(###)
#    l###: turn left atoi(###)
#    r###: turn right atoi(###)
#    s000: stop
# B: busy
# I: idle
# I###: ACK idle
import sys
import serial
from time import sleep

ttgo = serial.Serial('/dev/ttyCH343USB0', 115200, timeout=0.1)
print(f"<TTGO> connected to {ttgo.name}")

# ----------------------------------------------------
CMD_LEN = 5
PING_CMD = b'?PING'
SYNC_CMD = b'^^^^^'
ACKI_CMD = b'IIIII'

commands = [
    b'*f064',
    b'*b064',
    b'*l064',
    b'*r064',
    b'*s000',
]

# ----------------------------------------------------
# Flush
while b'I' in ttgo.read(CMD_LEN):
    ttgo.write(ACKI_CMD)
    sleep(1)
    ttgo.read(100)
# ----------------------------------------------------
# Sync
ttgo.write(SYNC_CMD)
while ttgo.read(CMD_LEN)!=SYNC_CMD:
    ttgo.write(SYNC_CMD[0])
    pass

# ----------------------------------------------------
ttgo.write(PING_CMD)
echo = ttgo.read(CMD_LEN)
if echo != PING_CMD:
    print(f'<ERROR> Unable to sync with TTGO! ({echo})')
    ttgo.close()
    sys.exit(1)
    
else:
    print(f'<TTGO> sync')

# ----------------------------------------------------
# Send commands
for cmd in commands:
    print(f"tx: {cmd}")
    ttgo.write(cmd)
    echo = ttgo.read(CMD_LEN)
    print(f"rx: {echo}")
    
    if(cmd[0]==b'*'[0]):
        # Movement command issued, wait for done
        while True:
            ack = ttgo.read()
            if b'I' in ack:
                break
        
        # ACK idle
        ttgo.write(ACKI_CMD)
        
        # Flush
        while ttgo.read(10):
            pass
        
ttgo.close()
