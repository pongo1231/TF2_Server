#include <sourcemod>

Handle hudSync;

public void OnPluginStart() {
	hudSync = CreateHudSynchronizer();
	HookEvent("player_spawn", Event_PlayerSpawn);
}

public Action Event_PlayerSpawn(Handle event, const char[] name, bool dontBroadcast) {
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	CreateTimer(0.25, Delay_ShowHudText, client);
}

public Action Delay_ShowHudText(Handle timer, int client) {
	SetHudTextParams(0.01, 0.01, 9999999999.0, 0, 153, 0, 127, 0, 0.0, 0.0);
	ShowSyncHudText(client, hudSync, "DuckyServers EU");
}

public void OnPluginEnd() {
	delete hudSync;
}