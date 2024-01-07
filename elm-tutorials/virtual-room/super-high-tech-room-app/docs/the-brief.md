1. If the alarm is armed, then it should be triggered by the door opening.
2. If the alarm has been triggered, then it can be disarmed, but not armed.
3. If the door is open, the alarm's current state can not be altered manually.
4. If the door is open it can be closed.
5. If the door is closed it can be opened or locked.
6. If the door is locked it can be unlocked.


```text
-- POSSIBLE STATES:

Door:
  Locked
  Closed
  Opened

Alarm:
  Armed
  Disarmed
  Triggered

Combined:
  Locked + Armed
  Locked + Triggered
  Locked + Disarmed
  Unlocked + Armed
  Unlocked + Triggered
  Unlocked + Disarmed
  Opened + Triggered
  Opened + Disarmed
```
