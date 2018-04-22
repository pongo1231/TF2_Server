 #include <sourcemod>
 #include <tf2>
 #include <tf2_stocks>

ConVar g_enabled;
bool playing_mvm = false;

public void OnPluginStart() {
	g_enabled = CreateConVar("sm_kartbots_enabled", "0", "Enable plugin");
	CreateTimer(1.0, Timer_KartBots, _, TIMER_REPEAT);
}

public void OnMapStart() {
	playing_mvm = IsGamemodeMvm();
}

public Action Timer_KartBots(Handle timer) {
	if (!playing_mvm)
		return Plugin_Continue;

	for (int i = 1; i < GetMaxClients(); i++)
		if (IsClientInGame(i) && TF2_GetClientTeam(i) == TFTeam_Blue)
			if (GetConVarBool(g_enabled)) {
 				if (!TF2_IsPlayerInCondition(i, view_as<TFCond>(82)) && !TF2_IsPlayerInCondition(i, view_as<TFCond>(51))) 
					TF2_AddCondition(i, view_as<TFCond>(82));
				else if (TF2_IsPlayerInCondition(i, view_as<TFCond>(51)) && TF2_IsPlayerInCondition(i, view_as<TFCond>(82)))
					TF2_RemoveCondition(i, view_as<TFCond>(82));
			} else if (!GetConVarBool(g_enabled) && TF2_IsPlayerInCondition(i, view_as<TFCond>(82)))
				TF2_RemoveCondition(i, view_as<TFCond>(82));

	return Plugin_Handled;
}

bool IsGamemodeMvm() {
	if (GameRules_GetProp("m_bPlayingMannVsMachine") == -1)
		return false;
	else
		return true;
}