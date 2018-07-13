 #include <sourcemod>
 #include <tf2>
 #include <tf2_stocks>

ConVar g_enabled;
bool playing_mvm = false;

public void OnPluginStart() {
	g_enabled = CreateConVar("sm_kartbots_enabled", "0", "Enable plugin");
}

public void OnMapStart() {
	playing_mvm = IsGamemodeMvm();
}

public void TF2_OnConditionRemoved(int client, TFCond condition) {
	if (!playing_mvm || !GetConVarBool(g_enabled))
		return;

	if (TF2_GetClientTeam(client) == TFTeam_Blue && condition == view_as<TFCond>(51)) // Robot Spawn Invul effect
		TF2_AddCondition(client, view_as<TFCond>(82));
}

public void TF2_OnConditionAdded(int client, TFCond condition) {
	if (!playing_mvm || !GetConVarBool(g_enabled))
		return;

	if (TF2_GetClientTeam(client) == TFTeam_Blue && condition == view_as<TFCond>(51)) // Robot Spawn Invul effect
		TF2_RemoveCondition(client, view_as<TFCond>(82));
}

bool IsGamemodeMvm() {
	if (GameRules_GetProp("m_bPlayingMannVsMachine") == -1)
		return false;
	else
		return true;
}