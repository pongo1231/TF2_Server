 #include <sourcemod>
 #include <tf2>
 #include <tf2_stocks>
 #include <betherobot>

ConVar g_enabled;
bool playing_mvm = false;

public void OnPluginStart() {
	g_enabled = CreateConVar("sm_robotshuman_enabled", "0", "Enable plugin");
	HookEvent("player_spawn", Event_PlayerSpawn);
}

public void OnMapStart() {
	playing_mvm = IsGamemodeMvm();
}

public Action Event_PlayerSpawn(Handle event, const char[] name, bool dontBroadcast) {
	if (!playing_mvm || !GetConVarBool(g_enabled))
		return Plugin_Continue;

	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (TF2_GetClientTeam(client) == TFTeam_Blue)
		CreateTimer(1.0, Delay_MakeHuman, client);

	return Plugin_Handled;
}

public Action Delay_MakeHuman(Handle timer, int client) {
	BeTheRobot_SetRobot(client, false);
	if (BeTheRobot_GetRobotStatus(client) != RobotStatus_Human)
		CreateTimer(0.1, Delay_MakeHuman, client);
}

bool IsGamemodeMvm() {
	if (GameRules_GetProp("m_bPlayingMannVsMachine") == -1)
		return false;
	else
		return true;
}