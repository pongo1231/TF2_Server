#include <sourcemod>
#include <tf2>
#include <tf2_stocks>
#include <server/serverchat>

bool playing_mvm = false;

ConVar g_enabled;
ConVar g_blindbots;

public void OnPluginStart() {
	g_enabled = CreateConVar("sm_mvm_blindrobots", "0", "Enable plugin", _, true, 0.0, true, 1.0);
	g_enabled.AddChangeHook(OnBlindRobotsChange);
	g_blindbots = FindConVar("nb_blind");

	SetConVarBool(g_blindbots, GetConVarBool(g_enabled));
}

public void OnMapStart() {
	playing_mvm = IsGamemodeMvm();
}

public void OnBlindRobotsChange(ConVar convar, char[] oldValue, char[] newValue)
{
	if (playing_mvm) {
		SetConVarBool(g_blindbots, GetConVarBool(g_enabled));

		SetCommandFlags("tf_mvm_jump_to_wave", FCVAR_NONE);
		ServerCommand("tf_mvm_jump_to_wave 1");
		Server_PrintToChatAll("Server", "Mission has been reset.");
		CreateTimer(1.0, Delay_UnCheatCommand);
	}
}

public Action Delay_UnCheatCommand(Handle timer) {
	SetCommandFlags("tf_mvm_jump_to_wave", FCVAR_CHEAT);
}

bool IsGamemodeMvm() {
	return GameRules_GetProp("m_bPlayingMannVsMachine") ? true : false;
}