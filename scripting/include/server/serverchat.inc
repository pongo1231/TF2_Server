/** Double-include prevention */
#if defined _serverchat_natives_included_
  #endinput
#endif
#define _serverchat_natives_included_

/**
 * Prints a Server Message to a Client
 *
 * @param convar 	The ConVar to change
 * @param question 	The question to show
 */
native void Server_PrintToChat(int client, char[] tag, char[] text);

/**
 * Prints a Server Messages to all Clients
 *
 * @param convar 	The ConVar to change
 * @param question 	The question to show
 * @param values	The values to select from
 */
native void Server_PrintToChatAll(char[] tag, char[] text);