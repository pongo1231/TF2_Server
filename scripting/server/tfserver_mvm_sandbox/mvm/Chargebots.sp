 #include <sourcemod>
 #include <tf2>
 #include <tf2_stocks>

ConVar g_enabled;
bool playing_mvm = false;

public void OnPluginStart() {
	g_enabled = CreateConVar("sm_chargebots_enabled", "0", "Enable plugin");
	CreateTimer(0.2, Timer_ActivateCharge, _, TIMER_REPEAT);
}

public void OnMapStart() {
	playing_mvm = IsGamemodeMvm();
}

public Action Timer_ActivateCharge(Handle timer, int client) {
	if (!playing_mvm || !GetConVarBool(g_enabled))
		return Plugin_Stop;

	for (int i = 1; i < GetMaxClients(); i++)
		if (IsClientInGame(i) && TF2_GetClientTeam(i) == TFTeam_Blue)
			if (!TF2_IsPlayerInCondition(i, view_as<TFCond>(51))) // 51 = Robot Spawn Effect
				TF2_AddCondition(i, view_as<TFCond>(17));
			else
				TF2_RemoveCondition(i, view_as<TFCond>(17));

	return Plugin_Handled;
}

bool IsGamemodeMvm() {
	if (GameRules_GetProp("m_bPlayingMannVsMachine") == -1)
		return false;
	else
		return true;
}