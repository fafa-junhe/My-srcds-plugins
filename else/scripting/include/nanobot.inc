/** Double-include prevention */
#if defined _nanobot_included_
  #endinput
#endif
#define _nanobot_included_
 
/**
 * Returns if Nanobot(PVB) is enabled/disabled
 *
 * @return        True for enabled, false for disabled.
 */
 native bool NB_NanobotEnabled();