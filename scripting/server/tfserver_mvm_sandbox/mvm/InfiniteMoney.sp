#include <sourcemod>
#include <tf2>
#include <tf2_stocks>
#include <server/serverchat>

bool playing_mvm = false;

ConVar g_enabled;

public void OnPluginStart() {
	g_enabled = CreateConVar("sm_mvm_infinitemoney", "0", "Enable plugin", _, true, 0.0, true, 1.0);
	//g_enabled.AddChangeHook(OnInfiniteMoneyChange);

	CreateTimer(1.0, Timer_GiveMoney, _, TIMER_REPEAT);
}

public void OnMapStart() {
	playing_mvm = GameRules_GetProp("m_bPlayingMannVsMachine") != 0;
}

/*public void OnInfiniteMoneyChange(ConVar convar, char[] oldValue, char[] newValue)
{
	if (playing_mvm) {
		SetCommandFlags("tf_mvm_jump_to_wave", FCVAR_NONE);
		ServerCommand("tf_mvm_jump_to_wave 1");
		Server_PrintToChatAll("Server", "Mission has been reset.");
		CreateTimer(1.0, Delay_UnCheatCommand);
	}
}

public Action Delay_UnCheatCommand(Handle timer) {
	SetCommandFlags("tf_mvm_jump_to_wave", FCVAR_CHEAT);
}*/

public Action Timer_GiveMoney(Handle timer) {
	if (!playing_mvm || !GetConVarBool(g_enabled))
		return Plugin_Continue;

	for (int client = 1; client < MaxClients + 1; client++)
		if (IsClientInGame(client) && !IsFakeClient(client))
			SetEntProp(client, Prop_Send, "m_nCurrency", 30000);

	return Plugin_Handled;
}
