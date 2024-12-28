 #include <sourcemod>
 #include <tf2>
 #include <tf2_stocks>

ConVar g_enabled;
bool playing_mvm = false;

public void OnPluginStart() {
	g_enabled = CreateConVar("sm_chargebots_enabled", "0", "Enable plugin");
	CreateTimer(1.0, Timer_ActivateCharge, _, TIMER_REPEAT);
}

public void OnMapStart() {
	playing_mvm = IsGamemodeMvm();
}

public Action Timer_ActivateCharge(Handle timer, int client) {
	if (!playing_mvm || !GetConVarBool(g_enabled))
		return Plugin_Continue;

	for (int client = 1; client < MaxClients; client++)
		if (IsClientInGame(client) && TF2_GetClientTeam(client) == TFTeam_Blue)
			if (!TF2_IsPlayerInCondition(client, view_as<TFCond>(51))) // 51 = Robot Spawn Effect
				TF2_AddCondition(client, view_as<TFCond>(17));
			else
				TF2_RemoveCondition(client, view_as<TFCond>(17));

	return Plugin_Handled;
}

bool IsGamemodeMvm() {
	if (GameRules_GetProp("m_bPlayingMannVsMachine") == -1)
		return false;
	else
		return true;
}
