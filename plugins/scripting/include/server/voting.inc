/** Double-include prevention */
#if defined _voting_natives_included_
  #endinput
#endif
#define _voting_natives_included_

/**
 * Creates a Boolean ConVar Change Vote Menu
 *
 * @param convar 	The ConVar to change
 * @param question 	The question to show
 */
native void Voting_CreateYesNoConVarVote(int client, char[] convar, char[] question, int true_value=1, int false_value=0);

/**
 * Creates a Multi-Value ConVar Change Vote Menu
 *
 * @param convar 	The ConVar to change
 * @param question 	The question to show
 * @param values	The values to select from
 */
native void Voting_CreateStringConVarVote(int client, char[] convar, char[] question, char[] ...);

/**
 * Creates a Yes/No Vote for an Command Execution
 *
 * @param command 	The Command to execute
 * @param question 	The question to show
 */
native void Voting_CreateYesNoCommandVote(int client, char[] commandYes, char[] question, char[] commandNo = "");